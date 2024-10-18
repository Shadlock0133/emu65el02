use core::mem;
use std::{
    env, fs,
    io::{stderr, Write},
    iter,
    ops::{Index, IndexMut, RangeFrom},
};

use emu65el02::Decoder;
use image::{GenericImageView, Pixel, Rgba};
use minifb::WindowOptions;

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
struct DiskDrive(Option<Disk>);

#[derive(Default, Debug)]
struct Display {
    cursor: (u8, u8),
    mode: u8,
    blit_start: (u8, u8),
    blit_offset: (u8, u8),
    blit_size: (u8, u8),
}

struct Interconnect {
    cpu: Cpu,
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

    fn r_s(&mut self) -> u16 {
        let rel = i8::from_le_bytes([self.read_byte_pc()]);
        self.read_word(self.cpu.s.wrapping_add_signed(rel.into()))
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
            display: Default::default(),
        }
    }

    fn read_byte(&mut self, addr: u16) -> u8 {
        if self.rb_state
            && (self.rb_window..self.rb_window + 0x100).contains(&addr)
        {
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr) {
                (0x01, 0x01) => self.display.cursor.0,
                (0x01, 0x02) => self.display.cursor.1,
                (0x01, 0x03) => self.display.mode,
                (0x01, 0x07) => self.mem[addr],
                (0x01, 0x08) => self.display.blit_start.0,
                (0x01, 0x09) => self.display.blit_start.1,
                (0x01, 0x0a) => self.display.blit_offset.0,
                (0x01, 0x0b) => self.display.blit_offset.1,
                (0x01, 0x0c) => self.display.blit_size.0,
                (0x01, 0x0d) => self.display.blit_size.1,
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
            let subaddr = addr - self.rb_window;
            match (self.device_id, subaddr, value) {
                (0x01, 0x00, _) => self.mem[addr] = value,
                (0x01, 0x01, _) => self.display.cursor.0 = value,
                (0x01, 0x02, _) => self.display.cursor.1 = value,
                (0x01, 0x03, _) => self.display.mode = value,
                (0x01, 0x07, _) => {
                    self.mem[addr] = 1;
                }
                (0x01, 0x08, _) => self.display.blit_start.0 = value,
                (0x01, 0x09, _) => self.display.blit_start.1 = value,
                (0x01, 0x0a, _) => self.display.blit_offset.0 = value,
                (0x01, 0x0b, _) => self.display.blit_offset.1 = value,
                (0x01, 0x0c, _) => self.display.blit_size.0 = value,
                (0x01, 0x0d, _) => self.display.blit_size.1 = value,
                (0x01, 0x10..=0x60, _) => {
                    print!("{}", char::from(value));
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
        let addr = u16::from(self.read_byte_pc()) + self.cpu.x;
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
        let addr = u16::from(self.read_byte_pc()) + self.cpu.x;
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

    fn pull_r(&mut self) -> u16 {
        let a = if !self.m() {
            let a = self.read_byte(self.cpu.r);
            self.cpu.r += 1;
            a
        } else {
            0
        };
        let b = self.read_byte(self.cpu.r);
        self.cpu.r += 1;
        u16::from_le_bytes([a, b])
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
            0x03 => self.mm_window = self.cpu.a,
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
    fn zpx_do<T>(&mut self, f: impl Fn(&mut u16) -> T) -> T {
        let addr = u16::from(self.read_byte_pc()) + self.cpu.x;
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
        let addr = u16::from(self.read_byte_pc()) + self.cpu.s;
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
            0x1a => self.cpu.a += 1,
            0x22 => {
                self.push_r(self.cpu.i);
                self.cpu.i = self.cpu.pc + 2;
                self.cpu.pc = self.read_word_pc();
            }
            0x2b => self.cpu.i = self.pull_r(),
            0x30 => self.branch(self.n()),
            0x38 => self.set_c(true),
            0x3a => self.cpu.a -= 1,
            0x42 => {
                self.cpu.a = self.read_word(self.cpu.i);
                self.cpu.i += 2;
            }
            0x48 => self.push_s(self.cpu.a),
            0x4b => self.push_r(self.cpu.a),
            0x4c => self.cpu.pc = self.read_word_pc(),
            0x49 => self.cpu.a ^= self.read_word_pc(),
            0x5c => self.cpu.i = self.cpu.x,
            0x63 => self.cpu.a += self.r_s(),
            0x64 => self.set_zp(0),
            0x68 => self.cpu.a = self.pull_s(),
            0x6b => self.cpu.a = self.pull_r(),
            0x83 => self.r_s_do({
                let a = self.cpu.a;
                move |x| *x = a
            }),
            0x85 => self.set_zp(self.cpu.a),
            0x88 => {
                self.cpu.y = self.cpu.y.wrapping_sub(1);
                self.set_flags(self.cpu.y, FLAG_N | FLAG_Z);
            }
            0x8d => self.set_abs(self.cpu.a),
            0x8f => {
                self.cpu.d = 0;
                if !self.m() {
                    self.cpu.a &= 0xff;
                }
            }
            0x92 => self.set_ind(self.cpu.a),
            0x95 => self.set_zpx(self.cpu.a),
            0xa0 => {
                let value = self.read_word_pc();
                self.ldy(value)
            }
            0xa2 => {
                let value = self.read_word_pc();
                self.ldx(value)
            }
            0xa3 => self.cpu.a = self.r_s(),
            0xa5 => {
                let value = self.zp();
                self.lda(value)
            }
            0xa9 => {
                let a = self.read_byte_pc();
                let b = if !self.m() { self.read_byte_pc() } else { 0 };
                self.lda(u16::from_le_bytes([a, b]));
            }
            0xaa => self.cpu.x = self.cpu.a,
            0xad => {
                let value = self.abs();
                self.lda(value)
            }
            0xb5 => {
                let value = self.zpx();
                self.lda(value)
            }
            0xba => self.cpu.x = self.cpu.s,
            0xc2 => self.cpu.p &= !self.read_byte_pc(),
            0xc3 => {
                let value = self.r_s();
                self.cmp(value)
            }
            0xcb => (), // wai
            0xcd => {
                let value = self.abs();
                self.cmp(value)
            }
            0xcf => self.cpu.d = self.pull_s(),
            0xd0 => self.branch(!self.z()),
            0xda => self.push_s(self.cpu.x),
            0xdc => self.cpu.x = self.cpu.i,
            0xe2 => self.cpu.p |= self.read_byte_pc(),
            0xe3 => self.cpu.a -= self.r_s(),
            0xe6 => self.zp_do(|x| *x = x.wrapping_add(1)),
            0xef => self.mmu(),
            0xf0 => self.branch(self.z()),
            0xf4 => {
                let value = self.read_word_pc();
                self.push_s(value)
            }
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
    let mut interconnect = Interconnect::new();
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
    // let ch = font.view(0, 24, 8, 8);
    // for y in 0..50 {
    //     blend_font(&mut buf, WIDTH * 2, OFFSET[0], OFFSET[1] + 8 * y, &*ch);
    // }
    // for x in 0..80 {
    //     blend_font(&mut buf, WIDTH * 2, OFFSET[0] + 8 * x, OFFSET[1], &*ch);
    // }
    window
        .update_with_buffer(&buf, WIDTH_U * 2, HEIGHT_U * 2)
        .unwrap();
    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {
        paste_bg_x2(&mut buf, WIDTH_U * 2, &*bg);
        window
            .update_with_buffer(&buf, WIDTH_U * 2, HEIGHT_U * 2)
            .unwrap();
        for _ in 0..1000 {
            // if interconnect.cpu.pc == 0xec7 {
            //     static COUNT: AtomicU8 = AtomicU8::new(0);
            //     if COUNT.fetch_add(1, Ordering::AcqRel) >= 1 {
            //         panic!("CR")
            //     }
            // }

            if interconnect.cpu.pc == 0x1829 {
                panic!("QUIT")
            }

            interconnect.step();
        }
    }
}
