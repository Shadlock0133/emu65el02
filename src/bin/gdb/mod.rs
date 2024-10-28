use std::num::NonZeroUsize;

use gdbstub::{
    arch::{Arch, Registers},
    target::{
        ext::base::{singlethread::SingleThreadBase, BaseOps},
        Target,
    },
};

use crate::{Interconnect, RegFile};

pub struct Cpu65el02;
impl Registers for RegFile {
    type ProgramCounter = u16;

    fn pc(&self) -> Self::ProgramCounter {
        self.pc
    }

    fn gdb_serialize(&self, write_byte: impl FnMut(Option<u8>)) {
        todo!()
    }

    fn gdb_deserialize(&mut self, bytes: &[u8]) -> Result<(), ()> {
        todo!()
    }
}

#[derive(Debug)]
pub enum RegId {
    A,
    X,
    Y,
    I,
    D,
    S,
    R,
}

impl gdbstub::arch::RegId for RegId {
    fn from_raw_id(id: usize) -> Option<(Self, Option<NonZeroUsize>)> {
        match id {
            0 => Some((Self::A, NonZeroUsize::new(2))),
            _ => None,
        }
    }
}

impl Arch for Cpu65el02 {
    type Usize = u16;
    type Registers = RegFile;
    type BreakpointKind = ();
    type RegId = RegId;
}

impl Target for Interconnect {
    type Arch = Cpu65el02;
    type Error = ();

    fn base_ops(
        &mut self,
    ) -> gdbstub::target::ext::base::BaseOps<'_, Self::Arch, Self::Error>
    {
        BaseOps::SingleThread(self)
    }
}

impl SingleThreadBase for Interconnect {
    fn read_registers(
        &mut self,
        regs: &mut <Self::Arch as Arch>::Registers,
    ) -> gdbstub::target::TargetResult<(), Self> {
        *regs = self.regs.clone();
        Ok(())
    }

    fn write_registers(
        &mut self,
        regs: &<Self::Arch as Arch>::Registers,
    ) -> gdbstub::target::TargetResult<(), Self> {
        self.regs = regs.clone();
        Ok(())
    }

    fn read_addrs(
        &mut self,
        start_addr: <Self::Arch as Arch>::Usize,
        data: &mut [u8],
    ) -> gdbstub::target::TargetResult<usize, Self> {
        data.copy_from_slice(&self.mem[start_addr..][..data.len()]);
        Ok(data.len())
    }

    fn write_addrs(
        &mut self,
        start_addr: <Self::Arch as Arch>::Usize,
        data: &[u8],
    ) -> gdbstub::target::TargetResult<(), Self> {
        self.mem[start_addr..][..data.len()].copy_from_slice(data);
        Ok(())
    }
}
