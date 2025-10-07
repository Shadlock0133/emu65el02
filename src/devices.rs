pub struct Disk {
    name: [u8; 64],
    pub data: Vec<u8>,
}
impl Disk {
    pub fn new(name: &str, data: Vec<u8>) -> Self {
        let mut name_buf = [0; 64];
        name_buf[..name.len()].copy_from_slice(name.as_bytes());
        Self {
            name: name_buf,
            data,
        }
    }
}

pub struct DiskDrive {
    // mmio
    pub buffer: [u8; 0x80],
    pub sector: u16,
    pub status: u8,

    // hidden data
    pub disk: Option<Disk>,
}

impl Default for DiskDrive {
    fn default() -> Self {
        Self {
            buffer: [0; 0x80],
            sector: 0,
            status: 0,
            disk: None,
        }
    }
}

impl DiskDrive {
    pub fn read_sector(&mut self) {
        self.buffer.fill(0);
        let data = self
            .disk
            .as_mut()
            .and_then(|disk| disk.data.get(usize::from(self.sector) * 0x80..));
        if let Some(data) = data {
            let data = &data[..0x80.min(data.len())];
            self.buffer[..data.len()].copy_from_slice(data);
            self.status = 0;
        } else {
            self.status = 0xff;
        }
    }
}

const DISPLAY_WIDTH: usize = 80;
const DISPLAY_HEIGHT: usize = 50;
const KEY_BUFFER_SIZE: u8 = 16;

#[derive(Debug)]
pub struct Display {
    // mmio
    pub memory_access_row: u8,

    pub cursor_x: u8,
    pub cursor_y: u8,
    pub cursor_mode: u8,

    pub key_start: u8,
    pub key_end: u8,

    pub blit_status: u8,
    pub blit_x_start_fill_value: u8,
    pub blit_y_start: u8,
    pub blit_x_offset: u8,
    pub blit_y_offset: u8,
    pub blit_width: u8,
    pub blit_height: u8,

    // hidden data
    pub key_buffer: [u8; KEY_BUFFER_SIZE as usize],
    pub buffer: [u8; DISPLAY_WIDTH * DISPLAY_HEIGHT],
}

impl Default for Display {
    fn default() -> Self {
        Self {
            memory_access_row: 0,
            cursor_x: 0,
            cursor_y: 0,
            cursor_mode: 0,

            key_start: 0,
            key_end: 0,

            blit_status: 0,
            blit_x_start_fill_value: 0,
            blit_y_start: 0,
            blit_x_offset: 0,
            blit_y_offset: 0,
            blit_width: 0,
            blit_height: 0,

            key_buffer: [0; KEY_BUFFER_SIZE as usize],
            buffer: [b' '; DISPLAY_WIDTH * DISPLAY_HEIGHT],
        }
    }
}

impl Display {
    pub fn current_key(&self) -> u8 {
        // todo: handle panic
        self.key_buffer[usize::from(self.key_start % KEY_BUFFER_SIZE)]
    }

    pub fn try_push_key(&mut self, value: u8) {
        if (self.key_start + 1) % KEY_BUFFER_SIZE != self.key_end {
            self.key_buffer[usize::from(self.key_end % KEY_BUFFER_SIZE)] =
                value;
            self.key_end = self.key_end.wrapping_add(1);
        }
    }

    pub fn blit_fill(&mut self) {
        // this technically happens async to cpu running
        let fill_value = self.blit_x_start_fill_value;
        let sx = usize::from(self.blit_x_offset);
        let sy = usize::from(self.blit_y_offset);
        let w = usize::from(self.blit_width);
        let h = usize::from(self.blit_height);
        assert!(sx + w <= 80);
        assert!(sy + h <= 50);
        for dy in 0..h {
            for dx in 0..w {
                let i = (dy + sy) * 80 + (dx + sx);
                self.buffer[i] = fill_value;
            }
        }
        self.blit_status = 0;
    }
}
