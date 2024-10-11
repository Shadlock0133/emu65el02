use std::{env, fs, iter, num::ParseIntError};

use emu65el02::{Arguments, Decoder};

fn parse_number(s: &str) -> Result<usize, ParseIntError> {
    if let Some(hex) = s.strip_prefix("0x") {
        usize::from_str_radix(hex, 16)
    } else {
        s.parse()
    }
}

fn print_hex(data: &[u8], width: usize) {
    for x in data
        .iter()
        .map(Some)
        .chain(iter::repeat(None))
        .take(width)
    {
        match x {
            Some(x) => print!("{x:02x} "),
            None => print!("   "),
        }
    }
}

fn main() {
    let rom = fs::read(env::args_os().nth(1).unwrap()).unwrap();
    let offset = env::args()
        .nth(2)
        .map(|s| parse_number(&s).unwrap())
        .unwrap_or(0);
    let start = env::args()
        .nth(3)
        .map(|s| parse_number(&s).unwrap())
        .unwrap_or(offset);
    let end = env::args()
        .nth(4)
        .map(|s| parse_number(&s).unwrap())
        .unwrap_or(rom.len());
    let mut addr = start - offset;
    eprintln!("file offset: {addr:#x}");
    let mut decoder = Decoder::default();
    while !rom[addr..end].is_empty() {
        let data = &rom[addr..];
        print!("{:04x}: ", addr + offset);
        let Ok((instr, size)) = decoder.decode(data) else {
            print_hex(&data[..1], 3);
            println!("| !unknown");
            addr += 1;
            continue;
        };
        let size: usize = size.into();
        print_hex(&data[..size], 3);
        addr += size;
        print!("| ");
        match instr.argument {
            Some(Arguments::Rel(rel)) => {
                print!(
                    "{} {:04x}",
                    instr.opcode,
                    addr.wrapping_add_signed(rel.into())
                )
            }
            _ => print!("{instr}"),
        }
        println!();
    }
}
