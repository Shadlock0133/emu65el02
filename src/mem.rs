use core::ops::{Index, IndexMut, RangeFrom};

pub struct Mem {
    mem: [u8; 0x10000],
    size: u8,
}

impl Mem {
    pub fn new(size: u8, boot_addr: u16, boot_rom: &[u8]) -> Self {
        assert!((1..=8).contains(&size));
        let mut mem = [0; 0x10000];
        mem[0] = 2;
        mem[1] = 1;
        mem[boot_addr.into()..][..boot_rom.len()].copy_from_slice(boot_rom);
        Self { mem, size }
    }

    pub fn mem(&self) -> &[u8] {
        &self.mem
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
