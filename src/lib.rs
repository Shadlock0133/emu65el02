pub mod op;
pub mod mem;
pub mod cpu;
pub mod devices;

use core::fmt;

pub struct Instruction {
    pub opcode: Opcode,
    pub argument: Option<Arguments>,
}

impl fmt::Display for Instruction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.opcode)?;
        if let Some(arg) = &self.argument {
            write!(f, " {arg}")?;
        }
        Ok(())
    }
}

macro_rules! opcodes {
    ($vis:vis enum $name:ident { $(
        $variant:ident => $lit:literal
    ),* $(,)? } ) => {
        $vis enum $name { $($variant),* }
        impl ::core::fmt::Display for $name {
            fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
                let op: &'static str = match self {
                    $( Self::$variant => $lit ),*
                };
                write!(f, "{op}")
            }
        }
    };
}

opcodes! {
    pub enum Opcode {
        Adc => "adc",
        Cmp => "cmp",
        Cpx => "cpx",
        Cpy => "cpy",
        Dec => "dec",
        Dex => "dex",
        Dey => "dey",
        Inc => "inc",
        Inx => "inx",
        Iny => "iny",
        Sbc => "sbc",

        Lda => "lda",
        Ldx => "ldx",
        Ldy => "ldy",
        Sta => "sta",
        Stx => "stx",
        Sty => "sty",
        Tax => "tax",
        Tay => "tay",
        Tsx => "tsx",
        Txa => "txa",
        Txs => "txs",
        Tya => "tya",

        And => "and",
        Asl => "asl",
        Bit => "bit",
        Eor => "eor",
        Lsr => "lsr",
        Ora => "ora",
        Rol => "rol",
        Ror => "ror",

        Bcc => "bcc",
        Bcs => "bcs",
        Beq => "beq",
        Bmi => "bmi",
        Bne => "bne",
        Bpl => "bpl",
        Bvc => "bvc",
        Bvs => "bvs",
        Bra => "bra",

        Jmp => "jmp",
        Jsr => "jsr",
        Rts => "rts",
        Rti => "rti",

        Clc	=> "clc",
        Cld	=> "cld",
        Cli	=> "cli",
        Clv	=> "clv",
        Sec	=> "sec",
        Sed	=> "sed",
        Sei	=> "sei",

        Brk => "brk",
        Nop => "nop",

        Pha => "pha",
        Php => "php",
        Phx => "phx",
        Phy => "phy",
        Pla => "pla",
        Plp => "plp",
        Plx => "plx",
        Ply => "ply",

        Stz => "stz",
        Trb => "trb",
        Tsb => "tsb",
        Stp => "stp",
        Wai => "wai",

        Pea => "pea",
        Pei => "pei",
        Per => "per",
        Rep => "rep",
        Sep => "sep",
        Txy => "txy",
        Tyx => "tyx",
        Xba => "xba",
        Xce => "xce",

        Ent => "ent",
        Nxa => "nxa",
        Nxt => "nxt",
        Txr => "txr",
        Trx => "trx",
        Txi => "txi",
        Tix => "tix",
        Rha => "rha",
        Rla => "rla",
        Rhx => "rhx",
        Rlx => "rlx",
        Rhy => "rhy",
        Rly => "rly",
        Rhi => "rhi",
        Rli => "rli",
        Rea => "rea",
        Rei => "rei",
        Rer => "rer",
        Mmu => "mmu",

        Mul => "mul",
        Div => "div",
        Zea => "zea",
        Sea => "sea",
        Tad => "tad",
        Tda => "tda",
        Phd => "phd",
        Pld => "pld",
    }
}

pub enum Arguments {
    Imm(u8),
    Imm16(u16),
    Zp(u8),
    ZpX(u8),
    ZpY(u8),
    Rs(u8),
    RsY(u8),
    Rr(u8),
    RrY(u8),
    Ind(u8),
    IndX(u8),
    IndY(u8),
    Rel(i8),
    Abs(u16),
    AbsX(u16),
    AbsY(u16),
}

impl fmt::Display for Arguments {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Imm(imm) => write!(f, "#${imm:02x}")?,
            Self::Imm16(imm) => write!(f, "#${imm:04x}")?,
            Self::Zp(zp) => write!(f, "${zp:02x}")?,
            Self::ZpX(zp) => write!(f, "${zp:02x},x")?,
            Self::ZpY(zp) => write!(f, "${zp:02x},y")?,
            Self::Rs(r) => write!(f, "${r:02x},s")?,
            Self::RsY(r) => write!(f, "(${r:02x},s),y")?,
            Self::Rr(r) => write!(f, "${r:02x},r")?,
            Self::RrY(r) => write!(f, "(${r:02x},r),y")?,
            Self::Ind(ind) => write!(f, "(${ind:02x})")?,
            Self::IndX(ind) => write!(f, "(${ind:02x},x)")?,
            Self::IndY(ind) => write!(f, "(${ind:02x}),y")?,
            Self::Rel(rel) => write!(f, "{rel}")?,
            Self::Abs(addr) => write!(f, "${addr:04x}")?,
            Self::AbsX(addr) => write!(f, "${addr:04x},x")?,
            Self::AbsY(addr) => write!(f, "${addr:04x},y")?,
        }
        Ok(())
    }
}

pub struct DecodeError {}

impl fmt::Display for DecodeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Invalid opcode")
    }
}

impl fmt::Debug for DecodeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Invalid opcode")
    }
}

#[derive(Clone)]
pub struct Decoder {
    pub m: bool,
    pub x: bool,
}

impl Default for Decoder {
    fn default() -> Self {
        Self { m: true, x: true }
    }
}

impl Decoder {
    pub fn decode(&mut self, data: &[u8]) -> Result<(Instruction, u8), DecodeError> {
        use {Opcode::*, Arguments::*};
        let opcode = data[0];
        let mut size = 1u8;
        let mut argument = None;
        macro_rules! op {
            ($op:expr) => {{
                $op
            }};
            ($op:expr, $x:expr) => {{
                argument = Some($x);
                $op
            }};
            ($op:expr, $x:expr, u8) => {{
                let a = data[usize::from(size)];
                size += 1;
                argument = Some($x(a));
                $op
            }};
            ($op:expr, $x:expr, i8) => {{
                let a = data[usize::from(size)];
                size += 1;
                argument = Some($x(i8::from_le_bytes([a])));
                $op
            }};
            ($op:expr, $x:expr, u16) => {{
                let a = data[usize::from(size)];
                size += 1;
                let b = data[usize::from(size)];
                size += 1;
                argument = Some($x(u16::from_le_bytes([a, b])));
                $op
            }};
        }
        let opcode = match opcode {
            0x00 => op!(Brk),
            0x01 => op!(Ora, IndX, u8),
            0x02 => op!(Nxt),
            0x03 => op!(Ora, Rs, u8),
            0x04 => op!(Tsb, Zp, u8),
            0x05 => op!(Ora, Zp, u8),
            0x06 => op!(Asl, Zp, u8),
            0x07 => op!(Ora, Rr, u8),
            0x08 => op!(Php),
            0x09 if !self.m => op!(Ora, Imm16, u16),
            0x09 => op!(Ora, Imm, u8),
            0x0a => op!(Asl),
            0x0b => op!(Rhi),
            0x0c => op!(Tsb, Abs, u16),
            0x0d => op!(Ora, Abs, u16),
            0x0e => op!(Asl, Abs, u16),
            0x0f => op!(Mul, Zp, u8),

            0x10 => op!(Bpl, Rel, i8),
            0x11 => op!(Ora, IndY, u8),
            0x12 => op!(Ora, Ind, u8),
            0x13 => op!(Ora, RsY, u8),
            0x14 => op!(Trb, Zp, u8),
            0x15 => op!(Ora, ZpX, u8),
            0x16 => op!(Asl, ZpX, u8),
            0x17 => op!(Ora, RrY, u8),
            0x18 => op!(Clc),
            0x19 => op!(Ora, AbsY, u16),
            0x1a => op!(Inc),
            0x1b => op!(Rhx),
            0x1c => op!(Trb, Abs, u16),
            0x1d => op!(Ora, AbsX, u16),
            0x1e => op!(Asl, AbsX, u16),
            0x1f => op!(Mul, ZpX, u8),

            0x20 => op!(Jsr, Abs, u16),
            0x21 => op!(And, IndX, u8),
            0x22 => op!(Ent),
            0x23 => op!(And, Rs, u8),
            0x24 => op!(Bit, Zp, u8),
            0x25 => op!(And, Zp, u8),
            0x26 => op!(Rol, Zp, u8),
            0x27 => op!(And, Rr, u8),
            0x28 => op!(Plp),
            0x29 if !self.m => op!(And, Imm16, u16),
            0x29 => op!(And, Imm, u8),
            0x2a => op!(Rol),
            0x2b => op!(Rli),
            0x2c => op!(Bit, Abs, u16),
            0x2d => op!(And, Abs, u16),
            0x2e => op!(Rol, Abs, u16),
            0x2f => op!(Mul, Abs, u16),
            
            0x30 => op!(Bmi, Rel, i8),
            0x31 => op!(And, IndY, u8),
            0x32 => op!(And, Ind, u8),
            0x33 => op!(And, RsY, u8),
            0x34 => op!(Bit, ZpX, u8),
            0x35 => op!(And, ZpX, u8),
            0x36 => op!(Rol, ZpX, u8),
            0x37 => op!(And, RrY, u8),
            0x38 => op!(Sec),
            0x39 => op!(And, AbsY, u16),
            0x3a => op!(Dec),
            0x3b => op!(Rlx),
            0x3c => op!(Bit, AbsX, u16),
            0x3d => op!(And, AbsX, u16),
            0x3e => op!(Rol, AbsX, u16),
            0x3f => op!(Mul, AbsX, u16),
            
            0x40 => op!(Rti),
            0x41 => op!(Eor, IndX, u8),
            0x42 => op!(Nxa),
            0x43 => op!(Eor, Rs, u8),
            0x44 => op!(Rea, Abs, u16),
            0x45 => op!(Eor, Zp, u8),
            0x46 => op!(Lsr, Zp, u8),
            0x47 => op!(Eor, Rr, u8),
            0x48 => op!(Pha),
            0x49 if !self.m => op!(Eor, Imm16, u16),
            0x49 => op!(Eor, Imm, u8),
            0x4a => op!(Lsr),
            0x4b => op!(Rha),
            0x4c => op!(Jmp, Abs, u16),
            0x4d => op!(Eor, Abs, u16),
            0x4e => op!(Lsr, Abs, u16),
            0x4f => op!(Div, Zp, u8),
            
            0x50 => op!(Bvc, Rel, i8),
            0x51 => op!(Eor, IndY, u8),
            0x52 => op!(Eor, Ind, u8),
            0x53 => op!(Eor, RsY, u8),
            0x54 => op!(Rei, Zp, u8),
            0x55 => op!(Eor, ZpX, u8),
            0x56 => op!(Lsr, ZpX, u8),
            0x57 => op!(Eor, RrY, u8),
            0x58 => op!(Cli),
            0x59 => op!(Eor, AbsY, u16),
            0x5a => op!(Phy),
            0x5b => op!(Rhy),
            0x5c => op!(Txi),
            0x5d => op!(Eor, AbsX, u16),
            0x5e => op!(Lsr, AbsX, u16),
            0x5f => op!(Div, ZpX, u8),
            
            0x60 => op!(Rts),
            0x61 => op!(Adc, IndX, u8),
            0x62 => op!(Per, Rel, i8),
            0x63 => op!(Adc, Rs, u8),
            0x64 => op!(Stz, Zp, u8),
            0x65 => op!(Adc, Zp, u8),
            0x66 => op!(Ror, Zp, u8),
            0x67 => op!(Adc, Rr, u8),
            0x68 => op!(Pla),
            0x69 if !self.m => op!(Adc, Imm16, u16),
            0x69 => op!(Adc, Imm, u8),
            0x6a => op!(Ror),
            0x6b => op!(Rla),
            0x6c => op!(Jmp, Ind, u8),
            0x6d => op!(Adc, Abs, u16),
            0x6e => op!(Ror, Abs, u16),
            0x6f => op!(Div, Abs, u16),
            
            0x70 => op!(Bvs, Rel, i8),
            0x71 => op!(Adc, IndY, u8),
            0x72 => op!(Adc, Ind, u8),
            0x73 => op!(Adc, RsY, u8),
            0x74 => op!(Stz, ZpX, u8),
            0x75 => op!(Adc, ZpX, u8),
            0x76 => op!(Ror, ZpX, u8),
            0x77 => op!(Adc, RrY, u8),
            0x78 => op!(Sei),
            0x79 => op!(Adc, AbsY, u16),
            0x7a => op!(Ply),
            0x7b => op!(Rly),
            0x7c => op!(Jmp, AbsX, u16),
            0x7d => op!(Adc, AbsX, u16),
            0x7e => op!(Ror, AbsX, u16),
            0x7f => op!(Div, AbsX, u16),
            
            0x80 => op!(Bra, Rel, i8),
            0x81 => op!(Sta, IndX, u8),
            0x82 => op!(Rer, Rel, i8),
            0x83 => op!(Sta, Rs, u8),
            0x84 => op!(Sty, Zp, u8),
            0x85 => op!(Sta, Zp, u8),
            0x86 => op!(Stx, Zp, u8),
            0x87 => op!(Sta, Rr, u8),
            0x88 => op!(Dey),
            0x89 if !self.m => op!(Bit, Imm16, u16),
            0x89 => op!(Bit, Imm, u8),
            0x8a => op!(Txa),
            0x8b => op!(Txr),
            0x8c => op!(Sty, Abs, u16),
            0x8d => op!(Sta, Abs, u16),
            0x8e => op!(Stx, Abs, u16),
            0x8f => op!(Zea),
            
            0x90 => op!(Bcc, Rel, i8),
            0x91 => op!(Sta, IndY, u8),
            0x92 => op!(Sta, Ind, u8),
            0x93 => op!(Sta, RsY, u8),
            0x94 => op!(Sty, ZpX, u8),
            0x95 => op!(Sta, ZpX, u8),
            0x96 => op!(Stx, ZpY, u8),
            0x97 => op!(Sta, RrY, u8),
            0x98 => op!(Tya),
            0x99 => op!(Sta, AbsY, u16),
            0x9a => op!(Txs),
            0x9b => op!(Txy),
            0x9c => op!(Stz, Abs, u16),
            0x9d => op!(Sta, AbsX, u16),
            0x9e => op!(Stz, AbsX, u16),
            0x9f => op!(Sea),
            
            0xa0 if !self.m => op!(Ldy, Imm16, u16),
            0xa0 => op!(Ldy, Imm, u8),
            0xa1 => op!(Lda, IndX, u8),
            0xa2 if !self.m => op!(Ldx, Imm16, u16),
            0xa2 => op!(Ldx, Imm, u8),
            0xa3 => op!(Lda, Rs, u8),
            0xa4 => op!(Ldy, Zp, u8),
            0xa5 => op!(Lda, Zp, u8),
            0xa6 => op!(Ldx, Zp, u8),
            0xa7 => op!(Lda, Rr, u8),
            0xa8 => op!(Tay),
            0xa9 if !self.m => op!(Lda, Imm16, u16),
            0xa9 => op!(Lda, Imm, u8),
            0xaa => op!(Tax),
            0xab => op!(Trx),
            0xac => op!(Ldy, Abs, u16),
            0xad => op!(Lda, Abs, u16),
            0xae => op!(Ldx, Abs, u16),
            0xaf => op!(Tda),
            
            0xb0 => op!(Bcs, Rel, i8),
            0xb1 => op!(Lda, IndY, u8),
            0xb2 => op!(Lda, Ind, u8),
            0xb3 => op!(Lda, RsY, u8),
            0xb4 => op!(Ldy, ZpX, u8),
            0xb5 => op!(Lda, ZpX, u8),
            0xb6 => op!(Ldx, ZpY, u8),
            0xb7 => op!(Lda, RrY, u8),
            0xb8 => op!(Clv),
            0xb9 => op!(Lda, AbsY, u16),
            0xba => op!(Tsx),
            0xbb => op!(Tyx),
            0xbc => op!(Ldy, AbsX, u16),
            0xbd => op!(Lda, AbsX, u16),
            0xbe => op!(Ldx, AbsY, u16),
            0xbf => op!(Tad),
            
            0xc0 if !self.m => op!(Cpy, Imm16, u16),
            0xc0 => op!(Cpy, Imm, u8),
            0xc1 => op!(Cmp, IndX, u8),
            0xc2 => {
                let op = op!(Rep, Imm, u8);
                if let Some(Imm(x)) = argument {
                    if (x >> 4) & 1 == 1 {
                        self.x = false;
                    }
                    if x >> 5 & 1 == 1 {
                        self.m = false;
                    }
                }
                op
            }
            0xc3 => op!(Cmp, Rs, u8),
            0xc4 => op!(Cpy, Zp, u8),
            0xc5 => op!(Cmp, Zp, u8),
            0xc6 => op!(Dec, Zp, u8),
            0xc7 => op!(Cmp, Rr, u8),
            0xc8 => op!(Iny),
            0xc9 if !self.m => op!(Cmp, Imm16, u16),
            0xc9 => op!(Cmp, Imm, u8),
            0xca => op!(Dex),
            0xcb => op!(Wai),
            0xcc => op!(Cpy, Abs, u16),
            0xcd => op!(Cmp, Abs, u16),
            0xce => op!(Dec, Abs, u16),
            0xcf => op!(Pld),
            
            0xd0 => op!(Bne, Rel, i8),
            0xd1 => op!(Cmp, IndY, u8),
            0xd2 => op!(Cmp, Ind, u8),
            0xd3 => op!(Cmp, RsY, u8),
            0xd4 => op!(Pei, Zp, u8),
            0xd5 => op!(Cmp, ZpX, u8),
            0xd6 => op!(Dec, ZpX, u8),
            0xd7 => op!(Cmp, RrY, u8),
            0xd8 => op!(Cld),
            0xd9 => op!(Cmp, AbsY, u16),
            0xda => op!(Phx),
            0xdb => op!(Stp),
            0xdc => op!(Tix),
            0xdd => op!(Cmp, AbsX, u16),
            0xde => op!(Dec, AbsX, u16),
            0xdf => op!(Phd),
            
            0xe0 => op!(Cpx, Imm, u8),
            0xe1 => op!(Sbc, IndX, u8),
            0xe2 => {
                let op = op!(Sep, Imm, u8);
                if let Some(Imm(x)) = argument {
                    if (x >> 4) & 1 == 1 {
                        self.x = true;
                    }
                    if x >> 5 & 1 == 1 {
                        self.m = true;
                    }
                }
                op
            }
            0xe3 => op!(Sbc, Rs, u8),
            0xe4 => op!(Cpx, Zp, u8),
            0xe5 => op!(Sbc, Zp, u8),
            0xe6 => op!(Inc, Zp, u8),
            0xe7 => op!(Sbc, Rr, u8),
            0xe8 => op!(Inx),
            0xe9 if !self.m => op!(Sbc, Imm16, u16),
            0xe9 => op!(Sbc, Imm, u8),
            0xea => op!(Nop),
            0xeb => op!(Xba),
            0xec => op!(Cpx, Abs, u16),
            0xed => op!(Sbc, Abs, u16),
            0xee => op!(Inc, Abs, u16),
            0xef => op!(Mmu, Imm, u8),
            
            0xf0 => op!(Beq, Rel, i8),
            0xf1 => op!(Sbc, IndY, u8),
            0xf2 => op!(Sbc, Ind, u8),
            0xf3 => op!(Sbc, RsY, u8),
            0xf4 => op!(Pea, Abs, u16),
            0xf5 => op!(Sbc, ZpX, u8),
            0xf6 => op!(Inc, ZpX, u8),
            0xf7 => op!(Sbc, RrY, u8),
            0xf8 => op!(Sed),
            0xf9 => op!(Sbc, AbsY, u16),
            0xfa => op!(Plx),
            0xfb => op!(Xce),
            0xfc => op!(Jsr, AbsX, u16),
            0xfd => op!(Sbc, AbsX, u16),
            0xfe => op!(Inc, AbsX, u16),
            0xff => return Err(DecodeError {}),
        };
        Ok((Instruction { opcode, argument }, size))
    }
}
