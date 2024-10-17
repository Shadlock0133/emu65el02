use core::mem;
use std::{
    env, fs,
    io::{stderr, Write},
    iter,
    ops::{Index, IndexMut, RangeFrom},
};

use emu65el02::Decoder;

const RPCBOOT: &[u8] = include_bytes!("../../rpcboot.bin");
const FLAG_C: u8 = 0x01;
const FLAG_Z: u8 = 0x02;
const FLAG_I: u8 = 0x04;
const FLAG_D: u8 = 0x08;
const FLAG_X: u8 = 0x10;
const FLAG_M: u8 = 0x20;
const FLAG_V: u8 = 0x40;
const FLAG_N: u8 = 0x80;

struct Cpu {
    a: u16,
    pc: u16,
    p: u8,
    emu: bool,
    s: u16,
    x: u16,
    y: u16,
    r: u16,
    i: u16,
    d: u16,
}

struct Mem {
    mem: [u8; 0x10000],
    size: u8,
}

impl Mem {
    pub fn new(size: u8) -> Self {
        assert!((1..=8).contains(&size));
        let mut mem = [0; 0x10000];
        mem[0] = 2;
        mem[1] = 1;
        mem[0x400..][..RPCBOOT.len()].copy_from_slice(RPCBOOT);
        Self { mem, size }
    }
}

impl Index<u16> for Mem {
    type Output = u8;

    fn index(&self, index: u16) -> &Self::Output {
        &self.mem[usize::from(index)]
    }
}

impl Index<RangeFrom<u16>> for Mem {
    type Output = [u8];

    fn index(&self, index: RangeFrom<u16>) -> &Self::Output {
        &self.mem[usize::from(index.start)..]
    }
}

impl IndexMut<u16> for Mem {
    fn index_mut(&mut self, index: u16) -> &mut Self::Output {
        &mut self.mem[usize::from(index)]
    }
}

impl IndexMut<RangeFrom<u16>> for Mem {
    fn index_mut(&mut self, index: RangeFrom<u16>) -> &mut Self::Output {
        &mut self.mem[usize::from(index.start)..]
    }
}

struct Disk {
    name: [u8; 64],
    data: Vec<u8>,
}
impl Disk {
    fn new(name: &str, data: Vec<u8>) -> Self {
        let mut name_buf = [0; 64];
        name_buf[..name.len()].copy_from_slice(name.as_bytes());
        Self {
            name: name_buf,
            data,
        }
    }
}

#[derive(Default)]
struct DiskDrive(Option<Disk>, u16);

struct Interconnect {
    cpu: Cpu,
    mem: Mem,
    device_id: u8,
    rb_window: u16,
    rb_state: bool,
    mm_window: u16,
    mm_state: bool,
    disk_drive: DiskDrive,
}

fn write_hex<W: Write>(mut w: W, data: &[u8], width: usize) {
    for x in data.iter().map(Some).chain(iter::repeat(None)).take(width) {
        match x {
            Some(x) => write!(w, "{x:02x} "),
            None => write!(w, "   "),
        }
        .unwrap()
    }
}

macro_rules! gen_flag_methods {
    ( $( $name:ident : $flag:ident ),* $(,)?) => {
        $(paste::paste!(
            #[allow(unused)]
            fn $name(&self) -> bool {
                self.cpu.p & $flag != 0
            }
            #[allow(unused)]
            fn [<set_ $name>](&mut self, value: bool) {
                if value {
                    self.cpu.p |= $flag;
                } else {
                    self.cpu.p &= !$flag;
                }
            }
        );)*
    };
}

impl Interconnect {
    gen_flag_methods!(
        c: FLAG_C,
        z: FLAG_Z,
        i: FLAG_I,
        d: FLAG_D,
        x: FLAG_X,
        m: FLAG_M,
        v: FLAG_V,
        n: FLAG_N,
    );

    fn set_flags(&mut self, value: u16, flag_mask: u8) {
        if flag_mask & FLAG_Z != 0 {
            self.set_z(value == 0);
        }
        if flag_mask & FLAG_N != 0 {
            self.set_n(value & 0x8000 != 0);
        }
    }
}

impl Interconnect {
    pub fn new() -> Self {
        Self {
            cpu: Cpu {
                a: 0,
                pc: 0x400,
                p: 0b_0011_0000,
                emu: true,
                s: 0x200,
                x: 0,
                y: 0,
                r: 0x300,
                i: 0,
                d: 0,
            },
            device_id: 0,
            rb_window: 0,
            rb_state: false,
            mm_window: 0,
            mm_state: false,
            mem: Mem::new(8),
            disk_drive: Default::default(),
        }
    }

    fn read_byte(&mut self, addr: u16) -> u8 {
        if self.rb_state
            && (self.rb_window..self.rb_window + 0x100).contains(&addr)
        {
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr) {
                (0x01, _) => todo!(),
                (0x02, 0x00..=0x7f) => self.mem[addr],
                (0x02, 0x80) => self.disk_drive.1.to_le_bytes()[0],
                (0x02, 0x81) => self.disk_drive.1.to_le_bytes()[1],
                (0x02, 0x82) => self.mem[addr],
                _ => todo!(),
            }
        } else {
            self.mem[addr]
        }
    }

    fn write_byte(&mut self, addr: u16, value: u8) {
        if self.rb_state
            && (self.rb_window..self.rb_window + 0x100).contains(&addr)
        {
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr, value) {
                (0x01, _, _) => todo!(),
                (0x02, 0x00..=0x7f, _) => self.mem[addr] = value,
                (0x02, 0x80, _) => {
                    let sector = &mut self.disk_drive.1;
                    *sector =
                        u16::from_le_bytes([value, sector.to_le_bytes()[1]])
                }
                (0x02, 0x81, _) => {
                    let sector = &mut self.disk_drive.1;
                    *sector =
                        u16::from_le_bytes([sector.to_le_bytes()[0], value])
                }
                (0x02, 0x82, 0x04) => {
                    let buf = &mut self.mem[self.rb_window..][..0x80];
                    buf.fill(0);
                    let disk = self.disk_drive.0.as_mut();
                    let data = disk.and_then(|disk| {
                        disk.data.get(usize::from(self.disk_drive.1) * 0x80..)
                    });
                    if let Some(data) = data {
                        let data = &data[..0x80.min(data.len())];
                        buf[..data.len()].copy_from_slice(data);
                        self.mem[addr] = 0;
                    } else {
                        self.mem[addr] = 0xff;
                    }
                }
                _ => todo!(),
            }
        } else {
            self.mem[addr] = value;
        }
    }

    fn read_word(&mut self, addr: u16) -> u16 {
        let a = self.read_byte(addr);
        let b = self.read_byte(addr + 1);
        u16::from_le_bytes([a, b])
    }

    fn read_byte_pc(&mut self) -> u8 {
        let r = self.read_byte(self.cpu.pc);
        self.cpu.pc += 1;
        r
    }

    fn read_word_pc(&mut self) -> u16 {
        let a = self.read_byte_pc();
        let b = self.read_byte_pc();
        u16::from_le_bytes([a, b])
    }

    fn zp(&mut self) -> u16 {
        let addr = self.read_byte_pc();
        let a = self.read_byte(u16::from(addr));
        let b = if !self.m() {
            self.read_byte(u16::from(addr) + 1)
        } else {
            0
        };
        u16::from_le_bytes([a, b])
    }

    fn abs(&mut self) -> u16 {
        let addr = self.read_word_pc();
        let a = self.read_byte(addr);
        let b = if !self.m() {
            self.read_byte(addr + 1)
        } else {
            0
        };
        u16::from_le_bytes([a, b])
    }

    fn set_zp(&mut self, value: u16) {
        let zp = self.read_byte_pc();
        self.write_byte(u16::from(zp), value.to_le_bytes()[0]);
        if !self.m() {
            self.write_byte(u16::from(zp) + 1, value.to_le_bytes()[1]);
        }
    }

    fn set_abs(&mut self, value: u16) {
        let addr = self.read_word_pc();
        let [a, b] = value.to_le_bytes();
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
    }

    fn set_ind(&mut self, value: u16) {
        let addr = self.read_byte_pc();
        let addr = self.read_word(addr.into());
        let [a, b] = value.to_le_bytes();
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
    }

    fn cmp(&mut self, value: u16) {
        let diff = self.cpu.a.wrapping_sub(value);
        self.set_n(diff & 0x8000 != 0);
        self.set_z(diff == 0);
        self.set_c(self.cpu.a < value);
    }

    fn branch(&mut self, cond: bool) {
        let offset = i8::from_le_bytes([self.read_byte_pc()]);
        if cond {
            self.cpu.pc = self.cpu.pc.wrapping_add_signed(offset.into());
        }
    }

    fn push_r(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        if !self.m() {
            self.cpu.r -= 1;
            self.write_byte(self.cpu.r, b);
        }
        self.cpu.r -= 1;
        self.write_byte(self.cpu.r, a);
    }

    fn push_s(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        if !self.m() {
            self.cpu.s -= 1;
            self.write_byte(self.cpu.s, b);
        }
        self.cpu.s -= 1;
        self.write_byte(self.cpu.s, a);
    }

    fn pull_s(&mut self) -> u16 {
        let a = if !self.m() {
            let a = self.read_byte(self.cpu.s);
            self.cpu.s += 1;
            a
        } else {
            0
        };
        let b = self.read_byte(self.cpu.s);
        self.cpu.s += 1;
        u16::from_le_bytes([a, b])
    }

    fn lda(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.cpu.a = value;
    }

    fn ldx(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.cpu.x = value;
    }

    fn ldy(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.cpu.y = value;
    }

    fn mmu(&mut self) {
        match self.read_byte_pc() {
            0x00 => self.device_id = self.cpu.a.to_le_bytes()[0],
            0x01 => self.rb_window = self.cpu.a,
            0x02 => self.rb_state = true,
            0x82 => self.rb_state = false,
            0x03 => eprintln!("set mm window: {:#04x}", self.cpu.a),
            0x04 => self.mm_state = true,
            0x84 => self.mm_state = false,
            0x06 => eprintln!("set por: {:#04x}", self.cpu.a),
            _ => todo!(),
        }
    }

    fn zp_do<T>(&mut self, f: fn(&mut u16) -> T) -> T {
        let addr: u16 = self.read_byte_pc().into();
        let mut value = self.read_word(addr);
        let res = f(&mut value);
        let [a, b] = value.to_le_bytes();
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
        res
    }

    pub fn step(&mut self) {
        let debug = true;
        if debug {
            let pc = self.cpu.pc;
            let m = self.m();
            let x = self.x();
            let (instr, size) =
                Decoder { m, x }.decode(&self.mem[pc..]).unwrap();
            eprint!("{pc:04x}: ");
            write_hex(stderr(), &self.mem[pc..][..usize::from(size)], 3);
            eprintln!("| {instr}");
        }

        let op = self.read_byte_pc();
        match op {
            0x02 => {
                self.cpu.pc = self.read_word(self.cpu.i);
                self.cpu.i += 2;
            }
            0x18 => self.set_c(false),
            0x22 => {
                self.push_r(self.cpu.i);
                self.cpu.i = self.cpu.pc + 2;
                self.cpu.pc = self.read_word_pc();
            }
            0x38 => self.set_c(true),
            0x42 => {
                self.cpu.a = self.read_word(self.cpu.i);
                self.cpu.i += 2;
            }
            0x48 => self.push_s(self.cpu.a),
            0x4c => self.cpu.pc = self.read_word_pc(),
            0x5c => self.cpu.i = self.cpu.x,
            0x64 => self.set_zp(0),
            0x85 => self.set_zp(self.cpu.a),
            0x88 => {
                self.cpu.y = self.cpu.y.wrapping_sub(1);
                self.set_flags(self.cpu.y, FLAG_N | FLAG_Z);
            }
            0x8d => self.set_abs(self.cpu.a),
            0x92 => self.set_ind(self.cpu.a),
            0xa0 => {
                let value = self.read_word_pc();
                self.ldy(value)
            }
            0xa2 => {
                let value = self.read_word_pc();
                self.ldx(value)
            }
            0xa5 => {
                let value = self.zp();
                self.lda(value)
            }
            0xa9 => {
                let a = self.read_byte_pc();
                let b = if !self.m() { self.read_byte_pc() } else { 0 };
                self.lda(u16::from_le_bytes([a, b]));
            }
            0xad => {
                let value = self.abs();
                self.lda(value)
            }
            0xc2 => self.cpu.p &= !self.read_byte_pc(),
            0xcb => (),
            0xcd => {
                let value = self.abs();
                self.cmp(value)
            }
            0xd0 => self.branch(!self.z()),
            0xe2 => self.cpu.p |= self.read_byte_pc(),
            0xe6 => self.zp_do(|x| *x = x.wrapping_add(1)),
            0xef => self.mmu(),
            0xf0 => self.branch(self.z()),
            0xfa => self.cpu.x = self.pull_s(),
            0xfb => {
                let mut c = self.c();
                mem::swap(&mut self.cpu.emu, &mut c);
                self.set_c(c);
            }
            0xff => unimplemented!(),
            _ => todo!("{op:#010b}"),
        }
    }
}

fn main() {
    let rom = fs::read(env::args_os().nth(1).unwrap()).unwrap();
    let mut interconnect = Interconnect::new();
    interconnect.disk_drive.0 = Some(Disk::new("System disk", rom));
    loop {
        interconnect.step();
    }
}
