use std::{
    borrow::Cow,
    collections::{BTreeMap, HashMap},
    env,
    ffi::CStr,
    fs,
};

use emu65el02::{Arguments, Decoder, Opcode};

const INTRO_SIZE: usize = 0x1a;
const LATEST_ADDR: usize = 0x18;
const BASE_OFFSET: usize = 0x500;

#[derive(Debug)]
struct Slice2Error;

trait SliceExt {
    fn read_u16_le(&self) -> Result<u16, Slice2Error>;
}

impl SliceExt for [u8] {
    fn read_u16_le(&self) -> Result<u16, Slice2Error> {
        Ok(u16::from_le_bytes(
            self.get(..2)
                .ok_or(Slice2Error)?
                .try_into()
                .map_err(|_| Slice2Error)?,
        ))
    }
}

struct Word<'a> {
    name: &'a str,
    flag: u8,
    prev: u16,
    code: &'a [u8],
}

fn compile_dict(rom: &[u8], latest: u16) -> BTreeMap<u16, Word> {
    let mut res = BTreeMap::new();
    let mut code_ptr = latest;
    let mut code_end = rom.len();
    while code_ptr != 0 {
        let word_ptr = usize::from(code_ptr) - BASE_OFFSET;
        let name_start =
            rom[..word_ptr - 5].iter().rposition(|x| *x == 0).unwrap() + 1;
        let c_name = CStr::from_bytes_until_nul(&rom[name_start..]).unwrap();
        let name = c_name.to_str().unwrap();
        let flag = rom[word_ptr - 3];
        let prev = rom[word_ptr - 2..].read_u16_le().unwrap();
        let code = &rom[word_ptr..code_end];
        res.insert(
            code_ptr,
            Word {
                name,
                flag,
                prev,
                code,
            },
        );

        code_ptr = prev;
        code_end = name_start - 1;
    }
    res
}

fn is_valid_ident(s: &str) -> bool {
    let mut chars = s.chars();
    chars
        .next()
        .map_or(false, |ch| ch.is_ascii_alphabetic() || ch == '_')
        && chars.all(|ch| ch.is_ascii_alphanumeric() || ch == '_')
}

fn escape_word_name<'a>(
    name: &'a str,
    aliases: &HashMap<&str, &'a str>,
) -> &'a str {
    if let Some(value) = aliases.get(name) {
        return value;
    }
    if is_valid_ident(name) {
        return name;
    }
    panic!("unmapped invalid word name")
}

fn generate_labels<'a>(
    dict: &BTreeMap<u16, Word<'a>>,
    aliases: HashMap<&str, &'a str>,
) -> BTreeMap<u16, Cow<'a, str>> {
    let mut labels = BTreeMap::new();
    for (wordxp, word) in dict {
        let mut num = 0;
        let escaped_name = escape_word_name(word.name, &aliases);
        labels.insert(*wordxp, escaped_name.into());
        let mut decoder = Decoder { m: false, x: false };
        let mut pc = 0;
        let (instr, size) =
            decoder.decode(&word.code[usize::from(pc)..]).unwrap();
        pc += u16::from(size);
        if matches!(instr.opcode, Opcode::Ent) {
            while let Ok(xp) = word.code[usize::from(pc)..].read_u16_le() {
                let name = dict[&xp].name;
                match name {
                    "(lit)" | "DOCON" | "DOVAR" => pc += 2,
                    "(do)" | "(?do)" | "(loop)" | "(branch)" | "(?branch)" => {
                        pc += 2;
                        let addr =
                            word.code[usize::from(pc)..].read_u16_le().unwrap();
                        let local_label = format!(".{escaped_name}_{num}");
                        labels.entry(addr).or_insert(local_label.into());
                        num += 1;
                    }
                    "(.\")" => {
                        while word.code[usize::from(pc + 2)] != 0 {
                            pc += 1;
                        }
                        pc += 1;
                    }
                    _ => (),
                }
                pc += 2;
            }
        } else {
            while !word.code[usize::from(pc)..].is_empty() {
                let (instr, size) =
                    decoder.decode(&word.code[usize::from(pc)..]).unwrap();
                if let Some(Arguments::Rel(rel)) = instr.argument {
                    let addr =
                        (*wordxp + pc + 2).wrapping_add_signed(rel.into());
                    let local_label = format!(".{escaped_name}_{num}");
                    labels.entry(addr).or_insert(local_label.into());
                    num += 1;
                }
                pc += u16::from(size);
            }
        }
    }
    labels
}

fn disassembly_block(
    decoder: &mut Decoder,
    block: &[u8],
    start_addr: u16,
    labels: &BTreeMap<u16, Cow<str>>,
) {
    let mut pc = 0;
    while !block[usize::from(pc)..].is_empty() {
        let addr = start_addr + pc;
        if let Some(label) = labels.get(&addr) {
            println!("{label}:");
        }
        let (instr, size) = decoder.decode(&block[usize::from(pc)..]).unwrap();
        print!("  ");
        match (&instr.opcode, &instr.argument) {
            (Opcode::Rep, Some(Arguments::Imm(imm))) => {
                println!("{instr}");
                if imm & 0x20 != 0 {
                    println!("!al");
                }
                if imm & 0x10 != 0 {
                    println!("!rl");
                }
            }
            (Opcode::Sep, Some(Arguments::Imm(imm))) => {
                println!("{instr}");
                if imm & 0x20 != 0 {
                    println!("!as");
                }
                if imm & 0x10 != 0 {
                    println!("!rs");
                }
            }
            (op @ Opcode::Jmp, Some(Arguments::Abs(addr))) => {
                print!("{op} ");
                println!("{}", labels[addr]);
            }
            (op, &Some(Arguments::Rel(r))) => {
                print!("{op} ");
                let addr = addr.wrapping_add_signed(r.into()) + 2;
                println!("{}", labels[&addr]);
            }
            _ => println!("{instr}"),
        }
        pc += u16::from(size);
    }
}

fn main() {
    let rom = fs::read(env::args_os().nth(1).unwrap()).unwrap();
    let rom = &rom[..=rom.iter().rposition(|x| *x != 0).unwrap_or(0)];

    let aliases_file = env::args_os()
        .nth(2)
        .and_then(|x| fs::read_to_string(x).ok());
    // format: old_name new_name comments
    let aliases = aliases_file
        .as_ref()
        .map(|x| {
            x.lines()
                .filter_map(|x| x.split_once(' '))
                .map(|(a, b)| (a, b.split_once(' ').map(|x| x.0).unwrap_or(b)))
                .collect::<HashMap<_, _>>()
        })
        .unwrap_or_default();

    let latest = rom[LATEST_ADDR..].read_u16_le().unwrap();
    let dict = compile_dict(rom, latest);
    let labels = {
        let mut labels = generate_labels(&dict, aliases);
        labels.insert((BASE_OFFSET).try_into().unwrap(), "start".into());
        labels.insert(
            (rom.len() + BASE_OFFSET).try_into().unwrap(),
            "end".into(),
        );
        labels
    };

    println!(";; output from deforth by shadlock0133 (aka Aurora :3)");
    println!("!cpu 65el02");
    println!("!set prev = 0");
    println!(".FLAG_NONE = 0");
    println!(".FLAG_IMM = 1");
    println!();
    println!("* = {BASE_OFFSET:#06x}");
    println!("start:");
    let mut decoder = Decoder::default();
    disassembly_block(&mut decoder, &rom[..INTRO_SIZE], 0, &labels);
    let decoder = decoder;
    println!();

    for (wordxp, word) in &dict {
        println!("!text 0, {:?}, 0 ; name", word.name);
        println!(
            "!8 {}",
            match word.flag {
                0 => ".FLAG_NONE",
                1 => ".FLAG_IMM",
                _ => unimplemented!(),
            }
        );
        println!("!16 prev");
        println!("!set prev = *");

        // code
        let (instr, size) = decoder.clone().decode(word.code).unwrap();
        if matches!(instr.opcode, Opcode::Ent) {
            println!("{}:", labels[wordxp]);
            println!("  {instr}");
            let mut pc = u16::from(size);
            while let Ok(xp) = word.code[usize::from(pc)..].read_u16_le() {
                let addr = wordxp + pc;
                if let Some(label) = labels.get(&addr) {
                    println!("{label}:");
                }
                let name = dict[&xp].name;
                let label = &labels[&xp];
                match name {
                    "(lit)" | "DOCON" | "DOVAR" => {
                        pc += 2;
                        let value =
                            word.code[usize::from(pc)..].read_u16_le().unwrap();
                        if let Some(label2) = labels.get(&value) {
                            println!("  !16 {label}, {label2}",);
                        } else {
                            println!("  !16 {label}, {value:#06x}");
                        }
                    }
                    "(do)" | "(?do)" | "(loop)" | "(branch)" | "(?branch)" => {
                        pc += 2;
                        let value =
                            word.code[usize::from(pc)..].read_u16_le().unwrap();
                        let offset = (value - wordxp) as i16 - pc as i16 + 2;
                        if let Some(label2) = labels.get(&value) {
                            println!("  !16 {label}, {label2}");
                        } else {
                            println!("  !16 {label}, * + {offset} ; {name} {value:#06x}");
                        }
                    }
                    "(.\")" => {
                        println!("  !16 {label} ; {name}");
                        print!("  !text \"");
                        while word.code[usize::from(pc) + 2] != 0 {
                            let ch = char::from(word.code[usize::from(pc) + 2]);
                            if ch == '"' {
                                print!("\\");
                            }
                            print!("{}", ch);
                            pc += 1;
                        }
                        pc += 1;
                        println!("\", 0");
                    }
                    _ => {
                        print!("  !16 {label}");
                        if label != name {
                            print!(" ; {name}")
                        }
                        println!()
                    }
                }
                pc += 2;
            }
            if !word.code[usize::from(pc)..].is_empty() {
                println!("  !8 {}", word.code[usize::from(pc)]);
            }
        } else {
            disassembly_block(
                &mut decoder.clone(),
                word.code,
                *wordxp,
                &labels,
            );
        }
        println!();
    }
    println!("end:");
    println!("  !align 128, 0, 0");
}
