use std::{collections::BTreeMap, fs, path::PathBuf};

use clap::Parser;
use image::{GenericImageView, ImageFormat, Pixel, Rgba};
use minifb::{Key, KeyRepeat, WindowOptions};

use emu65el02::{
    cpu::{Interconnect, RegFile, StepError},
    devices::Disk,
};

const RPCBOOT: &[u8] = include_bytes!("../rpcboot.bin");
const DISPLAY_GUI: &[u8] = include_bytes!("../displaygui.png");

fn blit_bg_x2<I: GenericImageView<Pixel = Rgba<u8>>>(
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
    width: usize,
    x: u32,
    y: u32,
    color: Rgba<u8>,
    image_view: &I,
) {
    for (dx, dy, mut p) in image_view.pixels() {
        p.apply2(&color, |x, y| ((x as u16 * y as u16) >> 8) as u8);
        let i = usize::try_from(y + dy).unwrap() * width
            + usize::try_from(x + dx).unwrap();
        if let Some(b) = buf.get_mut(i) {
            let mut pixel = Rgba(b.to_le_bytes());
            pixel.blend(&p);
            *b = u32::from_le_bytes(pixel.0);
        }
    }
}

const WIDTH: u32 = 350;
const WIDTH_U: usize = WIDTH as usize;
const HEIGHT: u32 = 230;
const HEIGHT_U: usize = HEIGHT as usize;

const BUFFER_WIDTH: usize = WIDTH_U * 2;
const BUFFER_HEIGHT: usize = HEIGHT_U * 2 + 70;

const OFFSET: [u32; 2] = [30, 30];

#[derive(clap::Parser)]
struct Opts {
    #[clap(short, long)]
    debug: bool,
    #[clap(short, long)]
    run_to_disk: bool,
    disk: PathBuf,
    #[clap(short = 'l', long)]
    labels: Option<PathBuf>,
}

fn main() {
    let opts = Opts::parse();

    let debug = opts.debug;
    let run_to_disk = opts.run_to_disk;
    let disk = fs::read(&opts.disk).unwrap();
    let labels: BTreeMap<u16, String> = opts
        .labels
        .as_deref()
        .map(|path| fs::read_to_string(path).unwrap())
        .map(|labels| {
            labels
                .lines()
                .filter(|line| !line.is_empty())
                .map(|line| line.split_once("=$").unwrap())
                .map(|(name, addr)| {
                    (
                        u16::from_str_radix(addr, 16).unwrap(),
                        name.trim().to_string(),
                    )
                })
                .collect()
        })
        .unwrap_or_default();

    let mut interconnect = Interconnect::new(RPCBOOT);
    interconnect.labels = labels;
    interconnect.disk_drive.disk = Some(Disk::new("System disk", disk));

    let texture =
        image::load_from_memory_with_format(DISPLAY_GUI, ImageFormat::Png)
            .unwrap()
            .into_rgba8();
    let bg = texture.view(0, 0, WIDTH, HEIGHT);
    let font = texture.view(WIDTH, 0, 128, 128);
    let mut window = minifb::Window::new(
        "emu65el02",
        BUFFER_WIDTH,
        BUFFER_HEIGHT,
        WindowOptions {
            ..Default::default()
        },
    )
    .unwrap();
    let mut buf = vec![0u32; BUFFER_WIDTH * BUFFER_HEIGHT];
    blit_bg_x2(&mut buf, BUFFER_WIDTH, &*bg);
    window
        .update_with_buffer(&buf, BUFFER_WIDTH, BUFFER_HEIGHT)
        .unwrap();

    let mut running = false;
    if run_to_disk {
        while interconnect.regs.pc != 0x500 {
            match interconnect.step(debug) {
                Ok(()) | Err(StepError::Wai) => (),
                Err(e) => panic!("{e:?}"),
            }
        }
    }
    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {
        let shift = window.is_key_down(Key::LeftShift)
            | window.is_key_down(Key::RightShift);
        let ctrl = window.is_key_down(Key::LeftCtrl)
            | window.is_key_down(Key::RightCtrl);
        for key in window.get_keys_pressed(KeyRepeat::No) {
            let rp_key = match (key, ctrl, shift) {
                (Key::Key1, _, false) => Some(b'1'),
                (Key::Key2, false, false) => Some(b'2'),
                (Key::Key3, false, false) => Some(b'3'),
                (Key::Key4, false, false) => Some(b'4'),
                (Key::Key5, false, false) => Some(b'5'),
                (Key::Key6, false, false) => Some(b'6'),
                (Key::Key7, false, false) => Some(b'7'),
                (Key::Key8, false, false) => Some(b'8'),
                (Key::Key9, false, false) => Some(b'9'),
                (Key::Key0, false, false) => Some(b'0'),

                (Key::Key1, _, true) => Some(b'!'),
                (Key::Key2, false, true) => Some(b'@'),
                (Key::Key3, _, true) => Some(b'#'),
                (Key::Key4, _, true) => Some(b'$'),
                (Key::Key5, _, true) => Some(b'%'),
                (Key::Key6, false, true) => Some(b'^'),
                (Key::Key7, _, true) => Some(b'&'),
                (Key::Key8, _, true) => Some(b'*'),
                (Key::Key9, _, true) => Some(b'('),
                (Key::Key0, _, true) => Some(b')'),

                (Key::Key3, true, false) => Some(b'\x1b'),
                (Key::Key4, true, false) => Some(b'\x1c'),
                (Key::Key5, true, false) => Some(b'\x1d'),
                (Key::Key6, true, _) => Some(b'\x1e'),
                (Key::Key7, true, false) => Some(b'\x1f'),
                (Key::Key8, true, false) => Some(b'\x7f'),

                (Key::A, false, false) => Some(b'a'),
                (Key::B, false, false) => Some(b'b'),
                (Key::C, false, false) => Some(b'c'),
                (Key::D, false, false) => Some(b'd'),
                (Key::E, false, false) => Some(b'e'),
                (Key::F, false, false) => Some(b'f'),
                (Key::G, false, false) => Some(b'g'),
                (Key::H, false, false) => Some(b'h'),
                (Key::I, false, false) => Some(b'i'),
                (Key::J, false, false) => Some(b'j'),
                (Key::K, false, false) => Some(b'k'),
                (Key::L, false, false) => Some(b'l'),
                (Key::M, false, false) => Some(b'm'),
                (Key::N, false, false) => Some(b'n'),
                (Key::O, false, false) => Some(b'o'),
                (Key::P, false, false) => Some(b'p'),
                (Key::Q, false, false) => Some(b'q'),
                (Key::R, false, false) => Some(b'r'),
                (Key::S, false, false) => Some(b's'),
                (Key::T, false, false) => Some(b't'),
                (Key::U, false, false) => Some(b'u'),
                (Key::V, false, false) => Some(b'v'),
                (Key::W, false, false) => Some(b'w'),
                (Key::X, false, false) => Some(b'x'),
                (Key::Y, false, false) => Some(b'y'),
                (Key::Z, false, false) => Some(b'z'),

                (Key::A, false, true) => Some(b'A'),
                (Key::B, false, true) => Some(b'B'),
                (Key::C, false, true) => Some(b'C'),
                (Key::D, false, true) => Some(b'D'),
                (Key::E, false, true) => Some(b'E'),
                (Key::F, false, true) => Some(b'F'),
                (Key::G, false, true) => Some(b'G'),
                (Key::H, false, true) => Some(b'H'),
                (Key::I, false, true) => Some(b'I'),
                (Key::J, false, true) => Some(b'J'),
                (Key::K, false, true) => Some(b'K'),
                (Key::L, false, true) => Some(b'L'),
                (Key::M, false, true) => Some(b'M'),
                (Key::N, false, true) => Some(b'N'),
                (Key::O, false, true) => Some(b'O'),
                (Key::P, false, true) => Some(b'P'),
                (Key::Q, false, true) => Some(b'Q'),
                (Key::R, false, true) => Some(b'R'),
                (Key::S, false, true) => Some(b'S'),
                (Key::T, false, true) => Some(b'T'),
                (Key::U, false, true) => Some(b'U'),
                (Key::V, false, true) => Some(b'V'),
                (Key::W, false, true) => Some(b'W'),
                (Key::X, false, true) => Some(b'X'),
                (Key::Y, false, true) => Some(b'Y'),
                (Key::Z, false, true) => Some(b'Z'),

                (Key::A, true, _) => Some(b'\x01'),
                (Key::B, true, _) => Some(b'\x02'),
                (Key::C, true, _) => Some(b'\x03'),
                (Key::D, true, _) => Some(b'\x04'),
                (Key::E, true, _) => Some(b'\x05'),
                (Key::F, true, _) => Some(b'\x06'),
                (Key::G, true, _) => Some(b'\x07'),
                (Key::H, true, _) => Some(b'\x08'),
                (Key::I, true, _) => Some(b'\x09'),
                (Key::J, true, _) => Some(b'\x0d'),
                (Key::K, true, _) => Some(b'\x0b'),
                (Key::L, true, _) => Some(b'\x0c'),
                (Key::M, true, _) => Some(b'\x0d'),
                (Key::N, true, _) => Some(b'\x0e'),
                (Key::O, true, _) => Some(b'\x0f'),
                (Key::P, true, _) => Some(b'\x10'),
                (Key::Q, true, _) => Some(b'\x11'),
                (Key::R, true, _) => Some(b'\x12'),
                (Key::S, true, _) => Some(b'\x13'),
                (Key::T, true, _) => Some(b'\x14'),
                (Key::U, true, _) => Some(b'\x15'),
                (Key::V, true, _) => Some(b'\x16'),
                (Key::W, true, _) => Some(b'\x17'),
                (Key::X, true, _) => Some(b'\x18'),
                (Key::Y, true, _) => Some(b'\x19'),
                (Key::Z, true, _) => Some(b'\x1a'),

                (Key::Backquote, false, false) => Some(b'`'),
                (Key::Backquote, false, true) => Some(b'~'),
                (Key::Backquote, true, true) => Some(b'\x1e'),

                (Key::Minus, _, false) => Some(b'-'),
                (Key::Minus, false, true) => Some(b'_'),
                (Key::Minus, true, true) => Some(b'\x1f'),
                (Key::Equal, _, false) => Some(b'='),
                (Key::Equal, _, true) => Some(b'+'),

                (Key::Semicolon, _, false) => Some(b';'),
                (Key::Semicolon, _, true) => Some(b':'),
                (Key::Apostrophe, _, false) => Some(b'\''),
                (Key::Apostrophe, _, true) => Some(b'"'),

                (Key::Comma, _, false) => Some(b','),
                (Key::Comma, _, true) => Some(b'<'),
                (Key::Period, _, false) => Some(b'.'),
                (Key::Period, _, true) => Some(b'>'),
                (Key::Slash, false, false) => Some(b'/'),
                (Key::Slash, true, false) => Some(b'\x1f'),
                (Key::Slash, _, true) => Some(b'?'),

                (Key::Backspace, _, _) => Some(b'\x08'),
                (Key::Enter, _, _) => Some(b'\r'),
                (Key::Space, _, _) => Some(b' '),
                (Key::Delete, _, _) => Some(b'\x7f'),

                (Key::Up, false, false) => Some(b'\x80'),
                (Key::Up, true, false) => Some(b'\xa0'),
                (Key::Up, false, true) => Some(b'\xc0'),
                (Key::Up, true, true) => Some(b'\xe0'),

                (Key::Down, false, false) => Some(b'\x81'),
                (Key::Down, true, false) => Some(b'\xa1'),
                (Key::Down, false, true) => Some(b'\xc1'),
                (Key::Down, true, true) => Some(b'\xe1'),

                (Key::Left, false, false) => Some(b'\x82'),
                (Key::Left, true, false) => Some(b'\xa2'),
                (Key::Left, false, true) => Some(b'\xc2'),
                (Key::Left, true, true) => Some(b'\xe2'),

                (Key::Right, false, false) => Some(b'\x83'),
                (Key::Right, true, false) => Some(b'\xa3'),
                (Key::Right, false, true) => Some(b'\xc3'),
                (Key::Right, true, true) => Some(b'\xe3'),

                (Key::Home, false, false) => Some(b'\x84'),
                (Key::Home, true, false) => Some(b'\xa4'),
                (Key::Home, false, true) => Some(b'\xc4'),
                (Key::Home, true, true) => Some(b'\xe4'),

                (Key::End, false, false) => Some(b'\x85'),
                (Key::End, true, false) => Some(b'\xa5'),
                (Key::End, false, true) => Some(b'\xc5'),
                (Key::End, true, true) => Some(b'\xe5'),

                (Key::Insert, false, false) => Some(b'\x86'),
                (Key::Insert, true, false) => Some(b'\xa6'),
                (Key::Insert, false, true) => Some(b'\xc6'),
                (Key::Insert, true, true) => Some(b'\xe6'),

                _ => None,
            };
            if let Some(rp_key) = rp_key {
                interconnect.display.try_push_key(rp_key);
            }
        }
        buf.fill(0);
        blit_bg_x2(&mut buf, BUFFER_WIDTH, &*bg);
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
                    BUFFER_WIDTH,
                    OFFSET[0] + 8 * u32::from(x),
                    OFFSET[1] + 8 * u32::from(y),
                    Rgba([0, 255, 0, 255]),
                    &*glyph,
                );
            }
        }

        let regs = {
            #[rustfmt::skip]
            let RegFile { a, pc, p, emu, s, x, y, r, i, d } = interconnect.regs;
            let e = emu as u8;
            let run = if running { "running" } else { "paused" };
            format!(
                "{run:<8} ENVMXDIZC pc: {pc:#06x} a: {a:#06x} x: {x:#06x} y: {y:#06x}\n  \
                flags: {e}{p:08b}  s: {s:#06x} r: {r:#06x} i: {i:#06x} d: {d:#06x}\n\
                s: [                                                 ]\n\
                r: [                                                 ]"
            )
        };
        for (y, l) in regs.lines().enumerate() {
            for (x, ch) in l.bytes().enumerate() {
                let glyph = font.view(
                    u32::from(ch & 0xf) * 8,
                    u32::from(ch >> 4) * 8,
                    8,
                    8,
                );
                blend_font(
                    &mut buf,
                    BUFFER_WIDTH,
                    8 * u32::try_from(x).unwrap() + 30,
                    HEIGHT * 2 + 8 * u32::try_from(y).unwrap() + 16,
                    Rgba([255; 4]),
                    &*glyph,
                );
            }
        }
        let stack =
            &interconnect.mem()[usize::from(interconnect.regs.s)..][..16];
        for (n, byte) in stack.iter().rev().enumerate() {
            let color = if *byte != 0 {
                Rgba([255; 4])
            } else {
                Rgba([127; 4])
            };
            for (x, ch) in format!("{byte:02x}").bytes().enumerate() {
                let glyph = font.view(
                    u32::from(ch & 0xf) * 8,
                    u32::from(ch >> 4) * 8,
                    8,
                    8,
                );
                blend_font(
                    &mut buf,
                    BUFFER_WIDTH,
                    8 * (3 * u32::try_from(n).unwrap()
                        + u32::try_from(x).unwrap())
                        + 70,
                    HEIGHT * 2 + 32,
                    color,
                    &*glyph,
                );
            }
        }
        let r_stack =
            &interconnect.mem()[usize::from(interconnect.regs.r)..][..16];
        for (n, byte) in r_stack.iter().rev().enumerate() {
            let color = if *byte != 0 {
                Rgba([255; 4])
            } else {
                Rgba([127; 4])
            };
            for (x, ch) in format!("{byte:02x}").bytes().enumerate() {
                let glyph = font.view(
                    u32::from(ch & 0xf) * 8,
                    u32::from(ch >> 4) * 8,
                    8,
                    8,
                );
                blend_font(
                    &mut buf,
                    BUFFER_WIDTH,
                    8 * (3 * u32::try_from(n).unwrap()
                        + u32::try_from(x).unwrap())
                        + 70,
                    HEIGHT * 2 + 40,
                    color,
                    &*glyph,
                );
            }
        }

        window
            .update_with_buffer(&buf, BUFFER_WIDTH, BUFFER_HEIGHT)
            .unwrap();

        if window.is_key_pressed(Key::F9, KeyRepeat::No) {
            running = !running;
        }

        if running {
            for _ in 0..1000 {
                match interconnect.step(debug) {
                    Ok(()) => (),
                    Err(StepError::Wai) => break,
                    Err(e) => panic!("{e:?}"),
                }
            }
        } else if window.is_key_pressed(Key::F11, KeyRepeat::Yes) {
            match interconnect.step(debug) {
                Ok(()) | Err(StepError::Wai) => (),
                Err(e) => panic!("{e:?}"),
            }
        }
    }
}
