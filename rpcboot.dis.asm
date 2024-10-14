// disable 65c02 emulation
  clc
  xce
// map disk drive to redbus
  lda $00
  mmu #$00
// enable 16bit index and mem
  rep #$30
// map redbus to 0x0300
  lda #$0300
  mmu #$01
// enable redbus
  mmu #$02
// sector number @ 0x0002 = 0
  stz $02
// loaded data ptr @ 0x0004 = 0x0500
  lda #$0500
  sta $04
next_sector:
// disk drive sector = sector
  lda $02
  sta $0380
// disable 16bit mem
  sep #$20
// set disk drive command to read data sector
  lda #$04
  sta $0382
// wait for interrupt for new data
wait:
  wai
// check disk drive status
  cmp $0382
  beq wait
// 
  lda $0382
  beq continue
exit:
// disable redbus
  mmu #$82
// disable 16bit index and mem
  sep #$30
// enable 65c02 emulation
  sec
  xce
// jump to loaded code
  jmp $0500
continue:
// enable 16bit mem
  rep #$20
// i = 0x0300
  ldx #$0300
  txi
// y = 0x40 // loop counter
  ldy #$0040
copy:
// copy word from disk sector into memory
  nxa
  sta ($04)
  inc $04
  inc $04
// y--
  dey
  bne copy

// check for wraparound
  lda $04
  beq exit
// sector number++
  inc $02
  jmp next_sector
