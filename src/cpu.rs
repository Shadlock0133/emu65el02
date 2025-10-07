use core::{iter, mem};
use std::{
    collections::BTreeMap,
    io::{stderr, Write},
};

use super::{
    devices::{DiskDrive, Display},
    mem::Mem,
    op, Decoder,
};

trait IntHalves {
    type Half;
    fn lo(&self) -> Self::Half;
    fn hi(&self) -> Self::Half;
    fn set_lo(&mut self, lo: Self::Half);
    fn set_hi(&mut self, hi: Self::Half);
}

impl IntHalves for u16 {
    type Half = u8;
    fn lo(&self) -> u8 {
        self.to_le_bytes()[0]
    }
    fn hi(&self) -> u8 {
        self.to_le_bytes()[1]
    }
    fn set_lo(&mut self, lo: u8) {
        *self = u16::from_le_bytes([lo, self.hi()])
    }
    fn set_hi(&mut self, hi: u8) {
        *self = u16::from_le_bytes([self.lo(), hi])
    }
}

impl IntHalves for u32 {
    type Half = u16;
    fn lo(&self) -> u16 {
        *self as u16
    }
    fn hi(&self) -> u16 {
        (*self >> 16) as u16
    }
    fn set_lo(&mut self, lo: u16) {
        *self = (*self & !0x0000ffff) | u32::from(lo);
    }
    fn set_hi(&mut self, hi: u16) {
        *self = (*self & !0xffff0000) | (u32::from(hi) << 16);
    }
}

const FLAG_C: u8 = 0x01;
const FLAG_Z: u8 = 0x02;
const FLAG_I: u8 = 0x04;
const FLAG_D: u8 = 0x08;
const FLAG_X: u8 = 0x10;
const FLAG_M: u8 = 0x20;
const FLAG_V: u8 = 0x40;
const FLAG_N: u8 = 0x80;

enum Reg {
    A,
    X,
    Y,
    S,
    R,
    I,
    D,
}

#[derive(Default, Debug, Clone, PartialEq)]
pub struct RegFile {
    pub a: u16,
    pub pc: u16,
    pub p: u8,
    pub emu: bool,
    pub s: u16,
    pub x: u16,
    pub y: u16,
    pub r: u16,
    pub i: u16,
    pub d: u16,
}

#[derive(Debug)]
pub enum StepError {
    Wai,
    UD,
}

pub struct Interconnect {
    pub regs: RegFile,
    mem: Mem,
    device_id: u8,
    rb_window: u16,
    rb_state: bool,
    mm_window: u16,
    mm_state: bool,
    pub disk_drive: DiskDrive,
    pub display: Display,
    pub labels: BTreeMap<u16, String>,
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
    ( $( $name:ident : $flag:ident ),* $(,)? ) => {
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

    fn set_nz(&mut self, value: u16) {
        self.set_n(value & 0x8000 != 0);
        self.set_z(value == 0);
    }
}

impl Interconnect {
    pub fn new(boot_rom: &[u8]) -> Self {
        let boot_addr = 0x400;
        Self {
            regs: RegFile {
                a: 0,
                pc: boot_addr,
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
            mem: Mem::new(8, boot_addr, boot_rom),
            disk_drive: Default::default(),
            display: Default::default(),
            labels: BTreeMap::default(),
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
                (0x01, 0x00) => self.display.memory_access_row,
                (0x01, 0x01) => self.display.cursor_x,
                (0x01, 0x02) => self.display.cursor_y,
                (0x01, 0x03) => self.display.cursor_mode,
                (0x01, 0x04) => self.display.key_start,
                (0x01, 0x05) => self.display.key_end,
                // code updates the start pointer
                (0x01, 0x06) => self.display.current_key(),
                (0x01, 0x07) => self.display.blit_status,
                (0x01, 0x08) => self.display.blit_x_start_fill_value,
                (0x01, 0x09) => self.display.blit_y_start,
                (0x01, 0x0a) => self.display.blit_x_offset,
                (0x01, 0x0b) => self.display.blit_y_offset,
                (0x01, 0x0c) => self.display.blit_width,
                (0x01, 0x0d) => self.display.blit_height,
                (0x02, 0x00..0x80) => {
                    self.disk_drive.buffer[usize::from(subaddr)]
                }
                (0x02, 0x80) => self.disk_drive.sector.lo(),
                (0x02, 0x81) => self.disk_drive.sector.hi(),
                (0x02, 0x82) => self.disk_drive.status,
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
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr, value) {
                (0x01, 0x00, _) => self.display.memory_access_row = value,
                (0x01, 0x01, _) => self.display.cursor_x = value,
                (0x01, 0x02, _) => self.display.cursor_y = value,
                (0x01, 0x03, _) => self.display.cursor_mode = value,
                (0x01, 0x04, _) => self.display.key_start = value,
                (0x01, 0x07, 0x01) => self.display.blit_fill(),
                (0x01, 0x08, _) => self.display.blit_x_start_fill_value = value,
                (0x01, 0x09, _) => self.display.blit_y_start = value,
                (0x01, 0x0a, _) => self.display.blit_x_offset = value,
                (0x01, 0x0b, _) => self.display.blit_y_offset = value,
                (0x01, 0x0c, _) => self.display.blit_width = value,
                (0x01, 0x0d, _) => self.display.blit_height = value,
                (0x01, 0x10..=0x60, _) => {
                    let row = self.display.memory_access_row;
                    let i = usize::from(row) * 80 + usize::from(subaddr) - 0x10;
                    self.display.buffer[i] = value;
                }

                (0x02, 0x00..0x80, _) => {
                    self.disk_drive.buffer[usize::from(subaddr)] = value
                }
                (0x02, 0x80, _) => self.disk_drive.sector.set_lo(value),
                (0x02, 0x81, _) => self.disk_drive.sector.set_hi(value),
                (0x02, 0x82, 0x04) => self.disk_drive.read_sector(),

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

    fn zp_x(&mut self) -> u16 {
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

    fn r_s(&mut self) -> u16 {
        let rel = i8::from_le_bytes([self.read_byte_pc()]);
        self.read_word(self.regs.s.wrapping_add_signed(rel.into()))
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

    fn set_abs_x(&mut self, value: u16) {
        let addr = self.read_word_pc() + self.regs.x;
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

    fn reg(&mut self, reg: Reg) -> &mut u16 {
        match reg {
            Reg::A => &mut self.regs.a,
            Reg::X => &mut self.regs.x,
            Reg::Y => &mut self.regs.y,
            Reg::S => &mut self.regs.s,
            Reg::R => &mut self.regs.r,
            Reg::I => &mut self.regs.i,
            Reg::D => &mut self.regs.d,
        }
    }

    fn t(&mut self, from: Reg, to: Reg) {
        let value = *self.reg(from);
        *self.reg(to) = value;
        self.set_nz(value);
    }

    fn cmp(&mut self, reg: Reg, rhs: u16) {
        let lhs = *self.reg(reg);
        let (diff, o) = lhs.overflowing_sub(rhs);
        self.set_nz(diff);
        self.set_c(o);
    }

    fn branch(&mut self, cond: bool) {
        let offset = self.read_byte_pc();
        if cond {
            self.regs.pc = self
                .regs
                .pc
                .wrapping_add_signed(offset.cast_signed().into());
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

    fn rl_nz(&mut self) -> u16 {
        let lo = self.read_byte(self.regs.r);
        self.regs.r += 1;
        let hi = if !self.m() {
            let a = self.read_byte(self.regs.r);
            self.regs.r += 1;
            a
        } else {
            0
        };
        let value = u16::from_le_bytes([lo, hi]);
        self.set_nz(value);
        value
    }

    fn pl_nz(&mut self) -> u16 {
        let lo = self.read_byte(self.regs.s);
        self.regs.s += 1;
        let hi = if !self.m() {
            let v = self.read_byte(self.regs.s);
            self.regs.s += 1;
            v
        } else {
            0
        };
        let value = u16::from_le_bytes([lo, hi]);
        self.set_nz(value);
        value
    }

    fn ld(&mut self, reg: Reg, value: u16) {
        self.set_nz(value);
        *self.reg(reg) = value;
    }

    fn adc(&mut self, rhs: u16) {
        let (res, o) = self.regs.a.overflowing_add(rhs);
        self.regs.a = res;
        self.set_nz(res);
        self.set_v(o);
    }

    fn mul(&mut self, rhs: u16) {
        let (mul, o) = i32::from(self.regs.a).overflowing_mul(rhs.into());
        self.regs.a = mul as u16;
        self.regs.d = (mul >> 16) as u16;
        self.set_nz(self.regs.a);
        self.set_v(o);
    }

    fn div(&mut self, rhs: u16) {
        let lhs = (i32::from(self.regs.d) << 16) | i32::from(self.regs.a);
        let (div, o) = lhs.overflowing_div(i32::from(rhs));
        let (rem, ro) = lhs.overflowing_rem(i32::from(rhs));
        assert_eq!(o, ro);
        self.regs.a = div.cast_unsigned().lo();
        self.regs.d = rem.cast_unsigned().lo();
        self.set_nz(self.regs.a);
        self.set_v(o);
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

    pub fn step(&mut self, debug: bool) -> Result<(), StepError> {
        if debug {
            let pc = self.regs.pc;
            let m = self.m();
            let x = self.x();
            if let Some(label) = self.labels.get(&pc) {
                eprintln!("            {label}:")
            }
            let (instr, size) =
                Decoder { m, x }.decode(&self.mem[pc..]).unwrap();
            eprint!("{pc:04x}: ");
            write_hex(stderr(), &self.mem[pc..][..usize::from(size)], 3);
            eprintln!("| {instr}");
        }

        let op = self.read_byte_pc();
        match op {
            op::BPL => self.branch(!self.n()),
            op::BMI => self.branch(self.n()),
            op::BVC => self.branch(!self.v()),
            op::BVS => self.branch(self.v()),
            op::BRA => self.branch(true),
            op::BCC => self.branch(!self.c()),
            op::BCS => self.branch(self.c()),
            op::BNE => self.branch(!self.z()),
            op::BEQ => self.branch(self.z()),

            op::JMP_ABS => self.regs.pc = self.read_word_pc(),
            op::RTS => self.regs.pc = self.pl_nz() + 1,

            op::NXT => {
                self.regs.pc = self.read_word(self.regs.i);
                self.regs.i += 2;
            }
            op::ENT => {
                self.rh(self.regs.i);
                self.regs.i = self.regs.pc + 2;
                self.regs.pc = self.read_word_pc();
            }
            op::NXA => {
                self.regs.a = self.read_word(self.regs.i);
                self.regs.i += 2;
            }

            op::CLC => self.set_c(false),
            op::SEC => self.set_c(true),
            op::CLI => self.set_i(false),
            op::SEI => self.set_i(true),
            op::CLV => self.set_v(false),
            op::CLD => self.set_d(false),
            op::SED => self.set_d(true),
            op::REP => self.regs.p &= !self.read_byte_pc(),
            op::SEP => self.regs.p |= self.read_byte_pc(),

            op::TXA => self.t(Reg::X, Reg::A),
            op::TAX => self.t(Reg::A, Reg::X),
            op::TYA => self.t(Reg::Y, Reg::A),
            op::TAY => self.t(Reg::A, Reg::Y),
            op::TXS => self.t(Reg::X, Reg::S),
            op::TSX => self.t(Reg::S, Reg::X),
            op::TXR => self.t(Reg::X, Reg::R),
            op::TRX => self.t(Reg::R, Reg::X),
            op::TXY => self.t(Reg::X, Reg::Y),
            op::TYX => self.t(Reg::Y, Reg::X),
            op::TXI => self.t(Reg::X, Reg::I),
            op::TIX => self.t(Reg::I, Reg::X),
            op::TDA => self.t(Reg::D, Reg::A),
            op::TAD => self.t(Reg::A, Reg::D),

            op::PHP => self.ph(self.regs.p.into()),
            op::PHA => self.ph(self.regs.a),
            op::PHY => self.ph(self.regs.y),
            op::PHD => self.ph(self.regs.d),
            op::PHX => self.ph(self.regs.x),
            op::PEA_ABS => {
                let value = self.read_word_pc();
                self.ph(value)
            }
            op::RHA => self.rh(self.regs.a),
            op::RHI => self.rh(self.regs.i),

            op::PLP => self.regs.p = self.pl_nz().lo(),
            op::PLA => self.regs.a = self.pl_nz(),
            op::PLD => self.regs.d = self.pl_nz(),
            op::PLX => self.regs.x = self.pl_nz(),
            op::PLY => self.regs.y = self.pl_nz(),
            op::RLA => self.regs.a = self.rl_nz(),
            op::RLI => self.regs.i = self.rl_nz(),

            op::STZ_ZP => self.set_zp(0),
            op::STA_R_S => self.r_s_do({
                let a = self.regs.a;
                move |x| *x = a
            }),
            op::STA_ZP => self.set_zp(self.regs.a),
            op::STA_ABS => self.set_abs(self.regs.a),
            op::STA_IND => self.set_ind(self.regs.a),
            op::STA_ZP_X => self.set_zpx(self.regs.a),
            op::STA_ABS_X => self.set_abs_x(self.regs.a),

            op::LDA_R_S => {
                let value = self.r_s();
                self.ld(Reg::A, value);
            }
            op::LDA_ZP => {
                let value = self.zp();
                self.ld(Reg::A, value)
            }
            op::LDA_IMM => {
                // todo: don't overwrite high byte in m mode
                let a = self.read_byte_pc();
                let b = if !self.m() { self.read_byte_pc() } else { 0 };
                self.ld(Reg::A, u16::from_le_bytes([a, b]));
            }
            op::LDA_ABS => {
                let value = self.abs();
                self.ld(Reg::A, value)
            }
            op::LDA_ZP_X => {
                let value = self.zp_x();
                self.ld(Reg::A, value)
            }
            op::LDY_IMM => {
                let value = self.read_word_pc();
                self.ld(Reg::Y, value)
            }
            op::LDX_IMM => {
                let value = self.read_word_pc();
                self.ld(Reg::X, value)
            }

            op::INC_A => {
                self.regs.a = self.regs.a.wrapping_add(1);
                self.set_nz(self.regs.a);
            }
            op::INC_ZP => self.zp_do(|x| *x = x.wrapping_add(1)),
            op::INC_ABS => self.abs_do(|x| *x = x.wrapping_add(1)),
            op::INX => {
                self.regs.x = self.regs.x.wrapping_add(1);
                self.set_nz(self.regs.x);
            }
            op::INY => {
                self.regs.y = self.regs.y.wrapping_add(1);
                self.set_nz(self.regs.y);
            }
            op::DEC_A => {
                self.regs.a = self.regs.a.wrapping_sub(1);
                self.set_nz(self.regs.a);
            }
            op::DEX => {
                self.regs.x = self.regs.x.wrapping_sub(1);
                self.set_nz(self.regs.x);
            }
            op::DEY => {
                self.regs.y = self.regs.y.wrapping_sub(1);
                self.set_nz(self.regs.y);
            }

            op::CMP_R_S => {
                let value = self.r_s();
                self.cmp(Reg::A, value)
            }
            op::CMP_ABS => {
                let value = self.abs();
                self.cmp(Reg::A, value)
            }
            op::CMP_ZP_X => {
                let value = self.zp_x();
                self.cmp(Reg::A, value)
            }

            op::ORA_R_S => {
                let value = self.r_s();
                self.regs.a |= value;
                self.set_nz(value);
            }
            op::AND_R_S => {
                let value = self.r_s();
                self.regs.a &= value;
                self.set_nz(value);
            }
            op::EOR_IMM => {
                self.regs.a ^= self.read_word_pc();
                self.set_nz(self.regs.a);
            }
            op::ADC_R_S => {
                let rhs = self.r_s();
                self.adc(rhs);
            }
            op::SBC_R_S => self.regs.a -= self.r_s(),
            op::ROL_A => {
                let new_c;
                if !self.m() {
                    new_c = (self.regs.a >> 15) & 1 != 0;
                    self.regs.a = (self.regs.a << 1) | u16::from(self.c());
                } else {
                    new_c = (self.regs.a >> 7) & 1 != 0;
                    let value = ((self.regs.a.lo()) << 1) | u8::from(self.c());
                    self.regs.a = (self.regs.a & !0xff) | u16::from(value);
                }
                self.set_c(new_c);
                self.set_nz(self.regs.a);
            }
            op::ROR_A => {
                let new_c = self.regs.a & 1 != 0;
                let c = self.c();
                if !self.m() {
                    self.regs.a =
                        (self.regs.a & !0x01 | u16::from(c)).rotate_right(1);
                } else {
                    self.regs.a.set_lo(
                        (self.regs.a.lo() & !0x01 | u8::from(c))
                            .rotate_right(1),
                    );
                }
                self.set_c(new_c);
                self.set_nz(self.regs.a);
            }
            op::MUL_ZP_X => {
                let value = self.zp_x();
                self.mul(value);
            }
            op::DIV_ZP_X => {
                let rhs = self.zp_x();
                self.div(rhs)
            }
            op::ZEA => {
                self.regs.d = 0;
                // todo: check if correct
                if self.m() {
                    self.regs.a.set_hi(0);
                }
            }

            op::XBA => self.regs.a = self.regs.a.swap_bytes(),
            op::XCE => {
                let mut c = self.c();
                mem::swap(&mut self.regs.emu, &mut c);
                self.set_c(c);
            }
            op::WAI => return Err(StepError::Wai),
            op::MMU => self.mmu(),
            op::UD => return Err(StepError::UD),
            _ => todo!("{op:#04x}"),
        }
        Ok(())
    }
}
