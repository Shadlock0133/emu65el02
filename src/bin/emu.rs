use std::{collections::BTreeMap, env, fs};

use emu65el02::cpu::{self, Disk, Interconnect, RegFile};
use image::{GenericImageView, Pixel, Rgba};
use minifb::{Key, KeyRepeat, WindowOptions};

const RPCBOOT: &[u8] = include_bytes!("../../rpcboot.bin");

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
    image_view: &I,
) {
    for (dx, dy, mut p) in image_view.pixels() {
        // blend to green
        p.0[0] = 0;
        p.0[2] = 0;
        let i = usize::try_from(y + dy).unwrap() * width
            + usize::try_from(x + dx).unwrap();
        if let Some(b) = buf.get_mut(i) {
            let mut color = Rgba(b.to_le_bytes());
            color.blend(&p);
            *b = u32::from_le_bytes(color.0);
        }
    }
}

const WIDTH: u32 = 350;
const WIDTH_U: usize = WIDTH as usize;
const HEIGHT: u32 = 230;
const HEIGHT_U: usize = HEIGHT as usize;

const BUFFER_WIDTH: usize = WIDTH_U * 2;
const BUFFER_HEIGHT: usize = HEIGHT_U * 2 + 50;

const OFFSET: [u32; 2] = [30, 30];

fn main() {
    let debug = env::args_os().any(|x| x == "--debug" || x == "-d");
    let run_to_disk = env::args_os().any(|x| x == "--run-to-disk" || x == "-r");
    let mut args = env::args_os()
        .skip(1)
        .filter(|x| !x.to_string_lossy().starts_with("-"));
    let disk = fs::read(args.next().expect("Missing file")).unwrap();
    let labels: BTreeMap<u16, String> = args
        .next()
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
    interconnect.disk_drive.0 = Some(Disk::new("System disk", disk));

    let texture = image::open("displaygui.png").unwrap().into_rgba8();
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
            let _ = interconnect.step(debug);
        }
    }
    while window.is_open() && !window.is_key_down(minifb::Key::Escape) {
        let shift = window.is_key_down(Key::LeftShift)
            | window.is_key_down(Key::RightShift);
        for key in window.get_keys_pressed(KeyRepeat::No) {
            let rp_key = match (key, shift) {
                (Key::Key0, false) => Some(b'0'),
                (Key::Key1, false) => Some(b'1'),
                (Key::Key2, false) => Some(b'2'),
                (Key::Key3, false) => Some(b'3'),
                (Key::Key4, false) => Some(b'4'),
                (Key::Key5, false) => Some(b'5'),
                (Key::Key6, false) => Some(b'6'),
                (Key::Key7, false) => Some(b'7'),
                (Key::Key8, false) => Some(b'8'),
                (Key::Key9, false) => Some(b'9'),

                (Key::A, false) => Some(b'a'),
                (Key::B, false) => Some(b'b'),
                (Key::C, false) => Some(b'c'),
                (Key::D, false) => Some(b'd'),
                (Key::E, false) => Some(b'e'),
                (Key::F, false) => Some(b'f'),
                (Key::G, false) => Some(b'g'),
                (Key::H, false) => Some(b'h'),
                (Key::I, false) => Some(b'i'),
                (Key::J, false) => Some(b'j'),
                (Key::K, false) => Some(b'k'),
                (Key::L, false) => Some(b'l'),
                (Key::M, false) => Some(b'm'),
                (Key::N, false) => Some(b'n'),
                (Key::O, false) => Some(b'o'),
                (Key::P, false) => Some(b'p'),
                (Key::Q, false) => Some(b'q'),
                (Key::R, false) => Some(b'r'),
                (Key::S, false) => Some(b's'),
                (Key::T, false) => Some(b't'),
                (Key::U, false) => Some(b'u'),
                (Key::V, false) => Some(b'v'),
                (Key::W, false) => Some(b'w'),
                (Key::X, false) => Some(b'x'),
                (Key::Y, false) => Some(b'y'),
                (Key::Z, false) => Some(b'z'),

                (Key::A, true) => Some(b'A'),
                (Key::B, true) => Some(b'B'),
                (Key::C, true) => Some(b'C'),
                (Key::D, true) => Some(b'D'),
                (Key::E, true) => Some(b'E'),
                (Key::F, true) => Some(b'F'),
                (Key::G, true) => Some(b'G'),
                (Key::H, true) => Some(b'H'),
                (Key::I, true) => Some(b'I'),
                (Key::J, true) => Some(b'J'),
                (Key::K, true) => Some(b'K'),
                (Key::L, true) => Some(b'L'),
                (Key::M, true) => Some(b'M'),
                (Key::N, true) => Some(b'N'),
                (Key::O, true) => Some(b'O'),
                (Key::P, true) => Some(b'P'),
                (Key::Q, true) => Some(b'Q'),
                (Key::R, true) => Some(b'R'),
                (Key::S, true) => Some(b'S'),
                (Key::T, true) => Some(b'T'),
                (Key::U, true) => Some(b'U'),
                (Key::V, true) => Some(b'V'),
                (Key::W, true) => Some(b'W'),
                (Key::X, true) => Some(b'X'),
                (Key::Y, true) => Some(b'Y'),
                (Key::Z, true) => Some(b'Z'),

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
                flags: {e}{p:08b}  s: {s:#06x} r: {r:#06x} i: {i:#06x} d: {d:#06x}"
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
                    30 + 8 * u32::try_from(x).unwrap(),
                    HEIGHT * 2 + 16 + 8 * u32::try_from(y).unwrap(),
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
                if let Err(cpu::Wai) = interconnect.step(debug) {
                    break;
                }
            }
        } else if window.is_key_pressed(Key::F11, KeyRepeat::Yes) {
            let _ = interconnect.step(debug);
        }
    }
}
