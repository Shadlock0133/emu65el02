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

struct Interconnect {
    cpu: Cpu,
    mem: Mem,
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
            mem: Mem::new(8),
        }
    }

    fn read_word(&mut self, addr: u16) -> u16 {
        let a = self.mem[addr];
        let b = self.mem[addr + 1];
        u16::from_le_bytes([a, b])
    }

    fn read_byte_pc(&mut self) -> u8 {
        let r = self.mem[self.cpu.pc];
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
        let a = self.mem[u16::from(addr)];
        let b = if !self.m() {
            self.mem[u16::from(addr) + 1]
        } else {
            0
        };
        u16::from_le_bytes([a, b])
    }

    fn abs(&mut self) -> u16 {
        let addr = self.read_word_pc();
        let a = self.mem[addr];
        let b = if !self.m() { self.mem[addr + 1] } else { 0 };
        u16::from_le_bytes([a, b])
    }

    fn set_zp(&mut self, value: u16) {
        let zp = self.read_byte_pc();
        self.mem[u16::from(zp)] = value.to_le_bytes()[0];
        if !self.m() {
            self.mem[u16::from(zp) + 1] = value.to_le_bytes()[1];
        }
    }

    fn set_abs(&mut self, value: u16) {
        let addr = self.read_word_pc();
        self.mem[addr] = value.to_le_bytes()[0];
        if !self.m() {
            self.mem[addr + 1] = value.to_le_bytes()[1];
        }
    }

    fn cmp(&mut self, value: u16) {
        let diff = self.cpu.a.wrapping_sub(value);
        // self.set_z(diff == 0);
        // self.set_n(diff & 0x8000 != 0);
    }

    fn branch(&mut self, cond: bool) {
        let offset = i8::from_le_bytes([self.read_byte_pc()]);
        if cond {
            self.cpu.pc = self.cpu.pc.wrapping_add_signed(offset.into());
        }
    }

    fn push_r(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        self.cpu.r -= 1;
        self.mem[self.cpu.r] = b;
        self.cpu.r -= 1;
        self.mem[self.cpu.r] = a;
    }

    fn push_s(&mut self, value: u16) {
        let [a, b] = value.to_le_bytes();
        self.cpu.s -= 1;
        self.mem[self.cpu.s] = b;
        self.cpu.s -= 1;
        self.mem[self.cpu.s] = a;
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
            0x64 => self.set_zp(0),
            0x85 => self.set_zp(self.cpu.a),
            0x8d => self.set_abs(self.cpu.a),
            0xa5 => self.cpu.a = self.zp(),
            0xa9 => {
                let a = self.read_byte_pc();
                let b = if !self.m() { self.read_byte_pc() } else { 0 };
                self.cpu.a = u16::from_le_bytes([a, b]);
            }
            0xad => self.cpu.a = self.abs(),
            0xc2 => self.cpu.p &= !self.read_byte_pc(),
            0xcb => (),
            0xcd => {
                let value = self.abs();
                self.cmp(value)
            }
            0xe2 => self.cpu.p |= self.read_byte_pc(),
            0xef => match self.read_byte_pc() {
                0x00 => eprintln!("set device id: {}", self.cpu.a),
                0x01 => eprintln!("set rb window: {:#04x}", self.cpu.a),
                0x02 => eprintln!("enable redbus"),
                0x82 => eprintln!("disable redbus"),
                0x03 => eprintln!("set mm window: {:#04x}", self.cpu.a),
                0x04 => eprintln!("enable mm window"),
                0x84 => eprintln!("enable mm window"),
                0x06 => eprintln!("set por: {:#04x}", self.cpu.a),
                _ => todo!(),
            },
            0xf0 => self.branch(self.z()),
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
    interconnect.mem.mem[0x500..][..rom.len()].copy_from_slice(&rom);
    loop {
        interconnect.step();
    }
}
