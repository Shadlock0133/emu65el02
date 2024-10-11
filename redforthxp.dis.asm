;; output from deforth by shadlock0133 (aka Aurora :3)
!cpu 65el02
!set prev = 0
.FLAG_NONE = 0
.FLAG_IMM = 1
.FLAG_HIDE = 2

* = 0x0500
start:
  clc
  xce
  rep #$30
!al
!rl
  lda #$0300
  mmu #$01
  mmu #$02
  lda #$0400
  mmu #$03
  mmu #$04
  lda #$0500
  mmu #$06
  jmp COLD

!text 0, "DOCON", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- value )
; constant value impl
DOCON:
  tix
  lda $00,x
  pha
  rli
  nxt

!text 0, "DOVAR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- addr )
; variable value impl
DOVAR:
  tix
  phx
  rli
  nxt

!text 0, "DODOES", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DODOES:
  rlx
  phx
  nxt

!text 0, "(lit)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- lit )
; literal value inside word def
lit:
  nxa
  pha
  nxt

!text 0, "EXIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; finish current word def
EXIT:
  rli
  nxt

!text 0, "(branch)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; jmp as word
branch:
  nxa
  tax
  txi
  nxt

!text 0, "(?branch)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( a -- )
; beq as word
branch_if:
  pla
  nxa
  bne .branch_if_0
  tax
  txi
.branch_if_0:
  nxt

!text 0, "(do)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
do:
  nxa
  lda $02,s
  rha
  pla
  sec
  sbc $00,s
  rha
  pla
  nxt

!text 0, "(?do)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_do_if:
  nxa
  tax
  lda $02,s
  rha
  pla
  sec
  sbc $00,s
  beq ._do_if_0
  rha
  pla
  nxt
._do_if_0:
  rla
  pla
  txi
  nxt

!text 0, "(loop)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
loop:
  nxa
  tax
  lda $00,r
  inc
  eor $00,r
  bit #$8000
  bne .loop_0
  txi
.loop_0:
  lda $00,r
  inc
  sta $00,r
  nxt

!text 0, "(+loop)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_loop_add:
  nxa
  tax
  lda $00,s
  clc
  adc $00,r
  eor $00,r
  bit #$8000
  bne ._loop_add_0
  txi
._loop_add_0:
  clc
  pla
  adc $00,r
  sta $00,r
  nxt

!text 0, "(leave)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
leave:
  rla
  rla
  nxa
  tay
  ldx $00,y
  txi
  txa
  nxt

!text 0, "UNLOOP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UNLOOP:
  rla
  rla
  nxt

!text 0, "I", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
I:
  lda $00,r
  clc
  adc $02,r
  pha
  nxt

!text 0, "J", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
J:
  lda $04,r
  clc
  adc $06,r
  pha
  nxt

!text 0, "EXECUTE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
EXECUTE:
  plx
  dex
  phx
  rts

!text 0, "DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( a -- a a )
DUP:
  lda $00,s
  pha
  nxt

!text 0, "?DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
dup_if:
  lda $00,s
  beq .dup_if_0
  pha
.dup_if_0:
  nxt

!text 0, "2DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( b a -- b a b a )
_2dup:
  lda $02,s
  pha
  lda $02,s
  pha
  nxt

!text 0, "DROP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( a -- )
DROP:
  pla
  nxt

!text 0, "2DROP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( b a -- )
_2drop:
  pla
  pla
  nxt

!text 0, "SWAP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( b a -- a b )
SWAP:
  pla
  plx
  pha
  phx
  nxt

!text 0, "PICK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PICK:
  pla
  clc
  rol
  clc
  adc #$0002
  pha
  tsx
  txy
  lda ($00,s),y
  sta $00,s
  nxt

!text 0, "OVER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( b a -- b a b )
OVER:
  lda $02,s
  pha
  nxt

!text 0, "2OVER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( c b a -- c b a c )
_2over:
  lda $04,s
  pha
  nxt

!text 0, "ROT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ROT:
  pla
  plx
  ply
  phx
  pha
  phy
  nxt

!text 0, "2SWAP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_2swap:
  lda $06,s
  tax
  lda $02,s
  sta $06,s
  txa
  sta $02,s
  lda $04,s
  tax
  lda $00,s
  sta $04,s
  txa
  sta $00,s
  nxt

!text 0, "-ROT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rot_rev:
  pla
  plx
  ply
  pha
  phy
  phx
  nxt

!text 0, "NIP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
NIP:
  pla
  plx
  pha
  nxt

!text 0, "TUCK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TUCK:
  pla
  plx
  pha
  phx
  pha
  nxt

!text 0, ">R", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( r -- )
push_r:
  pla
  rha
  nxt

!text 0, "R>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- r )
pull_r:
  rla
  pha
  nxt

!text 0, "!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr value -- )
store:
  plx
  pla
  sta $00,x
  nxt

!text 0, "+!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr -- )
inc_word:
  plx
  pla
  clc
  adc $00,x
  sta $00,x
  nxt

!text 0, "-!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr -- )
dec_word:
  plx
  sec
  lda $00,x
  sbc $00,s
  sta $00,x
  pla
  nxt

!text 0, "C!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr value -- )
c_store:
  plx
  pla
  sep #$20
!as
  sta $00,x
  rep #$20
!al
  nxt

!text 0, "@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr -- value )
load:
  plx
  lda $00,x
  pha
  nxt

!text 0, "C@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr -- value )
c_load:
  plx
  sep #$20
!as
  lda $00,x
  zea
  rep #$20
!al
  pha
  nxt

!text 0, "+", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_add:
  pla
  clc
  adc $00,s
  sta $00,s
  nxt

!text 0, "-", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_sub:
  lda $02,s
  sec
  sbc $00,s
  sta $02,s
  pla
  nxt

!text 0, "M*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
m_mul:
  pla
  tsx
  sec
  mul $00,x
  plx
  pha
  phd
  nxt

!text 0, "UM*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
um_mul:
  pla
  tsx
  clc
  mul $00,x
  plx
  pha
  phd
  nxt

!text 0, "*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_mul:
  pla
  tsx
  sec
  mul $00,x
  plx
  pha
  nxt

!text 0, "U*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
umul:
  pla
  tsx
  clc
  mul $00,x
  plx
  pha
  nxt

!text 0, "SM/REM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sm_div_rem:
  plx
  pld
  pla
  phx
  tsx
  sec
  div $00,x
  plx
  phd
  pha
  nxt

!text 0, "FM/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
fm_div_mod:
  plx
  pld
  pla
  phx
  tsx
  sec
  div $00,x
  plx
  phd
  pha
  tda
  beq .fm_div_mod_0
  phx
  eor $00,s
  bit #$8000
  beq .fm_div_mod_1
  pla
  clc
  adc $02,s
  sta $02,s
  tsx
  dec $00,x
.fm_div_mod_0:
  nxt
.fm_div_mod_1:
  plx
  nxt

!text 0, "UM/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
um_div_mod:
  plx
  pld
  pla
  phx
  tsx
  clc
  div $00,x
  plx
  phd
  pha
  nxt

!text 0, "2*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
mul2:
  pla
  clc
  rol
  pha
  nxt

!text 0, "2/", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
div2:
  lda $00,s
  rol
  pla
  ror
  pha
  nxt

!text 0, "U>>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
shr:
  ply
  pla
.shr_0:
  clc
  ror
  dey
  bne .shr_0
  pha
  nxt

!text 0, "<<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
shl:
  ply
  pla
  cpy #$0000
  beq .shl_0
.shl_1:
  clc
  rol
  dey
  bne .shl_1
.shl_0:
  pha
  nxt

!text 0, "AND", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_and:
  pla
  and $00,s
  sta $00,s
  nxt

!text 0, "OR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
OR:
  pla
  ora $00,s
  sta $00,s
  nxt

!text 0, "XOR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
XOR:
  pla
  eor $00,s
  sta $00,s
  nxt

!text 0, "INVERT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
INVERT:
  pla
  eor #$ffff
  pha
  nxt

!text 0, "NEGATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
NEGATE:
  pla
  eor #$ffff
  inc
  pha
  nxt

!text 0, "1+", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
add1:
  pla
  inc
  pha
  nxt

!text 0, "1-", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sub1:
  pla
  dec
  pha
  nxt

!text 0, "SP@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- sp )
sp_load:
  tsx
  phx
  nxt

!text 0, "SP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( sp -- )
sp_store:
  plx
  txs
  nxt

!text 0, "RP@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- rp )
rp_load:
  trx
  phx
  nxt

!text 0, "RP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( rp -- )
rp_store:
  plx
  txr
  nxt

!text 0, "0=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
eq0:
  pla
  beq .eq0_0
  pea $0000
  nxt
.eq0_0:
  pea $ffff
  nxt

!text 0, "0<>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
neq0:
  pla
  beq .neq0_0
  pea $ffff
  nxt
.neq0_0:
  pha
  nxt

!text 0, "0<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
lt0:
  pla
  bmi .lt0_0
  pea $0000
  nxt
.lt0_0:
  pea $ffff
  nxt

!text 0, "<>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
neq:
  pla
  cmp $00,s
  beq .neq_0
  pla
  pea $ffff
  nxt
.neq_0:
  pla
  pea $0000
  nxt

!text 0, "<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
lt:
  pla
  cmp $00,s
  bmi .lt_0
  beq .lt_0
  pla
  pea $ffff
  nxt
.lt_0:
  pla
  pea $0000
  nxt

!text 0, ">", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
gt:
  pla
  cmp $00,s
  bmi .gt_0
  pla
  pea $0000
  nxt
.gt_0:
  pla
  pea $ffff
  nxt

!text 0, "U<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ult:
  pla
  cmp $00,s
  bcc .ult_0
  beq .ult_0
  pla
  pea $ffff
  nxt
.ult_0:
  pla
  pea $0000
  nxt

!text 0, "U>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ugt:
  pla
  cmp $00,s
  bcc .ugt_0
  pla
  pea $0000
  nxt
.ugt_0:
  pla
  pea $ffff
  nxt

!text 0, "<=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
le:
  pla
  cmp $00,s
  bmi .le_0
  pla
  pea $ffff
  nxt
.le_0:
  pla
  pea $0000
  nxt

!text 0, ">=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ge:
  pla
  cmp $00,s
  bmi .ge_0
  beq .ge_0
  pla
  pea $0000
  nxt
.ge_0:
  pla
  pea $ffff
  nxt

!text 0, "=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
eq:
  pla
  cmp $00,s
  beq .eq_0
  pla
  pea $0000
  nxt
.eq_0:
  pla
  pea $ffff
  nxt

!text 0, "CELL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( -- 2 )
CELL:
  pea $0002
  nxt

!text 0, "CELLS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( a -- 2*a )
CELLS:
  pla
  clc
  rol
  pha
  nxt

!text 0, "MAX", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MAX:
  pla
  cmp $00,s
  bmi .MAX_0
  sta $00,s
.MAX_0:
  nxt

!text 0, "MIN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MIN:
  pla
  cmp $00,s
  bpl .MIN_0
  sta $00,s
.MIN_0:
  nxt

!text 0, "MOVE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MOVE:
  rhi
  pla
  ply
  plx
  txi
  tyx
  tay
  beq .MOVE_0
  sep #$20
!as
.MOVE_1:
  nxa
  sta $00,x
  inx
  dey
  bne .MOVE_1
  rep #$20
!al
.MOVE_0:
  rli
  nxt

!text 0, "FILL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
; ( addr count value -- )
FILL:
  pla
  ply
  plx
  cpy #$0000
  beq .FILL_0
  sep #$20
!as
.FILL_1:
  sta $00,x
  inx
  dey
  bne .FILL_1
  rep #$20
!al
.FILL_0:
  nxt

!text 0, "MEMCMP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MEMCMP:
  rhi
  pla
  ply
  plx
  txi
  tyx
  tay
  beq .MEMCMP_0
  sep #$20
!as
.MEMCMP_2:
  nxa
  cmp $00,x
  bne .MEMCMP_1
  inx
  dey
  bne .MEMCMP_2
  rep #$20
!al
.MEMCMP_0:
  rli
  pea $0000
  nxt
.MEMCMP_1:
  rep #$20
!al
  rli
  bmi .MEMCMP_3
  pea $0001
  nxt
.MEMCMP_3:
  pea $ffff
  nxt

!text 0, "STRLEN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STRLEN:
  lda $00,s
  tax
  lda #$0000
  sep #$20
!as
.STRLEN_1:
  cmp $00,x
  beq .STRLEN_0
  inx
  bra .STRLEN_1
.STRLEN_0:
  rep #$20
!al
  txa
  sec
  sbc $00,s
  sta $00,s
  nxt

!text 0, "RSTRLEN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RSTRLEN:
  lda $00,s
  tax
  lda #$0000
  sep #$20
!as
.RSTRLEN_1:
  cmp $00,x
  beq .RSTRLEN_0
  dex
  bra .RSTRLEN_1
.RSTRLEN_0:
  rep #$20
!al
  pla
  phx
  sec
  sbc $00,s
  sta $00,s
  nxt

!text 0, "TRUE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TRUE:
  ent
  !16 DOCON, 0xffff

!text 0, "FALSE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FALSE:
  ent
  !16 DOCON, 0x0000

!text 0, "SCRATCH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SCRATCH:
  ent
  !16 DOCON, 0x0040

!text 0, "TIB", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIB:
  ent
  !16 DOCON, 0x0080

!text 0, "RADIX", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RADIX:
  ent
  !16 DOVAR, 0x000a

!text 0, "BL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BL:
  ent
  !16 DOCON, 0x0020

!text 0, "UITOA", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UITOA:
  ent
  !16 SCRATCH
  !16 lit, 0x0014
  !16 _add ; +
  !16 lit, 0x0000
  !16 OVER
  !16 c_store ; C!
.UITOA_1:
  !16 sub1 ; 1-
  !16 SWAP
  !16 lit, 0x0000
  !16 RADIX
  !16 load ; @
  !16 um_div_mod ; UM/MOD
  !16 rot_rev ; -ROT
  !16 lit, 0x0030
  !16 _add ; +
  !16 DUP
  !16 lit, 0x0039
  !16 gt ; >
  !16 branch_if, .UITOA_0
  !16 lit, 0x0007
  !16 _add ; +
.UITOA_0:
  !16 OVER
  !16 c_store ; C!
  !16 OVER
  !16 eq0 ; 0=
  !16 branch_if, .UITOA_1
  !16 NIP
  !16 EXIT

!text 0, "WORD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WORD:
  ent
.WORD_1:
  !16 DUP
  !16 c_load ; C@
  !16 DUP
  !16 lit, 0x0020
  !16 eq ; =
  !16 OVER
  !16 lit, 0x0009
  !16 eq ; =
  !16 OR
  !16 OVER
  !16 lit, 0x000a
  !16 eq ; =
  !16 OR
  !16 OVER
  !16 lit, 0x000d
  !16 eq ; =
  !16 OR
  !16 NIP
  !16 branch_if, .WORD_0
  !16 add1 ; 1+
  !16 branch, .WORD_1
.WORD_0:
  !16 DUP
  !16 c_load ; C@
  !16 eq0 ; 0=
  !16 branch_if, .WORD_2
  !16 DUP
  !16 EXIT
.WORD_2:
  !16 DUP
.WORD_4:
  !16 DUP
  !16 c_load ; C@
  !16 DUP
  !16 lit, 0x0020
  !16 neq ; <>
  !16 OVER
  !16 neq0 ; 0<>
  !16 _and ; AND
  !16 OVER
  !16 lit, 0x0009
  !16 neq ; <>
  !16 _and ; AND
  !16 OVER
  !16 lit, 0x000a
  !16 neq ; <>
  !16 _and ; AND
  !16 OVER
  !16 lit, 0x000d
  !16 neq ; <>
  !16 _and ; AND
  !16 NIP
  !16 branch_if, .WORD_3
  !16 add1 ; 1+
  !16 branch, .WORD_4
.WORD_3:
  !16 DUP
  !16 c_load ; C@
  !16 branch_if, .WORD_5
  !16 lit, 0x0000
  !16 OVER
  !16 c_store ; C!
  !16 add1 ; 1+
.WORD_5:
  !16 SWAP
  !16 EXIT

!text 0, "SPLIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SPLIT:
  ent
  !16 SWAP
.SPLIT_1:
  !16 OVER
  !16 OVER
  !16 c_load ; C@
  !16 eq ; =
  !16 branch_if, .SPLIT_0
  !16 add1 ; 1+
  !16 branch, .SPLIT_1
.SPLIT_0:
  !16 TUCK
.SPLIT_3:
  !16 OVER
  !16 OVER
  !16 c_load ; C@
  !16 neq ; <>
  !16 OVER
  !16 c_load ; C@
  !16 neq0 ; 0<>
  !16 _and ; AND
  !16 branch_if, .SPLIT_2
  !16 add1 ; 1+
  !16 branch, .SPLIT_3
.SPLIT_2:
  !16 DUP
  !16 c_load ; C@
  !16 branch_if, .SPLIT_4
  !16 lit, 0x0000
  !16 OVER
  !16 c_store ; C!
  !16 add1 ; 1+
.SPLIT_4:
  !16 NIP
  !16 SWAP
  !16 EXIT

!text 0, "STRCMP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STRCMP:
  ent
  !16 _2dup ; 2DUP
  !16 STRLEN
  !16 SWAP
  !16 STRLEN
  !16 MIN
  !16 add1 ; 1+
  !16 MEMCMP
  !16 EXIT

!text 0, "ISUNUM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ISUNUM:
  ent
  !16 DUP
  !16 lit, 0x0040
  !16 gt ; >
  !16 branch_if, .ISUNUM_0
  !16 lit, 0x0007
  !16 _sub ; -
.ISUNUM_0:
  !16 lit, 0x0030
  !16 _sub ; -
  !16 DUP
  !16 lt0 ; 0<
  !16 SWAP
  !16 RADIX
  !16 load ; @
  !16 sub1 ; 1-
  !16 gt ; >
  !16 OR
  !16 eq0 ; 0=
  !16 EXIT

!text 0, "ISNUM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ISNUM:
  ent
  !16 DUP
  !16 ISUNUM
  !16 SWAP
  !16 lit, 0x002d
  !16 eq ; =
  !16 OR
  !16 EXIT

!text 0, "UATOI", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UATOI:
  ent
  !16 lit, 0x0000
.UATOI_2:
  !16 OVER
  !16 c_load ; C@
  !16 DUP
  !16 lit, 0x0040
  !16 gt ; >
  !16 branch_if, .UATOI_0
  !16 lit, 0x0007
  !16 _sub ; -
.UATOI_0:
  !16 lit, 0x0030
  !16 _sub ; -
  !16 DUP
  !16 lt0 ; 0<
  !16 OVER
  !16 RADIX
  !16 load ; @
  !16 ge ; >=
  !16 OR
  !16 eq0 ; 0=
  !16 branch_if, .UATOI_1
  !16 SWAP
  !16 RADIX
  !16 load ; @
  !16 umul ; U*
  !16 _add ; +
  !16 SWAP
  !16 add1 ; 1+
  !16 SWAP
  !16 branch, .UATOI_2
.UATOI_1:
  !16 DROP
  !16 NIP
  !16 EXIT

!text 0, "ATOI", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ATOI:
  ent
  !16 DUP
  !16 c_load ; C@
  !16 lit, 0x002d
  !16 eq ; =
  !16 branch_if, .ATOI_0
  !16 add1 ; 1+
  !16 UATOI
  !16 NEGATE
  !16 branch, .ATOI_1
.ATOI_0:
  !16 UATOI
.ATOI_1:
  !16 EXIT

!text 0, "HEX", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
HEX:
  ent
  !16 lit, 0x0010
  !16 RADIX
  !16 store ; !
  !16 EXIT

!text 0, "DECIMAL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
DECIMAL:
  ent
  !16 lit, 0x000a
  !16 RADIX
  !16 store ; !
  !16 EXIT

!text 0, "TICK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TICK:
  wai
  nxt

!text 0, "RBP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rbp_store:
  pla
  mmu #$00
  nxt

!text 0, "TERMADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TERMADDR:
  ent
  !16 DOVAR, 0x0001

!text 0, "PAGE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PAGE:
  ent
  !16 TERMADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0000
  !16 lit, 0x0303
  !16 c_store ; C!
  !16 lit, 0x0020
  !16 lit, 0x0308
  !16 c_store ; C!
  !16 lit, 0x0000
  !16 lit, 0x030a
  !16 store ; !
  !16 lit, 0x3250
  !16 lit, 0x030c
  !16 store ; !
  !16 lit, 0x0001
  !16 lit, 0x0307
  !16 c_store ; C!
.PAGE_0:
  !16 lit, 0x0307
  !16 c_load ; C@
  !16 eq0 ; 0=
  !16 TICK
  !16 branch_if, .PAGE_0
  !16 lit, 0x0001
  !16 lit, 0x0301
  !16 store ; !
  !16 lit, 0x0002
  !16 lit, 0x0303
  !16 c_store ; C!
  !16 EXIT

!text 0, "SCROLL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SCROLL:
  ent
  !16 TERMADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0000
  !16 lit, 0x0303
  !16 c_store ; C!
  !16 lit, 0x0100
  !16 lit, 0x0308
  !16 store ; !
  !16 lit, 0x0000
  !16 lit, 0x030a
  !16 store ; !
  !16 lit, 0x3150
  !16 lit, 0x030c
  !16 store ; !
  !16 lit, 0x0003
  !16 lit, 0x0307
  !16 c_store ; C!
.SCROLL_0:
  !16 lit, 0x0307
  !16 c_load ; C@
  !16 eq0 ; 0=
  !16 TICK
  !16 branch_if, .SCROLL_0
  !16 lit, 0x0020
  !16 lit, 0x0308
  !16 c_store ; C!
  !16 lit, 0x3100
  !16 lit, 0x030a
  !16 store ; !
  !16 lit, 0x0150
  !16 lit, 0x030c
  !16 store ; !
  !16 lit, 0x0001
  !16 lit, 0x0307
  !16 c_store ; C!
.SCROLL_1:
  !16 lit, 0x0307
  !16 c_load ; C@
  !16 eq0 ; 0=
  !16 TICK
  !16 branch_if, .SCROLL_1
  !16 lit, 0x0002
  !16 lit, 0x0303
  !16 c_store ; C!
  !16 EXIT

!text 0, "CR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CR:
  ent
  !16 TERMADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 c_load ; C@
  !16 lit, 0x0030
  !16 gt ; >
  !16 branch_if, .CR_0
  !16 SCROLL
  !16 branch, .CR_1
.CR_0:
  !16 lit, 0x0302
  !16 c_load ; C@
  !16 add1 ; 1+
  !16 lit, 0x0302
  !16 c_store ; C!
.CR_1:
  !16 lit, 0x0000
  !16 lit, 0x0301
  !16 c_store ; C!
  !16 EXIT

!text 0, "EMIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
EMIT:
  ent
  !16 TERMADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 c_load ; C@
  !16 lit, 0x0300
  !16 c_store ; C!
  !16 lit, 0x0301
  !16 c_load ; C@
  !16 lit, 0x0310
  !16 _add ; +
  !16 c_store ; C!
  !16 lit, 0x0301
  !16 c_load ; C@
  !16 lit, 0x004e
  !16 gt ; >
  !16 branch_if, .EMIT_0
  !16 CR
  !16 branch, .EMIT_1
.EMIT_0:
  !16 lit, 0x0301
  !16 c_load ; C@
  !16 add1 ; 1+
  !16 lit, 0x0301
  !16 c_store ; C!
.EMIT_1:
  !16 EXIT

!text 0, "BS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BS:
  sep #$20
!as
  lda $0dc4
  mmu #$00
  lda $0301
  beq .BS_0
  dec
  sta $0301
  tax
  lda $0302
  sta $0300
  lda #$20
  sta $0310,x
.BS_0:
  rep #$20
!al
  nxt

!text 0, "KEY?", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
is_key:
  sep #$20
!as
  lda $0dc4
  mmu #$00
  lda $0304
  cmp $0305
  rep #$20
!al
  beq .is_key_0
  pea $ffff
  nxt
.is_key_0:
  pea $0000
  nxt

!text 0, "KEY", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
KEY:
  sep #$20
!as
  lda $0dc4
  mmu #$00
.KEY_1:
  lda $0304
  cmp $0305
  bne .KEY_0
  wai
  bra .KEY_1
.KEY_0:
  lda $0306
  zea
  inc $0304
  rep #$20
!al
  pha
  nxt

!text 0, "AT-XY", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
at_xy:
  sep #$20
!as
  lda $0dc4
  mmu #$00
  plx
  txa
  sta $0302
  plx
  txa
  sta $0301
  rep #$20
!al
  nxt

!text 0, "(.\")", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_str_lit:
  ent
  !16 pull_r ; R>
.print_str_lit_1:
  !16 DUP
  !16 c_load ; C@
  !16 dup_if ; ?DUP
  !16 branch_if, .print_str_lit_0
  !16 EMIT
  !16 add1 ; 1+
  !16 branch, .print_str_lit_1
.print_str_lit_0:
  !16 add1 ; 1+
  !16 push_r ; >R
  !16 EXIT

!text 0, "SPACE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SPACE:
  ent
  !16 BL
  !16 EMIT
  !16 EXIT

!text 0, "TYPE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TYPE:
  ent
.TYPE_1:
  !16 DUP
  !16 c_load ; C@
  !16 dup_if ; ?DUP
  !16 branch_if, .TYPE_0
  !16 EMIT
  !16 add1 ; 1+
  !16 branch, .TYPE_1
.TYPE_0:
  !16 DROP
  !16 EXIT

!text 0, ".", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_int:
  ent
  !16 DUP
  !16 lt0 ; 0<
  !16 branch_if, .print_int_0
  !16 NEGATE
  !16 UITOA
  !16 sub1 ; 1-
  !16 lit, 0x002d
  !16 OVER
  !16 c_store ; C!
  !16 branch, .print_int_1
.print_int_0:
  !16 UITOA
.print_int_1:
  !16 TYPE
  !16 SPACE
  !16 EXIT

!text 0, "U.", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_uint:
  ent
  !16 UITOA
  !16 TYPE
  !16 SPACE
  !16 EXIT

!text 0, "/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
div_mod:
  ent
  !16 OVER
  !16 lt0 ; 0<
  !16 SWAP
  !16 fm_div_mod ; FM/MOD
  !16 EXIT

!text 0, "/", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_div:
  ent
  !16 div_mod ; /MOD
  !16 DROP
  !16 EXIT

!text 0, "MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MOD:
  ent
  !16 div_mod ; /MOD
  !16 NIP
  !16 EXIT

!text 0, "ABORT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ABORT:
  ent
  !16 SP0
  !16 sp_store ; SP!
  !16 QUIT

!text 0, "TIBPTR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBPTR:
  ent
  !16 DOVAR, 0x0000

!text 0, "VOCAB", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
VOCAB:
  ent
  !16 DOVAR, COLD

!text 0, "(HERE)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
here_var:
  ent
  !16 DOVAR, end

!text 0, "HERE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HERE:
  ent
  !16 here_var ; (HERE)
  !16 load ; @
  !16 EXIT

!text 0, "TOP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TOP:
  ent
  !16 DOVAR, 0x0000

!text 0, "STATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STATE:
  ent
  !16 DOVAR, 0x0000

!text 0, "PROBE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PROBE:
  ent
  !16 lit, 0x1fff
.PROBE_1:
  !16 DUP
  !16 lit, 0x2000
  !16 _add ; +
  !16 DUP
  !16 c_load ; C@
  !16 DUP
  !16 INVERT
  !16 _2over ; 2OVER
  !16 store ; !
  !16 DUP
  !16 _2over ; 2OVER
  !16 c_load ; C@
  !16 eq ; =
  !16 SWAP
  !16 _2over ; 2OVER
  !16 c_store ; C!
  !16 branch_if, .PROBE_0
  !16 DROP
  !16 EXIT
.PROBE_0:
  !16 NIP
  !16 DUP
  !16 lit, 0xffff
  !16 eq ; =
  !16 branch_if, .PROBE_1
  !16 EXIT

!text 0, "FREE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FREE:
  ent
  !16 TOP
  !16 load ; @
  !16 HERE
  !16 _sub ; -
  !16 EXIT

!text 0, "ALLOT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ALLOT:
  ent
  !16 DUP
  !16 lit, 0x0002
  !16 _add ; +
  !16 FREE
  !16 ugt ; U>
  !16 branch_if, .ALLOT_0
  !16 print_str_lit ; (.")
  !text "Out of memory", 0
  !16 CR
  !16 ABORT
.ALLOT_0:
  !16 HERE
  !16 SWAP
  !16 here_var ; (HERE)
  !16 inc_word ; +!
  !16 EXIT

!text 0, ",", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push:
  ent
  !16 CELL
  !16 ALLOT
  !16 store ; !
  !16 EXIT

!text 0, ",C", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push_char:
  ent
  !16 lit, 0x0001
  !16 ALLOT
  !16 c_store ; C!
  !16 EXIT

!text 0, ",S", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push_str:
  ent
.allot_push_str_1:
  !16 DUP
  !16 c_load ; C@
  !16 branch_if, .allot_push_str_0
  !16 DUP
  !16 c_load ; C@
  !16 allot_push_char ; ,C
  !16 add1 ; 1+
  !16 branch, .allot_push_str_1
.allot_push_str_0:
  !16 DROP
  !16 lit, 0x0000
  !16 allot_push_char ; ,C
  !16 EXIT

!text 0, "TIBWORD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBWORD:
  ent
  !16 TIBPTR
  !16 load ; @
  !16 WORD
  !16 SWAP
  !16 TIBPTR
  !16 store ; !
  !16 EXIT

!text 0, "TIBSPLIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBSPLIT:
  ent
  !16 TIBPTR
  !16 load ; @
  !16 SWAP
  !16 SPLIT
  !16 SWAP
  !16 TIBPTR
  !16 store ; !
  !16 EXIT

!text 0, "HEADER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HEADER:
  ent
  !16 lit, 0x0000
  !16 allot_push_char ; ,C
  !16 TIBWORD
  !16 allot_push_str ; ,S
  !16 lit, 0x0000
  !16 allot_push_char ; ,C
  !16 VOCAB
  !16 load ; @
  !16 allot_push ; ,
  !16 HERE
  !16 VOCAB
  !16 store ; !
  !16 EXIT

!text 0, "CONSTANT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CONSTANT:
  ent
  !16 HEADER
  !16 lit, 0x0022
  !16 allot_push_char ; ,C
  !16 lit, DOCON
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 EXIT

!text 0, "CREATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CREATE:
  ent
  !16 HEADER
  !16 lit, 0x0022
  !16 allot_push_char ; ,C
  !16 lit, DOVAR
  !16 allot_push ; ,
  !16 EXIT

!text 0, "VARIABLE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
VARIABLE:
  ent
  !16 CREATE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 EXIT

!text 0, "[", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
comp_enter:
  ent
  !16 lit, 0x0001
  !16 STATE
  !16 store ; !
  !16 EXIT

!text 0, "]", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
comp_exit:
  ent
  !16 lit, 0x0000
  !16 STATE
  !16 store ; !
  !16 EXIT

!text 0, "HIDE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HIDE:
  ent
  !16 VOCAB
  !16 load ; @
  !16 lit, 0x0003
  !16 _sub ; -
  !16 DUP
  !16 c_load ; C@
  !16 lit, .FLAG_HIDE
  !16 OR
  !16 SWAP
  !16 c_store ; C!
  !16 EXIT

!text 0, "REVEAL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
REVEAL:
  ent
  !16 VOCAB
  !16 load ; @
  !16 lit, 0x0003
  !16 _sub ; -
  !16 DUP
  !16 c_load ; C@
  !16 lit, .FLAG_IMM
  !16 _and ; AND
  !16 SWAP
  !16 c_store ; C!
  !16 EXIT

!text 0, "IMMEDIATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IMMEDIATE:
  ent
  !16 VOCAB
  !16 load ; @
  !16 lit, 0x0003
  !16 _sub ; -
  !16 DUP
  !16 c_load ; C@
  !16 lit, .FLAG_IMM
  !16 OR
  !16 SWAP
  !16 c_store ; C!
  !16 EXIT

!text 0, "(does)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_does:
  ent
  !16 pull_r ; R>
  !16 VOCAB
  !16 load ; @
  !16 add1 ; 1+
  !16 store ; !
  !16 EXIT

!text 0, "DOES>", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
does_right:
  ent
  !16 lit, _does
  !16 allot_push ; ,
  !16 lit, 0x0022
  !16 allot_push_char ; ,C
  !16 lit, DODOES
  !16 allot_push ; ,
  !16 EXIT

!text 0, ":", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
compile:
  ent
  !16 HEADER
  !16 HIDE
  !16 lit, 0x0022
  !16 allot_push_char ; ,C
  !16 comp_enter ; [
  !16 EXIT

!text 0, ";", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
compile_end:
  ent
  !16 lit, EXIT
  !16 allot_push ; ,
  !16 comp_exit ; ]
  !16 REVEAL
  !16 EXIT

!text 0, "IF", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
IF:
  ent
  !16 lit, branch_if
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 lit, 0x0000
  !16 EXIT

!text 0, "THEN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
THEN:
  ent
  !16 DROP
  !16 HERE
  !16 SWAP
  !16 store ; !
  !16 EXIT

!text 0, "ELSE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
ELSE:
  ent
  !16 DROP
  !16 lit, branch
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 SWAP
  !16 HERE
  !16 SWAP
  !16 store ; !
  !16 lit, 0x0000
  !16 EXIT

!text 0, ".\"", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
print_str:
  ent
  !16 lit, print_str_lit
  !16 allot_push ; ,
  !16 lit, 0x0022
  !16 TIBSPLIT
  !16 allot_push_str ; ,S
  !16 EXIT

!text 0, "BEGIN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
BEGIN:
  ent
  !16 HERE
  !16 lit, 0x0000
  !16 EXIT

!text 0, "AGAIN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
AGAIN:
  ent
  !16 DROP
  !16 lit, branch
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 EXIT

!text 0, "UNTIL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
UNTIL:
  ent
  !16 DROP
  !16 lit, branch_if
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 EXIT

!text 0, "WHILE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
WHILE:
  ent
  !16 lit, branch_if
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 lit, 0x0000
  !16 EXIT

!text 0, "REPEAT", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
REPEAT:
  ent
  !16 DROP
  !16 NIP
  !16 SWAP
  !16 lit, branch
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 HERE
  !16 SWAP
  !16 store ; !
  !16 EXIT

!text 0, "DO", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
DO:
  ent
  !16 lit, do
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 HERE
  !16 SWAP
  !16 EXIT

!text 0, "?DO", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
do_if:
  ent
  !16 lit, _do_if
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 HERE
  !16 SWAP
  !16 EXIT

!text 0, "LOOP", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LOOP:
  ent
  !16 SWAP
  !16 lit, loop
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 lit, UNLOOP
  !16 allot_push ; ,
  !16 HERE
  !16 SWAP
  !16 store ; !
  !16 EXIT

!text 0, "+LOOP", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
loop_add:
  ent
  !16 SWAP
  !16 lit, _loop_add
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 lit, UNLOOP
  !16 allot_push ; ,
  !16 HERE
  !16 SWAP
  !16 store ; !
  !16 EXIT

!text 0, "LEAVE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LEAVE:
  ent
  !16 lit, 0x0001
.LEAVE_1:
  !16 DUP
  !16 PICK
  !16 eq0 ; 0=
  !16 branch_if, .LEAVE_0
  !16 lit, 0x0002
  !16 _add ; +
  !16 branch, .LEAVE_1
.LEAVE_0:
  !16 lit, leave
  !16 allot_push ; ,
  !16 PICK
  !16 lit, 0x0002
  !16 _sub ; -
  !16 allot_push ; ,
  !16 EXIT

!text 0, "\\", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
line_comment:
  ent
  !16 lit, 0x000d
  !16 TIBSPLIT
  !16 DROP
  !16 EXIT

!text 0, "(", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
paren_comment:
  ent
  !16 lit, 0x0029
  !16 TIBSPLIT
  !16 DROP
  !16 EXIT

!text 0, "(\")", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
str_lit:
  ent
  !16 pull_r ; R>
  !16 DUP
.str_lit_1:
  !16 DUP
  !16 c_load ; C@
  !16 branch_if, .str_lit_0
  !16 add1 ; 1+
  !16 branch, .str_lit_1
.str_lit_0:
  !16 add1 ; 1+
  !16 push_r ; >R
  !16 EXIT

!text 0, "\"", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
str:
  ent
  !16 lit, str_lit
  !16 allot_push ; ,
  !16 lit, 0x0022
  !16 TIBSPLIT
  !16 allot_push_str ; ,S
  !16 EXIT

!text 0, "TIMES", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
TIMES:
  ent
  !16 STATE
  !16 load ; @
  !16 eq0 ; 0=
  !16 branch_if, .TIMES_0
  !16 find_name ; '
  !16 SWAP
  !16 lit, 0x0000
  !16 _do_if, .TIMES_1
.TIMES_2:
  !16 DUP
  !16 EXECUTE
  !16 loop, .TIMES_2
  !16 UNLOOP
.TIMES_1:
  !16 DROP
  !16 branch, .TIMES_3
.TIMES_0:
  !16 find_name ; '
  !16 lit, lit
  !16 allot_push ; ,
  !16 lit, 0x0000
  !16 allot_push ; ,
  !16 lit, _do_if
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x000a
  !16 _add ; +
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 HERE
  !16 lit, 0x0002
  !16 _sub ; -
  !16 lit, loop
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 lit, UNLOOP
  !16 allot_push ; ,
.TIMES_3:
  !16 EXIT

!text 0, "LITERAL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LITERAL:
  ent
  !16 find_name ; '
  !16 lit, lit
  !16 allot_push ; ,
  !16 allot_push ; ,
  !16 EXIT

!text 0, "POSTPONE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
POSTPONE:
  ent
  !16 find_name ; '
  !16 DUP
  !16 lit, 0x0003
  !16 _sub ; -
  !16 c_load ; C@
  !16 lit, 0x0001
  !16 _and ; AND
  !16 branch_if, .POSTPONE_0
  !16 allot_push ; ,
  !16 branch, .POSTPONE_1
.POSTPONE_0:
  !16 lit, lit
  !16 allot_push ; ,
  !16 allot_push ; ,
.POSTPONE_1:
  !16 EXIT

!text 0, "RECURSE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
RECURSE:
  ent
  !16 VOCAB
  !16 load ; @
  !16 allot_push ; ,
  !16 EXIT

!text 0, "TICKS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TICKS:
  ent
.TICKS_1:
  !16 dup_if ; ?DUP
  !16 branch_if, .TICKS_0
  !16 TICK
  !16 sub1 ; 1-
  !16 branch, .TICKS_1
.TICKS_0:
  !16 EXIT

!text 0, "SP0", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SP0:
  ent
  !16 DOCON, 0x0200

!text 0, "RP0", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RP0:
  ent
  !16 DOCON, 0x0300

!text 0, ">NAME", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
to_name:
  ent
  !16 lit, 0x0005
  !16 _sub ; -
  !16 DUP
  !16 RSTRLEN
  !16 _sub ; -
  !16 add1 ; 1+
  !16 EXIT

!text 0, "NAME>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
from_name:
  ent
  !16 DUP
  !16 STRLEN
  !16 _add ; +
  !16 lit, 0x0006
  !16 _add ; +
  !16 EXIT

!text 0, "FIND", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FIND:
  ent
  !16 VOCAB
  !16 load ; @
.FIND_4:
  !16 DUP
  !16 branch_if, .FIND_0
  !16 _2dup ; 2DUP
  !16 to_name ; >NAME
  !16 STRCMP
  !16 eq0 ; 0=
  !16 OVER
  !16 lit, 0x0003
  !16 _sub ; -
  !16 c_load ; C@
  !16 lit, 0x0002
  !16 _and ; AND
  !16 eq0 ; 0=
  !16 _and ; AND
  !16 branch_if, .FIND_1
  !16 TRUE
  !16 branch, .FIND_2
.FIND_1:
  !16 CELL
  !16 _sub ; -
  !16 load ; @
  !16 FALSE
.FIND_2:
  !16 branch, .FIND_3
.FIND_0:
  !16 TRUE
.FIND_3:
  !16 branch_if, .FIND_4
  !16 NIP
  !16 EXIT

!text 0, "ACCEPT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ACCEPT:
  ent
  !16 OVER
  !16 _add ; +
  !16 sub1 ; 1-
  !16 OVER
.ACCEPT_4:
  !16 KEY
  !16 DUP
  !16 lit, 0x000d
  !16 neq ; <>
  !16 branch_if, .ACCEPT_0
  !16 DUP
  !16 lit, 0x0008
  !16 eq ; =
  !16 branch_if, .ACCEPT_1
  !16 DROP
  !16 _2over ; 2OVER
  !16 OVER
  !16 lt ; <
  !16 branch_if, .ACCEPT_2
  !16 BS
  !16 sub1 ; 1-
.ACCEPT_2:
  !16 branch, .ACCEPT_3
.ACCEPT_1:
  !16 DUP
  !16 EMIT
  !16 OVER
  !16 c_store ; C!
  !16 add1 ; 1+
  !16 OVER
  !16 MIN
.ACCEPT_3:
  !16 branch, .ACCEPT_4
.ACCEPT_0:
  !16 DROP
  !16 MIN
  !16 lit, 0x0000
  !16 SWAP
  !16 c_store ; C!
  !16 EXIT

!text 0, "0SP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_0sp:
  ent
  !16 SP0
  !16 sp_store ; SP!
  !16 EXIT

!text 0, "INTERPRET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
INTERPRET:
  ent
.INTERPRET_10:
  !16 WORD
  !16 DUP
  !16 STRLEN
  !16 neq0 ; 0<>
  !16 branch_if, .INTERPRET_0
  !16 SWAP
  !16 TIBPTR
  !16 store ; !
  !16 DUP
  !16 FIND
  !16 dup_if ; ?DUP
  !16 branch_if, .INTERPRET_1
  !16 NIP
  !16 STATE
  !16 load ; @
  !16 branch_if, .INTERPRET_2
  !16 DUP
  !16 lit, 0x0003
  !16 _sub ; -
  !16 c_load ; C@
  !16 lit, 0x0001
  !16 _and ; AND
  !16 branch_if, .INTERPRET_3
  !16 EXECUTE
  !16 branch, .INTERPRET_4
.INTERPRET_3:
  !16 allot_push ; ,
.INTERPRET_4:
  !16 branch, .INTERPRET_5
.INTERPRET_2:
  !16 EXECUTE
.INTERPRET_5:
  !16 branch, .INTERPRET_6
.INTERPRET_1:
  !16 DUP
  !16 c_load ; C@
  !16 ISNUM
  !16 branch_if, .INTERPRET_7
  !16 ATOI
  !16 STATE
  !16 load ; @
  !16 branch_if, .INTERPRET_8
  !16 lit, lit
  !16 allot_push ; ,
  !16 allot_push ; ,
.INTERPRET_8:
  !16 branch, .INTERPRET_6
.INTERPRET_7:
  !16 print_str_lit ; (.")
  !text "Unknown Token: ", 0
  !16 TYPE
  !16 CR
  !16 ABORT
.INTERPRET_6:
  !16 TIBPTR
  !16 load ; @
  !16 branch, .INTERPRET_10
.INTERPRET_0:
  !16 DROP
  !16 DROP
  !16 EXIT

!text 0, "QUIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
QUIT:
  ent
  !16 RP0
  !16 rp_store ; RP!
  !16 lit, 0x0000
  !16 STATE
  !16 store ; !
.QUIT_3:
  !16 DEPTH
  !16 lt0 ; 0<
  !16 branch_if, .QUIT_0
  !16 print_str_lit ; (.")
  !text "Empty Stack", 0
  !16 SP0
  !16 sp_store ; SP!
.QUIT_0:
  !16 CR
  !16 STATE
  !16 load ; @
  !16 eq0 ; 0=
  !16 branch_if, .QUIT_1
  !16 print_str_lit ; (.")
  !text "> ", 0
  !16 branch, .QUIT_2
.QUIT_1:
  !16 print_str_lit ; (.")
  !text "compile: ", 0
.QUIT_2:
  !16 TIB
  !16 lit, 0x0078
  !16 ACCEPT
  !16 SPACE
  !16 INTERPRET
  !16 branch, .QUIT_3

!text 0, "WORDS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WORDS:
  ent
  !16 VOCAB
  !16 load ; @
.WORDS_1:
  !16 DUP
  !16 branch_if, .WORDS_0
  !16 DUP
  !16 to_name ; >NAME
  !16 TYPE
  !16 SPACE
  !16 CELL
  !16 _sub ; -
  !16 load ; @
  !16 branch, .WORDS_1
.WORDS_0:
  !16 DROP
  !16 EXIT

!text 0, "DEPTH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DEPTH:
  ent
  !16 sp_load ; SP@
  !16 SP0
  !16 SWAP
  !16 _sub ; -
  !16 div2 ; 2/
  !16 EXIT

!text 0, ".S", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_stack:
  ent
  !16 DEPTH
  !16 DUP
  !16 lit, 0x0000
  !16 _do_if, .print_stack_0
.print_stack_1:
  !16 DUP
  !16 I
  !16 _sub ; -
  !16 PICK
  !16 print_int ; .
  !16 loop, .print_stack_1
  !16 UNLOOP
.print_stack_0:
  !16 DROP
  !16 EXIT

!text 0, "'", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
find_name:
  ent
  !16 TIBWORD
  !16 DUP
  !16 FIND
  !16 dup_if ; ?DUP
  !16 eq0 ; 0=
  !16 branch_if, .find_name_0
  !16 print_str_lit ; (.")
  !text "Unknown Token: ", 0
  !16 TYPE
  !16 CR
  !16 ABORT
  !16 branch, .find_name_1
.find_name_0:
  !16 NIP
.find_name_1:
  !16 EXIT

!text 0, "FORGET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FORGET:
  ent
  !16 find_name ; '
  !16 DUP
  !16 to_name ; >NAME
  !16 sub1 ; 1-
  !16 here_var ; (HERE)
  !16 store ; !
  !16 CELL
  !16 _sub ; -
  !16 load ; @
  !16 VOCAB
  !16 store ; !
  !16 EXIT

!text 0, "IOXADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXADDR:
  ent
  !16 DOVAR, 0x0003

!text 0, "IOX@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
iox_read:
  ent
  !16 IOXADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0300
  !16 load ; @
  !16 EXIT

!text 0, "IOX!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
iox_write:
  ent
  !16 IOXADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 store ; !
  !16 EXIT

!text 0, "IOXSET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXSET:
  ent
  !16 IOXADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 load ; @
  !16 OR
  !16 lit, 0x0302
  !16 store ; !
  !16 EXIT

!text 0, "IOXRST", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXRST:
  ent
  !16 IOXADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 INVERT
  !16 lit, 0x0302
  !16 load ; @
  !16 _and ; AND
  !16 lit, 0x0302
  !16 store ; !
  !16 EXIT

!text 0, "DISKADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKADDR:
  ent
  !16 DOVAR, 0x0002

!text 0, "DISKNAME\"", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
diskname_str:
  ent
  !16 lit, 0x0022
  !16 TIBSPLIT
  !16 DISKADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0300
  !16 OVER
  !16 STRLEN
  !16 add1 ; 1+
  !16 MOVE
  !16 lit, 0x0002
  !16 lit, 0x0382
  !16 c_store ; C!
.diskname_str_1:
  !16 lit, 0x0382
  !16 c_load ; C@
  !16 lit, 0x0002
  !16 eq ; =
  !16 branch_if, .diskname_str_0
  !16 TICK
  !16 branch, .diskname_str_1
.diskname_str_0:
  !16 EXIT

!text 0, "DISKID", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKID:
  ent
  !16 DISKADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0003
  !16 lit, 0x0382
  !16 c_store ; C!
.DISKID_1:
  !16 lit, 0x0382
  !16 c_load ; C@
  !16 lit, 0x0003
  !16 eq ; =
  !16 branch_if, .DISKID_0
  !16 TICK
  !16 branch, .DISKID_1
.DISKID_0:
  !16 lit, 0x0300
  !16 SCRATCH
  !16 lit, 0x0040
  !16 MOVE
  !16 SCRATCH
  !16 TYPE
  !16 EXIT

!text 0, "DISKWS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKWS:
  ent
  !16 DISKADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0380
  !16 store ; !
  !16 lit, 0x0300
  !16 lit, 0x0080
  !16 MOVE
  !16 lit, 0x0005
  !16 lit, 0x0382
  !16 c_store ; C!
.DISKWS_1:
  !16 lit, 0x0382
  !16 c_load ; C@
  !16 lit, 0x0005
  !16 eq ; =
  !16 branch_if, .DISKWS_0
  !16 TICK
  !16 branch, .DISKWS_1
.DISKWS_0:
  !16 EXIT

!text 0, "DISKRS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKRS:
  ent
  !16 DISKADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0380
  !16 store ; !
  !16 lit, 0x0004
  !16 lit, 0x0382
  !16 c_store ; C!
.DISKRS_1:
  !16 lit, 0x0382
  !16 c_load ; C@
  !16 lit, 0x0004
  !16 eq ; =
  !16 branch_if, .DISKRS_0
  !16 TICK
  !16 branch, .DISKRS_1
.DISKRS_0:
  !16 lit, 0x0300
  !16 SWAP
  !16 lit, 0x0080
  !16 MOVE
  !16 EXIT

!text 0, "SAVE\"", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
save_str:
  ent
  !16 diskname_str ; DISKNAME"
  !16 lit, start
  !16 HERE
  !16 lit, 0x0481
  !16 _sub ; -
  !16 lit, 0x0007
  !16 shr ; U>>
  !16 lit, 0x0000
  !16 do, .save_str_0
.save_str_1:
  !16 DUP
  !16 I
  !16 DISKWS
  !16 lit, 0x0080
  !16 _add ; +
  !16 loop, .save_str_1
  !16 UNLOOP
.save_str_0:
  !16 EXIT

!text 0, "(blkbuf)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkbuf:
  ent
  !16 DOVAR, 0x0000

!text 0, "(blkno)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkno:
  ent
  !16 DOVAR, 0x0000

!text 0, "(blkup)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkup:
  ent
  !16 DOVAR, 0x0000

!text 0, "(blkload)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkload:
  ent
  !16 DOVAR, 0x0000

!text 0, "FLUSH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FLUSH:
  ent
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 blkno ; (blkno)
  !16 load ; @
  !16 sub1 ; 1-
  !16 lit, 0x0003
  !16 shl ; <<
  !16 lit, 0x0008
  !16 lit, 0x0000
  !16 do, .FLUSH_0
.FLUSH_1:
  !16 _2dup ; 2DUP
  !16 DISKWS
  !16 SWAP
  !16 lit, 0x0080
  !16 _add ; +
  !16 SWAP
  !16 add1 ; 1+
  !16 loop, .FLUSH_1
  !16 UNLOOP
.FLUSH_0:
  !16 _2drop ; 2DROP
  !16 lit, 0x0000
  !16 blkup ; (blkup)
  !16 store ; !
  !16 EXIT

!text 0, "REVERT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
REVERT:
  ent
  !16 lit, 0x0000
  !16 blkup ; (blkup)
  !16 store ; !
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 blkno ; (blkno)
  !16 load ; @
  !16 sub1 ; 1-
  !16 lit, 0x0003
  !16 shl ; <<
  !16 lit, 0x0008
  !16 lit, 0x0000
  !16 do, .REVERT_0
.REVERT_1:
  !16 _2dup ; 2DUP
  !16 DISKRS
  !16 SWAP
  !16 lit, 0x0080
  !16 _add ; +
  !16 SWAP
  !16 add1 ; 1+
  !16 loop, .REVERT_1
  !16 UNLOOP
.REVERT_0:
  !16 _2drop ; 2DROP
  !16 EXIT

!text 0, "BLOCK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BLOCK:
  ent
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 eq0 ; 0=
  !16 branch_if, .BLOCK_0
  !16 lit, 0x0400
  !16 ALLOT
  !16 blkbuf ; (blkbuf)
  !16 store ; !
.BLOCK_0:
  !16 DUP
  !16 blkno ; (blkno)
  !16 load ; @
  !16 eq ; =
  !16 branch_if, .BLOCK_1
  !16 DROP
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 EXIT
.BLOCK_1:
  !16 blkno ; (blkno)
  !16 load ; @
  !16 neq0 ; 0<>
  !16 branch_if, .BLOCK_2
  !16 FLUSH
.BLOCK_2:
  !16 blkno ; (blkno)
  !16 store ; !
  !16 REVERT
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 EXIT

!text 0, "UPDATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UPDATE:
  ent
  !16 lit, 0x0001
  !16 blkup ; (blkup)
  !16 store ; !
  !16 EXIT

!text 0, "LIST", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
LIST:
  ent
  !16 BLOCK
  !16 CR
  !16 lit, 0x000a
  !16 RADIX
  !16 store ; !
  !16 lit, 0x0010
  !16 lit, 0x0000
  !16 do, .LIST_0
.LIST_4:
  !16 I
  !16 lit, 0x000a
  !16 lt ; <
  !16 branch_if, .LIST_1
  !16 SPACE
.LIST_1:
  !16 I
  !16 print_int ; .
  !16 lit, 0x0040
  !16 lit, 0x0000
  !16 do, .LIST_2
.LIST_3:
  !16 DUP
  !16 c_load ; C@
  !16 EMIT
  !16 add1 ; 1+
  !16 loop, .LIST_3
  !16 UNLOOP
.LIST_2:
  !16 CR
  !16 loop, .LIST_4
  !16 UNLOOP
.LIST_0:
  !16 DROP
  !16 EXIT

!text 0, "WIPE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WIPE:
  ent
  !16 UPDATE
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 lit, 0x0400
  !16 lit, 0x0020
  !16 FILL
  !16 EXIT

!text 0, "PP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PP:
  ent
  !16 UPDATE
  !16 lit, 0x0006
  !16 shl ; <<
  !16 blkbuf ; (blkbuf)
  !16 load ; @
  !16 _add ; +
  !16 DUP
  !16 lit, 0x0040
  !16 lit, 0x0020
  !16 FILL
  !16 lit, 0x000d
  !16 TIBSPLIT
  !16 TUCK
  !16 STRLEN
  !16 lit, 0x0040
  !16 MIN
  !16 MOVE
  !16 EXIT

!text 0, "LOAD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
LOAD:
  ent
  !16 BLOCK
  !16 blkload ; (blkload)
  !16 store ; !
  !16 lit, 0x0000
  !16 TIB
  !16 lit, 0x0040
  !16 _add ; +
  !16 c_store ; C!
  !16 lit, 0x0010
  !16 lit, 0x0000
  !16 do, .LOAD_0
.LOAD_1:
  !16 blkload ; (blkload)
  !16 load ; @
  !16 TIB
  !16 lit, 0x0040
  !16 MOVE
  !16 TIB
  !16 TIBPTR
  !16 store ; !
  !16 TIB
  !16 INTERPRET
  !16 lit, 0x0040
  !16 blkload ; (blkload)
  !16 inc_word ; +!
  !16 loop, .LOAD_1
  !16 UNLOOP
.LOAD_0:
  !16 EXIT

!text 0, "SORTADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTADDR:
  ent
  !16 DOVAR, 0x0004

!text 0, "SORTCMD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTCMD:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 DUP
  !16 lit, 0x0300
  !16 c_store ; C!
.SORTCMD_1:
  !16 DUP
  !16 lit, 0x0300
  !16 c_load ; C@
  !16 eq ; =
  !16 branch_if, .SORTCMD_0
  !16 TICK
  !16 branch, .SORTCMD_1
.SORTCMD_0:
  !16 DROP
  !16 lit, 0x0300
  !16 c_load ; C@
  !16 lit, 0x00ff
  !16 eq ; =
  !16 branch_if, .SORTCMD_2
  !16 print_str_lit ; (.")
  !text "Sorter Error", 0
  !16 CR
  !16 ABORT
.SORTCMD_2:
  !16 EXIT

!text 0, "SORTSLOTS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTSLOTS:
  ent
  !16 lit, 0x0001
  !16 SORTCMD
  !16 lit, 0x0302
  !16 load ; @
  !16 EXIT

!text 0, "SORTSLOT@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortslot_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 store ; !
  !16 lit, 0x0002
  !16 SORTCMD
  !16 lit, 0x0306
  !16 load ; @
  !16 lit, 0x0304
  !16 load ; @
  !16 lit, 0x0301
  !16 c_load ; C@
  !16 EXIT

!text 0, "SORTPULL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTPULL:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0302
  !16 store ; !
  !16 lit, 0x0301
  !16 c_store ; C!
  !16 lit, 0x0003
  !16 SORTCMD
  !16 lit, 0x0301
  !16 c_load ; C@
  !16 EXIT

!text 0, "SORTCOLOR@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortcolor_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x030c
  !16 c_load ; C@
  !16 EXIT

!text 0, "SORTCOLOR!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortcolor_write:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x030c
  !16 c_store ; C!
  !16 EXIT

!text 0, "SORTPAT@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortpat_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0306
  !16 load ; @
  !16 lit, 0x0304
  !16 load ; @
  !16 EXIT

!text 0, "SORTPAT!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortpat_write:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0304
  !16 store ; !
  !16 lit, 0x0306
  !16 store ; !
  !16 EXIT

!text 0, "SORTINCOL@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortincol_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x030d
  !16 c_load ; C@
  !16 EXIT

!text 0, "SORTINCOL!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortincol_write:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x030d
  !16 c_store ; C!
  !16 EXIT

!text 0, "SORTDMG@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortdmg_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0308
  !16 load ; @
  !16 EXIT

!text 0, "SORTDMGMAX@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortdmgmax_read:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x030a
  !16 load ; @
  !16 EXIT

!text 0, "SORTMATCH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTMATCH:
  ent
  !16 SORTADDR
  !16 load ; @
  !16 rbp_store ; RBP!
  !16 lit, 0x0301
  !16 c_store ; C!
  !16 lit, 0x0004
  !16 SORTCMD
  !16 EXIT

!text 0, "COLD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
COLD:
  ent
  !16 lit, 0x0000
  !16 c_load ; C@
  !16 DISKADDR
  !16 store ; !
  !16 lit, 0x0001
  !16 c_load ; C@
  !16 TERMADDR
  !16 store ; !
  !16 CR
  !16 CR
  !16 print_str_lit ; (.")
  !text "MineOS XP V1.2 Initialized", 0
  !16 CR
  !16 PROBE
  !16 TOP
  !16 store ; !
  !16 FREE
  !16 print_uint ; U.
  !16 print_str_lit ; (.")
  !text "bytes free.", 0
  !16 CR
  !16 QUIT

end:
  !align 128, 0, 0
