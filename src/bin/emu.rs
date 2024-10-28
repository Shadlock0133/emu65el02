mod gdb;

use core::{
    iter, mem,
    ops::{Index, IndexMut, RangeFrom},
};
use std::{
    env,
    fs::{self, File},
    io::{stderr, Write},
    sync::LazyLock,
};

use emu65el02::Decoder;
use image::{GenericImageView, Pixel, Rgba};
use minifb::{Key, KeyRepeat, WindowOptions};

const RPCBOOT: &[u8] = include_bytes!("../../rpcboot.bin");
const FLAG_C: u8 = 0x01;
const FLAG_Z: u8 = 0x02;
const FLAG_I: u8 = 0x04;
const FLAG_D: u8 = 0x08;
const FLAG_X: u8 = 0x10;
const FLAG_M: u8 = 0x20;
const FLAG_V: u8 = 0x40;
const FLAG_N: u8 = 0x80;

#[derive(Default, Debug, Clone, PartialEq)]
pub struct RegFile {
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
struct DiskDrive(Option<Disk>);

#[derive(Debug)]
struct Display {
    key_buffer: [u8; 16],
    key_start: u8,
    key_end: u8,
    buffer: [u8; 80 * 50],
}

impl Default for Display {
    fn default() -> Self {
        Self {
            key_buffer: [0; 16],
            key_start: 0,
            key_end: 0,
            buffer: [b' '; 80 * 50],
        }
    }
}

impl Display {
    pub fn try_push_key(&mut self, value: u8) {
        if (self.key_start + 1) % 16 != self.key_end {
            self.key_buffer[usize::from(self.key_end)] = value;
            self.key_end = (self.key_end + 1) % 16;
        }
    }
}

pub struct Interconnect {
    regs: RegFile,
    mem: Mem,
    device_id: u8,
    rb_window: u16,
    rb_state: bool,
    mm_window: u16,
    mm_state: bool,
    disk_drive: DiskDrive,
    display: Display,
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
                self.regs.p & $flag != 0
            }
            #[allow(unused)]
            fn [<set_ $name>](&mut self, value: bool) {
                if value {
                    self.regs.p |= $flag;
                } else {
                    self.regs.p &= !$flag;
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

    fn r_s(&mut self) -> u16 {
        let rel = i8::from_le_bytes([self.read_byte_pc()]);
        self.read_word(self.regs.s.wrapping_add_signed(rel.into()))
    }

    fn div(&mut self, rhs: u16) {
        let a = self.regs.a.to_le_bytes();
        let d = self.regs.d.to_le_bytes();
        let lhs = i32::from_le_bytes([a[0], a[1], d[0], d[1]]);
        let value = lhs
            .checked_div(i16::from_le_bytes(rhs.to_le_bytes()).into())
            .unwrap_or(0)
            .to_le_bytes();
        self.regs.a = u16::from_le_bytes([value[0], value[1]]);
        self.regs.d = u16::from_le_bytes([value[2], value[3]]);
    }
}

impl Default for Interconnect {
    fn default() -> Self {
        Self {
            regs: RegFile {
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
            display: Default::default(),
        }
    }
}

impl Interconnect {
    fn read_byte(&mut self, addr: u16) -> u8 {
        if self.rb_state
            && (self.rb_window..self.rb_window + 0x100).contains(&addr)
        {
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr) {
                (0x01, 0x00..=0x03) => self.mem[addr],
                (0x01, 0x04) => self.display.key_start,
                (0x01, 0x05) => self.display.key_end,
                (0x01, 0x06) => {
                    self.display.key_buffer[usize::from(self.display.key_start)]
                }
                (0x01, 0x07..=0x0d) => self.mem[addr],
                (0x02, 0x00..=0x82) => self.mem[addr],
                _ => todo!(),
            }
        } else if self.mm_state
            && (self.mm_window..self.mm_window + 0x100).contains(&addr)
        {
            todo!()
        } else {
            self.mem[addr]
        }
    }

    fn write_byte(&mut self, addr: u16, value: u8) {
        if self.rb_state
            && (self.rb_window..self.rb_window + 0x100).contains(&addr)
        {
            static OUT: LazyLock<File> =
                LazyLock::new(|| File::create("output.txt").unwrap());
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr, value) {
                (0x01, 0x00, _) => {
                    let old_value = self.mem[addr];
                    self.mem[addr] = value;
                    if old_value != value {
                        writeln!(&*OUT).unwrap();
                    }
                }
                (0x01, 0x00..=0x04, _) => self.mem[addr] = value,
                (0x01, 0x07, 0x01) => {
                    self.mem[addr] = 1;
                }
                (0x01, 0x07, 0x03) => {
                    self.mem[addr] = 3;
                }
                (0x01, 0x08..=0x0d, _) => self.mem[addr] = value,
                (0x01, 0x10..=0x60, _) => {
                    write!(&*OUT, "{}", value as char).unwrap();
                    let row = self.mem[self.rb_window];
                    let i = usize::from(row) * 80 + usize::from(subaddr) - 0x10;
                    dbg!(row, subaddr, i);
                    self.display.buffer[i] = value;
                }
                (0x02, 0x00..=0x81, _) => self.mem[addr] = value,
                (0x02, 0x82, 0x04) => {
                    let sector = &self.mem[self.rb_window + 0x80..][..2];
                    let sector = u16::from_le_bytes([sector[0], sector[1]]);
                    let buf = &mut self.mem[self.rb_window..][..0x80];
                    buf.fill(0);
                    let disk = self.disk_drive.0.as_mut();
                    let data = disk.and_then(|disk| {
                        disk.data.get(usize::from(sector) * 0x80..)
                    });
                    if let Some(data) = data {
                        let data = &data[..0x80.min(data.len())];
                        buf[..data.len()].copy_from_slice(data);
                        self.mem[addr] = 0;
                    } else {
                        self.mem[addr] = 0xff;
                    }
                }
                _ => todo!(
                    "device {:#04x}: write {subaddr:#04x}",
                    self.device_id
                ),
            }
        } else if self.mm_state
            && (self.mm_window..self.mm_window + 0x100).contains(&addr)
        {
            todo!()
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
        let r = self.read_byte(self.regs.pc);
        self.regs.pc += 1;
        r
    }

    fn read_word_pc(&mut self) -> u16 {
        let a = self.read_byte_pc();
        let b = self.read_byte_pc();
        u16::from_le_bytes([a, b])
    }

    fn zp(&mut self) -> u16 {
        let addr = u16::from(self.read_byte_pc());
        let a = self.read_byte(addr);
        let b = if !self.m() {
            self.read_byte(addr + 1)
        } else {
            0
        };
        u16::from_le_bytes([a, b])
    }

    fn zpx(&mut self) -> u16 {
        let addr = u16::from(self.read_byte_pc()) + self.regs.x;
        let a = self.read_byte(addr);
        let b = if !self.m() {
            self.read_byte(addr + 1)
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
        let [a, b] = value.to_le_bytes();
        let addr = u16::from(self.read_byte_pc());
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
    }

    fn set_zpx(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        let addr = u16::from(self.read_byte_pc()) + self.regs.x;
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
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
        let diff = self.regs.a.wrapping_sub(value);
        self.set_n(diff & 0x8000 != 0);
        self.set_z(diff == 0);
        self.set_c(self.regs.a < value);
    }

    fn branch(&mut self, cond: bool) {
        let offset = i8::from_le_bytes([self.read_byte_pc()]);
        if cond {
            self.regs.pc = self.regs.pc.wrapping_add_signed(offset.into());
        }
    }

    fn rh(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        if !self.m() {
            self.regs.r -= 1;
            self.write_byte(self.regs.r, b);
        }
        self.regs.r -= 1;
        self.write_byte(self.regs.r, a);
    }

    fn ph(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        if !self.m() {
            self.regs.s -= 1;
            self.write_byte(self.regs.s, b);
        }
        self.regs.s -= 1;
        self.write_byte(self.regs.s, a);
    }

    fn rl(&mut self) -> u16 {
        let a = if !self.m() {
            let a = self.read_byte(self.regs.r);
            self.regs.r += 1;
            a
        } else {
            0
        };
        let b = self.read_byte(self.regs.r);
        self.regs.r += 1;
        u16::from_le_bytes([a, b])
    }

    fn pl(&mut self) -> u16 {
        let a = if !self.m() {
            let a = self.read_byte(self.regs.s);
            self.regs.s += 1;
            a
        } else {
            0
        };
        let b = self.read_byte(self.regs.s);
        self.regs.s += 1;
        u16::from_le_bytes([a, b])
    }

    fn lda(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.regs.a = value;
    }

    fn ldx(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.regs.x = value;
    }

    fn ldy(&mut self, value: u16) {
        self.set_n(value & 0x80 != 0);
        self.set_z(value == 0);
        self.regs.y = value;
    }

    fn mmu(&mut self) {
        match self.read_byte_pc() {
            0x00 => self.device_id = self.regs.a.to_le_bytes()[0],
            0x01 => self.rb_window = self.regs.a,
            0x02 => self.rb_state = true,
            0x82 => self.rb_state = false,
            0x03 => self.mm_window = self.regs.a,
            0x04 => self.mm_state = true,
            0x84 => self.mm_state = false,
            0x06 => eprintln!("set por: {:#04x}", self.regs.a),
            _ => todo!(),
        }
    }

    fn abs_do<T>(&mut self, f: fn(&mut u16) -> T) -> T {
        let addr: u16 = self.read_word_pc();
        let mut value = self.read_word(addr);
        let res = f(&mut value);
        let [a, b] = value.to_le_bytes();
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
        res
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
    fn zpx_do<T>(&mut self, f: impl Fn(&mut u16) -> T) -> T {
        let addr = u16::from(self.read_byte_pc()) + self.regs.x;
        let a = self.read_byte(addr);
        let b = if !self.m() {
            self.read_byte(addr + 1)
        } else {
            0
        };
        let mut value = u16::from_le_bytes([a, b]);
        let res = f(&mut value);
        let [a, b] = value.to_le_bytes();
        self.write_byte(addr, a);
        if !self.m() {
            self.write_byte(addr + 1, b);
        }
        res
    }
    fn r_s_do<T>(&mut self, f: impl Fn(&mut u16) -> T) -> T {
        let addr = u16::from(self.read_byte_pc()) + self.regs.s;
        let a = self.read_byte(addr);
        let b = if !self.m() {
            self.read_byte(addr + 1)
        } else {
            0
        };
        let mut value = u16::from_le_bytes([a, b]);
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
            let pc = self.regs.pc;
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
                self.regs.pc = self.read_word(self.regs.i);
                self.regs.i += 2;
            }
            0x18 => self.set_c(false),
            0x1a => self.regs.a += 1,
            0x22 => {
                self.rh(self.regs.i);
                self.regs.i = self.regs.pc + 2;
                self.regs.pc = self.read_word_pc();
            }
            0x2a => self.regs.a = self.regs.a.rotate_left(1),
            0x2b => self.regs.i = self.rl(),
            0x30 => self.branch(self.n()),
            0x38 => self.set_c(true),
            0x3a => self.regs.a -= 1,
            0x42 => {
                self.regs.a = self.read_word(self.regs.i);
                self.regs.i += 2;
            }
            0x48 => self.ph(self.regs.a),
            0x4b => self.rh(self.regs.a),
            0x4c => self.regs.pc = self.read_word_pc(),
            0x49 => self.regs.a ^= self.read_word_pc(),
            0x5a => self.ph(self.regs.y),
            0x5c => self.regs.i = self.regs.x,
            0x5f => {
                let rhs = self.zpx();
                self.div(rhs)
            }
            0x60 => self.regs.pc = self.pl() + 1,
            0x63 => self.regs.a += self.r_s(),
            0x64 => self.set_zp(0),
            0x68 => self.regs.a = self.pl(),
            0x6a => self.regs.a = self.regs.a.rotate_right(1),
            0x6b => self.regs.a = self.rl(),
            0x7a => self.regs.y = self.pl(),
            0x80 => self.branch(true),
            0x83 => self.r_s_do({
                let a = self.regs.a;
                move |x| *x = a
            }),
            0x85 => self.set_zp(self.regs.a),
            0x88 => {
                self.regs.y = self.regs.y.wrapping_sub(1);
                self.set_flags(self.regs.y, FLAG_N | FLAG_Z);
            }
            0x8b => self.regs.r = self.regs.x,
            0x8d => self.set_abs(self.regs.a),
            0x8f => {
                self.regs.d = 0;
                if !self.m() {
                    self.regs.a &= 0xff;
                }
            }
            0x92 => self.set_ind(self.regs.a),
            0x95 => self.set_zpx(self.regs.a),
            0x9a => self.regs.s = self.regs.x,
            0xa0 => {
                let value = self.read_word_pc();
                self.ldy(value)
            }
            0xa2 => {
                let value = self.read_word_pc();
                self.ldx(value)
            }
            0xa3 => self.regs.a = self.r_s(),
            0xa5 => {
                let value = self.zp();
                self.lda(value)
            }
            0xa9 => {
                let a = self.read_byte_pc();
                let b = if !self.m() { self.read_byte_pc() } else { 0 };
                self.lda(u16::from_le_bytes([a, b]));
            }
            0xaa => self.regs.x = self.regs.a,
            0xad => {
                let value = self.abs();
                self.lda(value)
            }
            0xb5 => {
                let value = self.zpx();
                self.lda(value)
            }
            0xba => self.regs.x = self.regs.s,
            0xc2 => self.regs.p &= !self.read_byte_pc(),
            0xc3 => {
                let value = self.r_s();
                self.cmp(value)
            }
            0xcb => (), // wai
            0xcd => {
                let value = self.abs();
                self.cmp(value)
            }
            0xcf => self.regs.d = self.pl(),
            0xd0 => self.branch(!self.z()),
            0xda => self.ph(self.regs.x),
            0xdc => self.regs.x = self.regs.i,
            0xdf => self.ph(self.regs.d),
            0xe2 => self.regs.p |= self.read_byte_pc(),
            0xe3 => self.regs.a -= self.r_s(),
            0xe6 => self.zp_do(|x| *x = x.wrapping_add(1)),
            0xee => self.abs_do(|x| *x = x.wrapping_add(1)),
            0xef => self.mmu(),
            0xf0 => self.branch(self.z()),
            0xf4 => {
                let value = self.read_word_pc();
                self.ph(value)
            }
            0xfa => self.regs.x = self.pl(),
            0xfb => {
                let mut c = self.c();
                mem::swap(&mut self.regs.emu, &mut c);
                self.set_c(c);
            }
            0xff => unimplemented!(),
            _ => todo!("{op:#010b}"),
        }
    }
}

fn paste_bg_x2<I: GenericImageView<Pixel = Rgba<u8>>>(
    buf: &mut [u32],
    width: usize,
    image_view: &I,
) {
    for (x, y, p) in image_view.pixels() {
        let i = usize::try_from(y * u32::try_from(width).unwrap() + x).unwrap();
        let mut color = Rgba(buf[i * 2].to_le_bytes());
        color.blend(&p);
        buf[i * 2] = u32::from_le_bytes(color.0);
        buf[i * 2 + 1] = u32::from_le_bytes(color.0);
        buf[i * 2 + width] = u32::from_le_bytes(color.0);
        buf[i * 2 + width + 1] = u32::from_le_bytes(color.0);
    }
}

fn blend_font<I: GenericImageView<Pixel = Rgba<u8>>>(
    buf: &mut [u32],
    width: u32,
    x: u32,
    y: u32,
    image_view: &I,
) {
    for (dx, dy, mut p) in image_view.pixels() {
        p.0[0] = 0;
        p.0[2] = 0;
        let i = usize::try_from((y + dy) * width + (x + dx)).unwrap();
        if let Some(b) = buf.get_mut(i) {
            let mut color = Rgba(b.to_le_bytes());
            color.blend(&p);
            *b = u32::from_le_bytes(color.0);
        }
    }
}

const WIDTH: u32 = 350;
const WIDTH_U: usize = 350;
const HEIGHT: u32 = 230;
const HEIGHT_U: usize = 230;

const OFFSET: [u32; 2] = [30, 30];

fn main() {
    let rom = fs::read(env::args_os().nth(1).unwrap()).unwrap();

    let mut interconnect = Interconnect::default();
    interconnect.disk_drive.0 = Some(Disk::new("System disk", rom));

    let texture = image::open("displaygui.png").unwrap().into_rgba8();
    let bg = texture.view(0, 0, WIDTH, HEIGHT);
    let font = texture.view(WIDTH, 0, 128, 128);
    let mut window = minifb::Window::new(
        "emu65el02",
        WIDTH_U * 2,
        HEIGHT_U * 2,
        WindowOptions {
            ..Default::default()
        },
    )
    .unwrap();
    let mut buf = vec![0u32; WIDTH_U * 2 * HEIGHT_U * 2];
    paste_bg_x2(&mut buf, WIDTH_U * 2, &*bg);
    window
        .update_with_buffer(&buf, WIDTH_U * 2, HEIGHT_U * 2)
        .unwrap();

    let mut running = false;
    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {
        for key in window.get_keys() {
            interconnect.display.try_push_key(key as u8);
        }
        paste_bg_x2(&mut buf, WIDTH_U * 2, &*bg);
        for y in 0..50u8 {
            for x in 0..80u8 {
                let i = usize::from(y) * 80 + usize::from(x);
                let ch = interconnect.display.buffer[i];
                let glyph = font.view(
                    u32::from(ch & 0xf) * 8,
                    u32::from(ch >> 4) * 8,
                    8,
                    8,
                );
                blend_font(
                    &mut buf,
                    WIDTH * 2,
                    OFFSET[0] + 8 * u32::from(x),
                    OFFSET[1] + 8 * u32::from(y),
                    &*glyph,
                );
            }
        }
        window
            .update_with_buffer(&buf, WIDTH_U * 2, HEIGHT_U * 2)
            .unwrap();

        if window.is_key_pressed(Key::F9, KeyRepeat::No) {
            running = !running;
        }

        if running {
            for _ in 0..1000 {
                interconnect.step();
            }
        } else if window.is_key_pressed(Key::F11, KeyRepeat::Yes) {
            interconnect.step();
        }
    }
}
