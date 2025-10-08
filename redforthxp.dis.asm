;; output from deforth by shadlock0133 (aka Aurora :3)
!cpu 65el02
!set prev = 0
.FLAG_NONE = 0
.FLAG_IMM = 1
.FLAG_HIDE = 2

* = 0x0500
start:
  clc                            ; 0500: 18
  xce                            ; 0501: fb
  rep #$30                       ; 0502: c2 30
!al
!rl
  lda #$0300                     ; 0504: a9 00 03
  mmu #$01                       ; 0507: ef 01
  mmu #$02                       ; 0509: ef 02
  lda #$0400                     ; 050b: a9 00 04
  mmu #$03                       ; 050e: ef 03
  mmu #$04                       ; 0510: ef 04
  lda #$0500                     ; 0512: a9 00 05
  mmu #$06                       ; 0515: ef 06
  jmp COLD                       ; 0517: 4c 71 1f

!text 0, "DOCON", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DOCON:
  tix                            ; 0524: dc
  lda $00,x                      ; 0525: b5 00
  pha                            ; 0527: 48
  rli                            ; 0528: 2b
  nxt                            ; 0529: 02

!text 0, "DOVAR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DOVAR:
  tix                            ; 0534: dc
  phx                            ; 0535: da
  rli                            ; 0536: 2b
  nxt                            ; 0537: 02

!text 0, "DODOES", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DODOES:
  rlx                            ; 0543: 3b
  phx                            ; 0544: da
  nxt                            ; 0545: 02

!text 0, "(lit)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
lit:
  nxa                            ; 0550: 42
  pha                            ; 0551: 48
  nxt                            ; 0552: 02

!text 0, "EXIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
EXIT:
  rli                            ; 055c: 2b
  nxt                            ; 055d: 02

!text 0, "(branch)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
branch:
  nxa                            ; 056b: 42
  tax                            ; 056c: aa
  txi                            ; 056d: 5c
  nxt                            ; 056e: 02

!text 0, "(?branch)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
branch_if:
  pla                            ; 057d: 68
  nxa                            ; 057e: 42
  bne .branch_if_0               ; 057f: d0 02
  tax                            ; 0581: aa
  txi                            ; 0582: 5c
.branch_if_0:
  nxt                            ; 0583: 02

!text 0, "(do)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
do:
  nxa                            ; 058d: 42
  lda $02,s                      ; 058e: a3 02
  rha                            ; 0590: 4b
  pla                            ; 0591: 68
  sec                            ; 0592: 38
  sbc $00,s                      ; 0593: e3 00
  rha                            ; 0595: 4b
  pla                            ; 0596: 68
  nxt                            ; 0597: 02

!text 0, "(?do)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_do_if:
  nxa                            ; 05a2: 42
  tax                            ; 05a3: aa
  lda $02,s                      ; 05a4: a3 02
  rha                            ; 05a6: 4b
  pla                            ; 05a7: 68
  sec                            ; 05a8: 38
  sbc $00,s                      ; 05a9: e3 00
  beq ._do_if_0                  ; 05ab: f0 03
  rha                            ; 05ad: 4b
  pla                            ; 05ae: 68
  nxt                            ; 05af: 02
._do_if_0:
  rla                            ; 05b0: 6b
  pla                            ; 05b1: 68
  txi                            ; 05b2: 5c
  nxt                            ; 05b3: 02

!text 0, "(loop)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
loop:
  nxa                            ; 05bf: 42
  tax                            ; 05c0: aa
  lda $00,r                      ; 05c1: a7 00
  inc                            ; 05c3: 1a
  eor $00,r                      ; 05c4: 47 00
  bit #$8000                     ; 05c6: 89 00 80
  bne .loop_0                    ; 05c9: d0 01
  txi                            ; 05cb: 5c
.loop_0:
  lda $00,r                      ; 05cc: a7 00
  inc                            ; 05ce: 1a
  sta $00,r                      ; 05cf: 87 00
  nxt                            ; 05d1: 02

!text 0, "(+loop)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_loop_add:
  nxa                            ; 05de: 42
  tax                            ; 05df: aa
  lda $00,s                      ; 05e0: a3 00
  clc                            ; 05e2: 18
  adc $00,r                      ; 05e3: 67 00
  eor $00,r                      ; 05e5: 47 00
  bit #$8000                     ; 05e7: 89 00 80
  bne ._loop_add_0               ; 05ea: d0 01
  txi                            ; 05ec: 5c
._loop_add_0:
  clc                            ; 05ed: 18
  pla                            ; 05ee: 68
  adc $00,r                      ; 05ef: 67 00
  sta $00,r                      ; 05f1: 87 00
  nxt                            ; 05f3: 02

!text 0, "(leave)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
leave:
  rla                            ; 0600: 6b
  rla                            ; 0601: 6b
  nxa                            ; 0602: 42
  tay                            ; 0603: a8
  ldx $00,y                      ; 0604: b6 00
  txi                            ; 0606: 5c
  txa                            ; 0607: 8a
  nxt                            ; 0608: 02

!text 0, "UNLOOP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UNLOOP:
  rla                            ; 0614: 6b
  rla                            ; 0615: 6b
  nxt                            ; 0616: 02

!text 0, "I", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
I:
  lda $00,r                      ; 061d: a7 00
  clc                            ; 061f: 18
  adc $02,r                      ; 0620: 67 02
  pha                            ; 0622: 48
  nxt                            ; 0623: 02

!text 0, "J", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
J:
  lda $04,r                      ; 062a: a7 04
  clc                            ; 062c: 18
  adc $06,r                      ; 062d: 67 06
  pha                            ; 062f: 48
  nxt                            ; 0630: 02

!text 0, "EXECUTE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
EXECUTE:
  plx                            ; 063d: fa
  dex                            ; 063e: ca
  phx                            ; 063f: da
  rts                            ; 0640: 60

!text 0, "DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DUP:
  lda $00,s                      ; 0649: a3 00
  pha                            ; 064b: 48
  nxt                            ; 064c: 02

!text 0, "?DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
dup_if:
  lda $00,s                      ; 0656: a3 00
  beq .dup_if_0                  ; 0658: f0 01
  pha                            ; 065a: 48
.dup_if_0:
  nxt                            ; 065b: 02

!text 0, "2DUP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_2dup:
  lda $02,s                      ; 0665: a3 02
  pha                            ; 0667: 48
  lda $02,s                      ; 0668: a3 02
  pha                            ; 066a: 48
  nxt                            ; 066b: 02

!text 0, "DROP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DROP:
  pla                            ; 0675: 68
  nxt                            ; 0676: 02

!text 0, "2DROP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_2drop:
  pla                            ; 0681: 68
  pla                            ; 0682: 68
  nxt                            ; 0683: 02

!text 0, "SWAP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SWAP:
  pla                            ; 068d: 68
  plx                            ; 068e: fa
  pha                            ; 068f: 48
  phx                            ; 0690: da
  nxt                            ; 0691: 02

!text 0, "PICK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PICK:
  pla                            ; 069b: 68
  clc                            ; 069c: 18
  rol                            ; 069d: 2a
  clc                            ; 069e: 18
  adc #$0002                     ; 069f: 69 02 00
  pha                            ; 06a2: 48
  tsx                            ; 06a3: ba
  txy                            ; 06a4: 9b
  lda ($00,s),y                  ; 06a5: b3 00
  sta $00,s                      ; 06a7: 83 00
  nxt                            ; 06a9: 02

!text 0, "OVER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
OVER:
  lda $02,s                      ; 06b3: a3 02
  pha                            ; 06b5: 48
  nxt                            ; 06b6: 02

!text 0, "2OVER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_2over:
  lda $04,s                      ; 06c1: a3 04
  pha                            ; 06c3: 48
  nxt                            ; 06c4: 02

!text 0, "ROT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ROT:
  pla                            ; 06cd: 68
  plx                            ; 06ce: fa
  ply                            ; 06cf: 7a
  phx                            ; 06d0: da
  pha                            ; 06d1: 48
  phy                            ; 06d2: 5a
  nxt                            ; 06d3: 02

!text 0, "2SWAP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_2swap:
  lda $06,s                      ; 06de: a3 06
  tax                            ; 06e0: aa
  lda $02,s                      ; 06e1: a3 02
  sta $06,s                      ; 06e3: 83 06
  txa                            ; 06e5: 8a
  sta $02,s                      ; 06e6: 83 02
  lda $04,s                      ; 06e8: a3 04
  tax                            ; 06ea: aa
  lda $00,s                      ; 06eb: a3 00
  sta $04,s                      ; 06ed: 83 04
  txa                            ; 06ef: 8a
  sta $00,s                      ; 06f0: 83 00
  nxt                            ; 06f2: 02

!text 0, "-ROT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rot_rev:
  pla                            ; 06fc: 68
  plx                            ; 06fd: fa
  ply                            ; 06fe: 7a
  pha                            ; 06ff: 48
  phy                            ; 0700: 5a
  phx                            ; 0701: da
  nxt                            ; 0702: 02

!text 0, "NIP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
NIP:
  pla                            ; 070b: 68
  plx                            ; 070c: fa
  pha                            ; 070d: 48
  nxt                            ; 070e: 02

!text 0, "TUCK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TUCK:
  pla                            ; 0718: 68
  plx                            ; 0719: fa
  pha                            ; 071a: 48
  phx                            ; 071b: da
  pha                            ; 071c: 48
  nxt                            ; 071d: 02

!text 0, ">R", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
push_r:
  pla                            ; 0725: 68
  rha                            ; 0726: 4b
  nxt                            ; 0727: 02

!text 0, "R>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
pull_r:
  rla                            ; 072f: 6b
  pha                            ; 0730: 48
  nxt                            ; 0731: 02

!text 0, "!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
store:
  plx                            ; 0738: fa
  pla                            ; 0739: 68
  sta $00,x                      ; 073a: 95 00
  nxt                            ; 073c: 02

!text 0, "+!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
inc_word:
  plx                            ; 0744: fa
  pla                            ; 0745: 68
  clc                            ; 0746: 18
  adc $00,x                      ; 0747: 75 00
  sta $00,x                      ; 0749: 95 00
  nxt                            ; 074b: 02

!text 0, "-!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
dec_word:
  plx                            ; 0753: fa
  sec                            ; 0754: 38
  lda $00,x                      ; 0755: b5 00
  sbc $00,s                      ; 0757: e3 00
  sta $00,x                      ; 0759: 95 00
  pla                            ; 075b: 68
  nxt                            ; 075c: 02

!text 0, "C!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
c_store:
  plx                            ; 0764: fa
  pla                            ; 0765: 68
  sep #$20                       ; 0766: e2 20
!as
  sta $00,x                      ; 0768: 95 00
  rep #$20                       ; 076a: c2 20
!al
  nxt                            ; 076c: 02

!text 0, "@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
load:
  plx                            ; 0773: fa
  lda $00,x                      ; 0774: b5 00
  pha                            ; 0776: 48
  nxt                            ; 0777: 02

!text 0, "C@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
c_load:
  plx                            ; 077f: fa
  sep #$20                       ; 0780: e2 20
!as
  lda $00,x                      ; 0782: b5 00
  zea                            ; 0784: 8f
  rep #$20                       ; 0785: c2 20
!al
  pha                            ; 0787: 48
  nxt                            ; 0788: 02

!text 0, "+", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_add:
  pla                            ; 078f: 68
  clc                            ; 0790: 18
  adc $00,s                      ; 0791: 63 00
  sta $00,s                      ; 0793: 83 00
  nxt                            ; 0795: 02

!text 0, "-", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_sub:
  lda $02,s                      ; 079c: a3 02
  sec                            ; 079e: 38
  sbc $00,s                      ; 079f: e3 00
  sta $02,s                      ; 07a1: 83 02
  pla                            ; 07a3: 68
  nxt                            ; 07a4: 02

!text 0, "M*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
m_mul:
  pla                            ; 07ac: 68
  tsx                            ; 07ad: ba
  sec                            ; 07ae: 38
  mul $00,x                      ; 07af: 1f 00
  plx                            ; 07b1: fa
  pha                            ; 07b2: 48
  phd                            ; 07b3: df
  nxt                            ; 07b4: 02

!text 0, "UM*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
um_mul:
  pla                            ; 07bd: 68
  tsx                            ; 07be: ba
  clc                            ; 07bf: 18
  mul $00,x                      ; 07c0: 1f 00
  plx                            ; 07c2: fa
  pha                            ; 07c3: 48
  phd                            ; 07c4: df
  nxt                            ; 07c5: 02

!text 0, "*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_mul:
  pla                            ; 07cc: 68
  tsx                            ; 07cd: ba
  sec                            ; 07ce: 38
  mul $00,x                      ; 07cf: 1f 00
  plx                            ; 07d1: fa
  pha                            ; 07d2: 48
  nxt                            ; 07d3: 02

!text 0, "U*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
umul:
  pla                            ; 07db: 68
  tsx                            ; 07dc: ba
  clc                            ; 07dd: 18
  mul $00,x                      ; 07de: 1f 00
  plx                            ; 07e0: fa
  pha                            ; 07e1: 48
  nxt                            ; 07e2: 02

!text 0, "SM/REM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sm_div_rem:
  plx                            ; 07ee: fa
  pld                            ; 07ef: cf
  pla                            ; 07f0: 68
  phx                            ; 07f1: da
  tsx                            ; 07f2: ba
  sec                            ; 07f3: 38
  div $00,x                      ; 07f4: 5f 00
  plx                            ; 07f6: fa
  phd                            ; 07f7: df
  pha                            ; 07f8: 48
  nxt                            ; 07f9: 02

!text 0, "FM/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
fm_div_mod:
  plx                            ; 0805: fa
  pld                            ; 0806: cf
  pla                            ; 0807: 68
  phx                            ; 0808: da
  tsx                            ; 0809: ba
  sec                            ; 080a: 38
  div $00,x                      ; 080b: 5f 00
  plx                            ; 080d: fa
  phd                            ; 080e: df
  pha                            ; 080f: 48
  tda                            ; 0810: af
  beq .fm_div_mod_0              ; 0811: f0 11
  phx                            ; 0813: da
  eor $00,s                      ; 0814: 43 00
  bit #$8000                     ; 0816: 89 00 80
  beq .fm_div_mod_1              ; 0819: f0 0a
  pla                            ; 081b: 68
  clc                            ; 081c: 18
  adc $02,s                      ; 081d: 63 02
  sta $02,s                      ; 081f: 83 02
  tsx                            ; 0821: ba
  dec $00,x                      ; 0822: d6 00
.fm_div_mod_0:
  nxt                            ; 0824: 02
.fm_div_mod_1:
  plx                            ; 0825: fa
  nxt                            ; 0826: 02

!text 0, "UM/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
um_div_mod:
  plx                            ; 0832: fa
  pld                            ; 0833: cf
  pla                            ; 0834: 68
  phx                            ; 0835: da
  tsx                            ; 0836: ba
  clc                            ; 0837: 18
  div $00,x                      ; 0838: 5f 00
  plx                            ; 083a: fa
  phd                            ; 083b: df
  pha                            ; 083c: 48
  nxt                            ; 083d: 02

!text 0, "2*", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
mul2:
  pla                            ; 0845: 68
  clc                            ; 0846: 18
  rol                            ; 0847: 2a
  pha                            ; 0848: 48
  nxt                            ; 0849: 02

!text 0, "2/", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
div2:
  lda $00,s                      ; 0851: a3 00
  rol                            ; 0853: 2a
  pla                            ; 0854: 68
  ror                            ; 0855: 6a
  pha                            ; 0856: 48
  nxt                            ; 0857: 02

!text 0, "U>>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
shr:
  ply                            ; 0860: 7a
  pla                            ; 0861: 68
.shr_0:
  clc                            ; 0862: 18
  ror                            ; 0863: 6a
  dey                            ; 0864: 88
  bne .shr_0                     ; 0865: d0 fb
  pha                            ; 0867: 48
  nxt                            ; 0868: 02

!text 0, "<<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
shl:
  ply                            ; 0870: 7a
  pla                            ; 0871: 68
  cpy #$0000                     ; 0872: c0 00 00
  beq .shl_0                     ; 0875: f0 05
.shl_1:
  clc                            ; 0877: 18
  rol                            ; 0878: 2a
  dey                            ; 0879: 88
  bne .shl_1                     ; 087a: d0 fb
.shl_0:
  pha                            ; 087c: 48
  nxt                            ; 087d: 02

!text 0, "AND", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_and:
  pla                            ; 0886: 68
  and $00,s                      ; 0887: 23 00
  sta $00,s                      ; 0889: 83 00
  nxt                            ; 088b: 02

!text 0, "OR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
OR:
  pla                            ; 0893: 68
  ora $00,s                      ; 0894: 03 00
  sta $00,s                      ; 0896: 83 00
  nxt                            ; 0898: 02

!text 0, "XOR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
XOR:
  pla                            ; 08a1: 68
  eor $00,s                      ; 08a2: 43 00
  sta $00,s                      ; 08a4: 83 00
  nxt                            ; 08a6: 02

!text 0, "INVERT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
INVERT:
  pla                            ; 08b2: 68
  eor #$ffff                     ; 08b3: 49 ff ff
  pha                            ; 08b6: 48
  nxt                            ; 08b7: 02

!text 0, "NEGATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
NEGATE:
  pla                            ; 08c3: 68
  eor #$ffff                     ; 08c4: 49 ff ff
  inc                            ; 08c7: 1a
  pha                            ; 08c8: 48
  nxt                            ; 08c9: 02

!text 0, "1+", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
add1:
  pla                            ; 08d1: 68
  inc                            ; 08d2: 1a
  pha                            ; 08d3: 48
  nxt                            ; 08d4: 02

!text 0, "1-", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sub1:
  pla                            ; 08dc: 68
  dec                            ; 08dd: 3a
  pha                            ; 08de: 48
  nxt                            ; 08df: 02

!text 0, "SP@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sp_load:
  tsx                            ; 08e8: ba
  phx                            ; 08e9: da
  nxt                            ; 08ea: 02

!text 0, "SP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sp_store:
  plx                            ; 08f3: fa
  txs                            ; 08f4: 9a
  nxt                            ; 08f5: 02

!text 0, "RP@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rp_load:
  trx                            ; 08fe: ab
  phx                            ; 08ff: da
  nxt                            ; 0900: 02

!text 0, "RP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rp_store:
  plx                            ; 0909: fa
  txr                            ; 090a: 8b
  nxt                            ; 090b: 02

!text 0, "0=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
eq0:
  pla                            ; 0913: 68
  beq .eq0_0                     ; 0914: f0 04
  pea $0000                      ; 0916: f4 00 00
  nxt                            ; 0919: 02
.eq0_0:
  pea $ffff                      ; 091a: f4 ff ff
  nxt                            ; 091d: 02

!text 0, "0<>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
neq0:
  pla                            ; 0926: 68
  beq .neq0_0                    ; 0927: f0 04
  pea $ffff                      ; 0929: f4 ff ff
  nxt                            ; 092c: 02
.neq0_0:
  pha                            ; 092d: 48
  nxt                            ; 092e: 02

!text 0, "0<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
lt0:
  pla                            ; 0936: 68
  bmi .lt0_0                     ; 0937: 30 04
  pea $0000                      ; 0939: f4 00 00
  nxt                            ; 093c: 02
.lt0_0:
  pea $ffff                      ; 093d: f4 ff ff
  nxt                            ; 0940: 02

!text 0, "<>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
neq:
  pla                            ; 0948: 68
  cmp $00,s                      ; 0949: c3 00
  beq .neq_0                     ; 094b: f0 05
  pla                            ; 094d: 68
  pea $ffff                      ; 094e: f4 ff ff
  nxt                            ; 0951: 02
.neq_0:
  pla                            ; 0952: 68
  pea $0000                      ; 0953: f4 00 00
  nxt                            ; 0956: 02

!text 0, "<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
lt:
  pla                            ; 095d: 68
  cmp $00,s                      ; 095e: c3 00
  bmi .lt_0                      ; 0960: 30 07
  beq .lt_0                      ; 0962: f0 05
  pla                            ; 0964: 68
  pea $ffff                      ; 0965: f4 ff ff
  nxt                            ; 0968: 02
.lt_0:
  pla                            ; 0969: 68
  pea $0000                      ; 096a: f4 00 00
  nxt                            ; 096d: 02

!text 0, ">", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
gt:
  pla                            ; 0974: 68
  cmp $00,s                      ; 0975: c3 00
  bmi .gt_0                      ; 0977: 30 05
  pla                            ; 0979: 68
  pea $0000                      ; 097a: f4 00 00
  nxt                            ; 097d: 02
.gt_0:
  pla                            ; 097e: 68
  pea $ffff                      ; 097f: f4 ff ff
  nxt                            ; 0982: 02

!text 0, "U<", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ult:
  pla                            ; 098a: 68
  cmp $00,s                      ; 098b: c3 00
  bcc .ult_0                     ; 098d: 90 07
  beq .ult_0                     ; 098f: f0 05
  pla                            ; 0991: 68
  pea $ffff                      ; 0992: f4 ff ff
  nxt                            ; 0995: 02
.ult_0:
  pla                            ; 0996: 68
  pea $0000                      ; 0997: f4 00 00
  nxt                            ; 099a: 02

!text 0, "U>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ugt:
  pla                            ; 09a2: 68
  cmp $00,s                      ; 09a3: c3 00
  bcc .ugt_0                     ; 09a5: 90 05
  pla                            ; 09a7: 68
  pea $0000                      ; 09a8: f4 00 00
  nxt                            ; 09ab: 02
.ugt_0:
  pla                            ; 09ac: 68
  pea $ffff                      ; 09ad: f4 ff ff
  nxt                            ; 09b0: 02

!text 0, "<=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
le:
  pla                            ; 09b8: 68
  cmp $00,s                      ; 09b9: c3 00
  bmi .le_0                      ; 09bb: 30 05
  pla                            ; 09bd: 68
  pea $ffff                      ; 09be: f4 ff ff
  nxt                            ; 09c1: 02
.le_0:
  pla                            ; 09c2: 68
  pea $0000                      ; 09c3: f4 00 00
  nxt                            ; 09c6: 02

!text 0, ">=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ge:
  pla                            ; 09ce: 68
  cmp $00,s                      ; 09cf: c3 00
  bmi .ge_0                      ; 09d1: 30 07
  beq .ge_0                      ; 09d3: f0 05
  pla                            ; 09d5: 68
  pea $0000                      ; 09d6: f4 00 00
  nxt                            ; 09d9: 02
.ge_0:
  pla                            ; 09da: 68
  pea $ffff                      ; 09db: f4 ff ff
  nxt                            ; 09de: 02

!text 0, "=", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
eq:
  pla                            ; 09e5: 68
  cmp $00,s                      ; 09e6: c3 00
  beq .eq_0                      ; 09e8: f0 05
  pla                            ; 09ea: 68
  pea $0000                      ; 09eb: f4 00 00
  nxt                            ; 09ee: 02
.eq_0:
  pla                            ; 09ef: 68
  pea $ffff                      ; 09f0: f4 ff ff
  nxt                            ; 09f3: 02

!text 0, "CELL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CELL:
  pea $0002                      ; 09fd: f4 02 00
  nxt                            ; 0a00: 02

!text 0, "CELLS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CELLS:
  pla                            ; 0a0b: 68
  clc                            ; 0a0c: 18
  rol                            ; 0a0d: 2a
  pha                            ; 0a0e: 48
  nxt                            ; 0a0f: 02

!text 0, "MAX", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MAX:
  pla                            ; 0a18: 68
  cmp $00,s                      ; 0a19: c3 00
  bmi .MAX_0                     ; 0a1b: 30 02
  sta $00,s                      ; 0a1d: 83 00
.MAX_0:
  nxt                            ; 0a1f: 02

!text 0, "MIN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MIN:
  pla                            ; 0a28: 68
  cmp $00,s                      ; 0a29: c3 00
  bpl .MIN_0                     ; 0a2b: 10 02
  sta $00,s                      ; 0a2d: 83 00
.MIN_0:
  nxt                            ; 0a2f: 02

!text 0, "MOVE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MOVE:
  rhi                            ; 0a39: 0b
  pla                            ; 0a3a: 68
  ply                            ; 0a3b: 7a
  plx                            ; 0a3c: fa
  txi                            ; 0a3d: 5c
  tyx                            ; 0a3e: bb
  tay                            ; 0a3f: a8
  beq .MOVE_0                    ; 0a40: f0 0b
  sep #$20                       ; 0a42: e2 20
!as
.MOVE_1:
  nxa                            ; 0a44: 42
  sta $00,x                      ; 0a45: 95 00
  inx                            ; 0a47: e8
  dey                            ; 0a48: 88
  bne .MOVE_1                    ; 0a49: d0 f9
  rep #$20                       ; 0a4b: c2 20
!al
.MOVE_0:
  rli                            ; 0a4d: 2b
  nxt                            ; 0a4e: 02

!text 0, "FILL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FILL:
  pla                            ; 0a58: 68
  ply                            ; 0a59: 7a
  plx                            ; 0a5a: fa
  cpy #$0000                     ; 0a5b: c0 00 00
  beq .FILL_0                    ; 0a5e: f0 0a
  sep #$20                       ; 0a60: e2 20
!as
.FILL_1:
  sta $00,x                      ; 0a62: 95 00
  inx                            ; 0a64: e8
  dey                            ; 0a65: 88
  bne .FILL_1                    ; 0a66: d0 fa
  rep #$20                       ; 0a68: c2 20
!al
.FILL_0:
  nxt                            ; 0a6a: 02

!text 0, "MEMCMP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MEMCMP:
  rhi                            ; 0a76: 0b
  pla                            ; 0a77: 68
  ply                            ; 0a78: 7a
  plx                            ; 0a79: fa
  txi                            ; 0a7a: 5c
  tyx                            ; 0a7b: bb
  tay                            ; 0a7c: a8
  beq .MEMCMP_0                  ; 0a7d: f0 0d
  sep #$20                       ; 0a7f: e2 20
!as
.MEMCMP_2:
  nxa                            ; 0a81: 42
  cmp $00,x                      ; 0a82: d5 00
  bne .MEMCMP_1                  ; 0a84: d0 0b
  inx                            ; 0a86: e8
  dey                            ; 0a87: 88
  bne .MEMCMP_2                  ; 0a88: d0 f7
  rep #$20                       ; 0a8a: c2 20
!al
.MEMCMP_0:
  rli                            ; 0a8c: 2b
  pea $0000                      ; 0a8d: f4 00 00
  nxt                            ; 0a90: 02
.MEMCMP_1:
  rep #$20                       ; 0a91: c2 20
!al
  rli                            ; 0a93: 2b
  bmi .MEMCMP_3                  ; 0a94: 30 04
  pea $0001                      ; 0a96: f4 01 00
  nxt                            ; 0a99: 02
.MEMCMP_3:
  pea $ffff                      ; 0a9a: f4 ff ff
  nxt                            ; 0a9d: 02

!text 0, "STRLEN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STRLEN:
  lda $00,s                      ; 0aa9: a3 00
  tax                            ; 0aab: aa
  lda #$0000                     ; 0aac: a9 00 00
  sep #$20                       ; 0aaf: e2 20
!as
.STRLEN_1:
  cmp $00,x                      ; 0ab1: d5 00
  beq .STRLEN_0                  ; 0ab3: f0 03
  inx                            ; 0ab5: e8
  bra .STRLEN_1                  ; 0ab6: 80 f9
.STRLEN_0:
  rep #$20                       ; 0ab8: c2 20
!al
  txa                            ; 0aba: 8a
  sec                            ; 0abb: 38
  sbc $00,s                      ; 0abc: e3 00
  sta $00,s                      ; 0abe: 83 00
  nxt                            ; 0ac0: 02

!text 0, "RSTRLEN", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RSTRLEN:
  lda $00,s                      ; 0acd: a3 00
  tax                            ; 0acf: aa
  lda #$0000                     ; 0ad0: a9 00 00
  sep #$20                       ; 0ad3: e2 20
!as
.RSTRLEN_1:
  cmp $00,x                      ; 0ad5: d5 00
  beq .RSTRLEN_0                 ; 0ad7: f0 03
  dex                            ; 0ad9: ca
  bra .RSTRLEN_1                 ; 0ada: 80 f9
.RSTRLEN_0:
  rep #$20                       ; 0adc: c2 20
!al
  pla                            ; 0ade: 68
  phx                            ; 0adf: da
  sec                            ; 0ae0: 38
  sbc $00,s                      ; 0ae1: e3 00
  sta $00,s                      ; 0ae3: 83 00
  nxt                            ; 0ae5: 02

!text 0, "TRUE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TRUE:
  ent                            ; 0aef: 22
  !16 DOCON, 0xffff              ; 0af0: 24 05 ff ff

!text 0, "FALSE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FALSE:
  ent                            ; 0afe: 22
  !16 DOCON, 0x0000              ; 0aff: 24 05 00 00

!text 0, "SCRATCH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SCRATCH:
  ent                            ; 0b0f: 22
  !16 DOCON, 0x0040              ; 0b10: 24 05 40 00

!text 0, "TIB", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIB:
  ent                            ; 0b1c: 22
  !16 DOCON, 0x0080              ; 0b1d: 24 05 80 00

!text 0, "RADIX", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RADIX:
  ent                            ; 0b2b: 22
  !16 DOVAR, 0x000a              ; 0b2c: 34 05 0a 00

!text 0, "BL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BL:
  ent                            ; 0b37: 22
  !16 DOCON, 0x0020              ; 0b38: 24 05 20 00

!text 0, "UITOA", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UITOA:
  ent                            ; 0b46: 22
  !16 SCRATCH                    ; 0b47: 0f 0b
  !16 lit, 0x0014                ; 0b49: 50 05 14 00
  !16 _add ; +                   ; 0b4d: 8f 07
  !16 lit, 0x0000                ; 0b4f: 50 05 00 00
  !16 OVER                       ; 0b53: b3 06
  !16 c_store ; C!               ; 0b55: 64 07
.UITOA_1:
  !16 sub1 ; 1-                  ; 0b57: dc 08
  !16 SWAP                       ; 0b59: 8d 06
  !16 lit, 0x0000                ; 0b5b: 50 05 00 00
  !16 RADIX                      ; 0b5f: 2b 0b
  !16 load ; @                   ; 0b61: 73 07
  !16 um_div_mod ; UM/MOD        ; 0b63: 32 08
  !16 rot_rev ; -ROT             ; 0b65: fc 06
  !16 lit, 0x0030                ; 0b67: 50 05 30 00
  !16 _add ; +                   ; 0b6b: 8f 07
  !16 DUP                        ; 0b6d: 49 06
  !16 lit, 0x0039                ; 0b6f: 50 05 39 00
  !16 gt ; >                     ; 0b73: 74 09
  !16 branch_if, .UITOA_0        ; 0b75: 7d 05 7f 0b
  !16 lit, 0x0007                ; 0b79: 50 05 07 00
  !16 _add ; +                   ; 0b7d: 8f 07
.UITOA_0:
  !16 OVER                       ; 0b7f: b3 06
  !16 c_store ; C!               ; 0b81: 64 07
  !16 OVER                       ; 0b83: b3 06
  !16 eq0 ; 0=                   ; 0b85: 13 09
  !16 branch_if, .UITOA_1        ; 0b87: 7d 05 57 0b
  !16 NIP                        ; 0b8b: 0b 07
  !16 EXIT                       ; 0b8d: 5c 05

!text 0, "WORD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WORD:
  ent                            ; 0b98: 22
.WORD_1:
  !16 DUP                        ; 0b99: 49 06
  !16 c_load ; C@                ; 0b9b: 7f 07
  !16 DUP                        ; 0b9d: 49 06
  !16 lit, 0x0020                ; 0b9f: 50 05 20 00
  !16 eq ; =                     ; 0ba3: e5 09
  !16 OVER                       ; 0ba5: b3 06
  !16 lit, 0x0009                ; 0ba7: 50 05 09 00
  !16 eq ; =                     ; 0bab: e5 09
  !16 OR                         ; 0bad: 93 08
  !16 OVER                       ; 0baf: b3 06
  !16 lit, 0x000a                ; 0bb1: 50 05 0a 00
  !16 eq ; =                     ; 0bb5: e5 09
  !16 OR                         ; 0bb7: 93 08
  !16 OVER                       ; 0bb9: b3 06
  !16 lit, 0x000d                ; 0bbb: 50 05 0d 00
  !16 eq ; =                     ; 0bbf: e5 09
  !16 OR                         ; 0bc1: 93 08
  !16 NIP                        ; 0bc3: 0b 07
  !16 branch_if, .WORD_0         ; 0bc5: 7d 05 cf 0b
  !16 add1 ; 1+                  ; 0bc9: d1 08
  !16 branch, .WORD_1            ; 0bcb: 6b 05 99 0b
.WORD_0:
  !16 DUP                        ; 0bcf: 49 06
  !16 c_load ; C@                ; 0bd1: 7f 07
  !16 eq0 ; 0=                   ; 0bd3: 13 09
  !16 branch_if, .WORD_2         ; 0bd5: 7d 05 dd 0b
  !16 DUP                        ; 0bd9: 49 06
  !16 EXIT                       ; 0bdb: 5c 05
.WORD_2:
  !16 DUP                        ; 0bdd: 49 06
.WORD_4:
  !16 DUP                        ; 0bdf: 49 06
  !16 c_load ; C@                ; 0be1: 7f 07
  !16 DUP                        ; 0be3: 49 06
  !16 lit, 0x0020                ; 0be5: 50 05 20 00
  !16 neq ; <>                   ; 0be9: 48 09
  !16 OVER                       ; 0beb: b3 06
  !16 neq0 ; 0<>                 ; 0bed: 26 09
  !16 _and ; AND                 ; 0bef: 86 08
  !16 OVER                       ; 0bf1: b3 06
  !16 lit, 0x0009                ; 0bf3: 50 05 09 00
  !16 neq ; <>                   ; 0bf7: 48 09
  !16 _and ; AND                 ; 0bf9: 86 08
  !16 OVER                       ; 0bfb: b3 06
  !16 lit, 0x000a                ; 0bfd: 50 05 0a 00
  !16 neq ; <>                   ; 0c01: 48 09
  !16 _and ; AND                 ; 0c03: 86 08
  !16 OVER                       ; 0c05: b3 06
  !16 lit, 0x000d                ; 0c07: 50 05 0d 00
  !16 neq ; <>                   ; 0c0b: 48 09
  !16 _and ; AND                 ; 0c0d: 86 08
  !16 NIP                        ; 0c0f: 0b 07
  !16 branch_if, .WORD_3         ; 0c11: 7d 05 1b 0c
  !16 add1 ; 1+                  ; 0c15: d1 08
  !16 branch, .WORD_4            ; 0c17: 6b 05 df 0b
.WORD_3:
  !16 DUP                        ; 0c1b: 49 06
  !16 c_load ; C@                ; 0c1d: 7f 07
  !16 branch_if, .WORD_5         ; 0c1f: 7d 05 2d 0c
  !16 lit, 0x0000                ; 0c23: 50 05 00 00
  !16 OVER                       ; 0c27: b3 06
  !16 c_store ; C!               ; 0c29: 64 07
  !16 add1 ; 1+                  ; 0c2b: d1 08
.WORD_5:
  !16 SWAP                       ; 0c2d: 8d 06
  !16 EXIT                       ; 0c2f: 5c 05

!text 0, "SPLIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SPLIT:
  ent                            ; 0c3b: 22
  !16 SWAP                       ; 0c3c: 8d 06
.SPLIT_1:
  !16 OVER                       ; 0c3e: b3 06
  !16 OVER                       ; 0c40: b3 06
  !16 c_load ; C@                ; 0c42: 7f 07
  !16 eq ; =                     ; 0c44: e5 09
  !16 branch_if, .SPLIT_0        ; 0c46: 7d 05 50 0c
  !16 add1 ; 1+                  ; 0c4a: d1 08
  !16 branch, .SPLIT_1           ; 0c4c: 6b 05 3e 0c
.SPLIT_0:
  !16 TUCK                       ; 0c50: 18 07
.SPLIT_3:
  !16 OVER                       ; 0c52: b3 06
  !16 OVER                       ; 0c54: b3 06
  !16 c_load ; C@                ; 0c56: 7f 07
  !16 neq ; <>                   ; 0c58: 48 09
  !16 OVER                       ; 0c5a: b3 06
  !16 c_load ; C@                ; 0c5c: 7f 07
  !16 neq0 ; 0<>                 ; 0c5e: 26 09
  !16 _and ; AND                 ; 0c60: 86 08
  !16 branch_if, .SPLIT_2        ; 0c62: 7d 05 6c 0c
  !16 add1 ; 1+                  ; 0c66: d1 08
  !16 branch, .SPLIT_3           ; 0c68: 6b 05 52 0c
.SPLIT_2:
  !16 DUP                        ; 0c6c: 49 06
  !16 c_load ; C@                ; 0c6e: 7f 07
  !16 branch_if, .SPLIT_4        ; 0c70: 7d 05 7e 0c
  !16 lit, 0x0000                ; 0c74: 50 05 00 00
  !16 OVER                       ; 0c78: b3 06
  !16 c_store ; C!               ; 0c7a: 64 07
  !16 add1 ; 1+                  ; 0c7c: d1 08
.SPLIT_4:
  !16 NIP                        ; 0c7e: 0b 07
  !16 SWAP                       ; 0c80: 8d 06
  !16 EXIT                       ; 0c82: 5c 05

!text 0, "STRCMP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STRCMP:
  ent                            ; 0c8f: 22
  !16 _2dup ; 2DUP               ; 0c90: 65 06
  !16 STRLEN                     ; 0c92: a9 0a
  !16 SWAP                       ; 0c94: 8d 06
  !16 STRLEN                     ; 0c96: a9 0a
  !16 MIN                        ; 0c98: 28 0a
  !16 add1 ; 1+                  ; 0c9a: d1 08
  !16 MEMCMP                     ; 0c9c: 76 0a
  !16 EXIT                       ; 0c9e: 5c 05

!text 0, "ISUNUM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ISUNUM:
  ent                            ; 0cab: 22
  !16 DUP                        ; 0cac: 49 06
  !16 lit, 0x0040                ; 0cae: 50 05 40 00
  !16 gt ; >                     ; 0cb2: 74 09
  !16 branch_if, .ISUNUM_0       ; 0cb4: 7d 05 be 0c
  !16 lit, 0x0007                ; 0cb8: 50 05 07 00
  !16 _sub ; -                   ; 0cbc: 9c 07
.ISUNUM_0:
  !16 lit, 0x0030                ; 0cbe: 50 05 30 00
  !16 _sub ; -                   ; 0cc2: 9c 07
  !16 DUP                        ; 0cc4: 49 06
  !16 lt0 ; 0<                   ; 0cc6: 36 09
  !16 SWAP                       ; 0cc8: 8d 06
  !16 RADIX                      ; 0cca: 2b 0b
  !16 load ; @                   ; 0ccc: 73 07
  !16 sub1 ; 1-                  ; 0cce: dc 08
  !16 gt ; >                     ; 0cd0: 74 09
  !16 OR                         ; 0cd2: 93 08
  !16 eq0 ; 0=                   ; 0cd4: 13 09
  !16 EXIT                       ; 0cd6: 5c 05

!text 0, "ISNUM", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ISNUM:
  ent                            ; 0ce2: 22
  !16 DUP                        ; 0ce3: 49 06
  !16 ISUNUM                     ; 0ce5: ab 0c
  !16 SWAP                       ; 0ce7: 8d 06
  !16 lit, 0x002d                ; 0ce9: 50 05 2d 00
  !16 eq ; =                     ; 0ced: e5 09
  !16 OR                         ; 0cef: 93 08
  !16 EXIT                       ; 0cf1: 5c 05

!text 0, "UATOI", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UATOI:
  ent                            ; 0cfd: 22
  !16 lit, 0x0000                ; 0cfe: 50 05 00 00
.UATOI_2:
  !16 OVER                       ; 0d02: b3 06
  !16 c_load ; C@                ; 0d04: 7f 07
  !16 DUP                        ; 0d06: 49 06
  !16 lit, 0x0040                ; 0d08: 50 05 40 00
  !16 gt ; >                     ; 0d0c: 74 09
  !16 branch_if, .UATOI_0        ; 0d0e: 7d 05 18 0d
  !16 lit, 0x0007                ; 0d12: 50 05 07 00
  !16 _sub ; -                   ; 0d16: 9c 07
.UATOI_0:
  !16 lit, 0x0030                ; 0d18: 50 05 30 00
  !16 _sub ; -                   ; 0d1c: 9c 07
  !16 DUP                        ; 0d1e: 49 06
  !16 lt0 ; 0<                   ; 0d20: 36 09
  !16 OVER                       ; 0d22: b3 06
  !16 RADIX                      ; 0d24: 2b 0b
  !16 load ; @                   ; 0d26: 73 07
  !16 ge ; >=                    ; 0d28: ce 09
  !16 OR                         ; 0d2a: 93 08
  !16 eq0 ; 0=                   ; 0d2c: 13 09
  !16 branch_if, .UATOI_1        ; 0d2e: 7d 05 46 0d
  !16 SWAP                       ; 0d32: 8d 06
  !16 RADIX                      ; 0d34: 2b 0b
  !16 load ; @                   ; 0d36: 73 07
  !16 umul ; U*                  ; 0d38: db 07
  !16 _add ; +                   ; 0d3a: 8f 07
  !16 SWAP                       ; 0d3c: 8d 06
  !16 add1 ; 1+                  ; 0d3e: d1 08
  !16 SWAP                       ; 0d40: 8d 06
  !16 branch, .UATOI_2           ; 0d42: 6b 05 02 0d
.UATOI_1:
  !16 DROP                       ; 0d46: 75 06
  !16 NIP                        ; 0d48: 0b 07
  !16 EXIT                       ; 0d4a: 5c 05

!text 0, "ATOI", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ATOI:
  ent                            ; 0d55: 22
  !16 DUP                        ; 0d56: 49 06
  !16 c_load ; C@                ; 0d58: 7f 07
  !16 lit, 0x002d                ; 0d5a: 50 05 2d 00
  !16 eq ; =                     ; 0d5e: e5 09
  !16 branch_if, .ATOI_0         ; 0d60: 7d 05 6e 0d
  !16 add1 ; 1+                  ; 0d64: d1 08
  !16 UATOI                      ; 0d66: fd 0c
  !16 NEGATE                     ; 0d68: c3 08
  !16 branch, .ATOI_1            ; 0d6a: 6b 05 70 0d
.ATOI_0:
  !16 UATOI                      ; 0d6e: fd 0c
.ATOI_1:
  !16 EXIT                       ; 0d70: 5c 05

!text 0, "HEX", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
HEX:
  ent                            ; 0d7a: 22
  !16 lit, 0x0010                ; 0d7b: 50 05 10 00
  !16 RADIX                      ; 0d7f: 2b 0b
  !16 store ; !                  ; 0d81: 38 07
  !16 EXIT                       ; 0d83: 5c 05

!text 0, "DECIMAL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
DECIMAL:
  ent                            ; 0d91: 22
  !16 lit, 0x000a                ; 0d92: 50 05 0a 00
  !16 RADIX                      ; 0d96: 2b 0b
  !16 store ; !                  ; 0d98: 38 07
  !16 EXIT                       ; 0d9a: 5c 05

!text 0, "TICK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TICK:
  wai                            ; 0da5: cb
  nxt                            ; 0da6: 02

!text 0, "RBP!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
rbp_store:
  pla                            ; 0db0: 68
  mmu #$00                       ; 0db1: ef 00
  nxt                            ; 0db3: 02

!text 0, "TERMADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TERMADDR:
  ent                            ; 0dc1: 22
  !16 DOVAR, 0x0001              ; 0dc2: 34 05 01 00

!text 0, "PAGE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PAGE:
  ent                            ; 0dcf: 22
  !16 TERMADDR                   ; 0dd0: c1 0d
  !16 load ; @                   ; 0dd2: 73 07
  !16 rbp_store ; RBP!           ; 0dd4: b0 0d
  !16 lit, 0x0000                ; 0dd6: 50 05 00 00
  !16 lit, 0x0303                ; 0dda: 50 05 03 03
  !16 c_store ; C!               ; 0dde: 64 07
  !16 lit, 0x0020                ; 0de0: 50 05 20 00
  !16 lit, 0x0308                ; 0de4: 50 05 08 03
  !16 c_store ; C!               ; 0de8: 64 07
  !16 lit, 0x0000                ; 0dea: 50 05 00 00
  !16 lit, 0x030a                ; 0dee: 50 05 0a 03
  !16 store ; !                  ; 0df2: 38 07
  !16 lit, 0x3250                ; 0df4: 50 05 50 32
  !16 lit, 0x030c                ; 0df8: 50 05 0c 03
  !16 store ; !                  ; 0dfc: 38 07
  !16 lit, 0x0001                ; 0dfe: 50 05 01 00
  !16 lit, 0x0307                ; 0e02: 50 05 07 03
  !16 c_store ; C!               ; 0e06: 64 07
.PAGE_0:
  !16 lit, 0x0307                ; 0e08: 50 05 07 03
  !16 c_load ; C@                ; 0e0c: 7f 07
  !16 eq0 ; 0=                   ; 0e0e: 13 09
  !16 TICK                       ; 0e10: a5 0d
  !16 branch_if, .PAGE_0         ; 0e12: 7d 05 08 0e
  !16 lit, 0x0001                ; 0e16: 50 05 01 00
  !16 lit, 0x0301                ; 0e1a: 50 05 01 03
  !16 store ; !                  ; 0e1e: 38 07
  !16 lit, 0x0002                ; 0e20: 50 05 02 00
  !16 lit, 0x0303                ; 0e24: 50 05 03 03
  !16 c_store ; C!               ; 0e28: 64 07
  !16 EXIT                       ; 0e2a: 5c 05

!text 0, "SCROLL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SCROLL:
  ent                            ; 0e37: 22
  !16 TERMADDR                   ; 0e38: c1 0d
  !16 load ; @                   ; 0e3a: 73 07
  !16 rbp_store ; RBP!           ; 0e3c: b0 0d
  !16 lit, 0x0000                ; 0e3e: 50 05 00 00
  !16 lit, 0x0303                ; 0e42: 50 05 03 03
  !16 c_store ; C!               ; 0e46: 64 07
  !16 lit, 0x0100                ; 0e48: 50 05 00 01
  !16 lit, 0x0308                ; 0e4c: 50 05 08 03
  !16 store ; !                  ; 0e50: 38 07
  !16 lit, 0x0000                ; 0e52: 50 05 00 00
  !16 lit, 0x030a                ; 0e56: 50 05 0a 03
  !16 store ; !                  ; 0e5a: 38 07
  !16 lit, 0x3150                ; 0e5c: 50 05 50 31
  !16 lit, 0x030c                ; 0e60: 50 05 0c 03
  !16 store ; !                  ; 0e64: 38 07
  !16 lit, 0x0003                ; 0e66: 50 05 03 00
  !16 lit, 0x0307                ; 0e6a: 50 05 07 03
  !16 c_store ; C!               ; 0e6e: 64 07
.SCROLL_0:
  !16 lit, 0x0307                ; 0e70: 50 05 07 03
  !16 c_load ; C@                ; 0e74: 7f 07
  !16 eq0 ; 0=                   ; 0e76: 13 09
  !16 TICK                       ; 0e78: a5 0d
  !16 branch_if, .SCROLL_0       ; 0e7a: 7d 05 70 0e
  !16 lit, 0x0020                ; 0e7e: 50 05 20 00
  !16 lit, 0x0308                ; 0e82: 50 05 08 03
  !16 c_store ; C!               ; 0e86: 64 07
  !16 lit, 0x3100                ; 0e88: 50 05 00 31
  !16 lit, 0x030a                ; 0e8c: 50 05 0a 03
  !16 store ; !                  ; 0e90: 38 07
  !16 lit, 0x0150                ; 0e92: 50 05 50 01
  !16 lit, 0x030c                ; 0e96: 50 05 0c 03
  !16 store ; !                  ; 0e9a: 38 07
  !16 lit, 0x0001                ; 0e9c: 50 05 01 00
  !16 lit, 0x0307                ; 0ea0: 50 05 07 03
  !16 c_store ; C!               ; 0ea4: 64 07
.SCROLL_1:
  !16 lit, 0x0307                ; 0ea6: 50 05 07 03
  !16 c_load ; C@                ; 0eaa: 7f 07
  !16 eq0 ; 0=                   ; 0eac: 13 09
  !16 TICK                       ; 0eae: a5 0d
  !16 branch_if, .SCROLL_1       ; 0eb0: 7d 05 a6 0e
  !16 lit, 0x0002                ; 0eb4: 50 05 02 00
  !16 lit, 0x0303                ; 0eb8: 50 05 03 03
  !16 c_store ; C!               ; 0ebc: 64 07
  !16 EXIT                       ; 0ebe: 5c 05

!text 0, "CR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CR:
  ent                            ; 0ec7: 22
  !16 TERMADDR                   ; 0ec8: c1 0d
  !16 load ; @                   ; 0eca: 73 07
  !16 rbp_store ; RBP!           ; 0ecc: b0 0d
  !16 lit, 0x0302                ; 0ece: 50 05 02 03
  !16 c_load ; C@                ; 0ed2: 7f 07
  !16 lit, 0x0030                ; 0ed4: 50 05 30 00
  !16 gt ; >                     ; 0ed8: 74 09
  !16 branch_if, .CR_0           ; 0eda: 7d 05 e4 0e
  !16 SCROLL                     ; 0ede: 37 0e
  !16 branch, .CR_1              ; 0ee0: 6b 05 f2 0e
.CR_0:
  !16 lit, 0x0302                ; 0ee4: 50 05 02 03
  !16 c_load ; C@                ; 0ee8: 7f 07
  !16 add1 ; 1+                  ; 0eea: d1 08
  !16 lit, 0x0302                ; 0eec: 50 05 02 03
  !16 c_store ; C!               ; 0ef0: 64 07
.CR_1:
  !16 lit, 0x0000                ; 0ef2: 50 05 00 00
  !16 lit, 0x0301                ; 0ef6: 50 05 01 03
  !16 c_store ; C!               ; 0efa: 64 07
  !16 EXIT                       ; 0efc: 5c 05

!text 0, "EMIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
EMIT:
  ent                            ; 0f07: 22
  !16 TERMADDR                   ; 0f08: c1 0d
  !16 load ; @                   ; 0f0a: 73 07
  !16 rbp_store ; RBP!           ; 0f0c: b0 0d
  !16 lit, 0x0302                ; 0f0e: 50 05 02 03
  !16 c_load ; C@                ; 0f12: 7f 07
  !16 lit, 0x0300                ; 0f14: 50 05 00 03
  !16 c_store ; C!               ; 0f18: 64 07
  !16 lit, 0x0301                ; 0f1a: 50 05 01 03
  !16 c_load ; C@                ; 0f1e: 7f 07
  !16 lit, 0x0310                ; 0f20: 50 05 10 03
  !16 _add ; +                   ; 0f24: 8f 07
  !16 c_store ; C!               ; 0f26: 64 07
  !16 lit, 0x0301                ; 0f28: 50 05 01 03
  !16 c_load ; C@                ; 0f2c: 7f 07
  !16 lit, 0x004e                ; 0f2e: 50 05 4e 00
  !16 gt ; >                     ; 0f32: 74 09
  !16 branch_if, .EMIT_0         ; 0f34: 7d 05 3e 0f
  !16 CR                         ; 0f38: c7 0e
  !16 branch, .EMIT_1            ; 0f3a: 6b 05 4c 0f
.EMIT_0:
  !16 lit, 0x0301                ; 0f3e: 50 05 01 03
  !16 c_load ; C@                ; 0f42: 7f 07
  !16 add1 ; 1+                  ; 0f44: d1 08
  !16 lit, 0x0301                ; 0f46: 50 05 01 03
  !16 c_store ; C!               ; 0f4a: 64 07
.EMIT_1:
  !16 EXIT                       ; 0f4c: 5c 05

!text 0, "BS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BS:
  sep #$20                       ; 0f55: e2 20
!as
  lda $0dc4                      ; 0f57: ad c4 0d
  mmu #$00                       ; 0f5a: ef 00
  lda $0301                      ; 0f5c: ad 01 03
  beq .BS_0                      ; 0f5f: f0 10
  dec                            ; 0f61: 3a
  sta $0301                      ; 0f62: 8d 01 03
  tax                            ; 0f65: aa
  lda $0302                      ; 0f66: ad 02 03
  sta $0300                      ; 0f69: 8d 00 03
  lda #$20                       ; 0f6c: a9 20
  sta $0310,x                    ; 0f6e: 9d 10 03
.BS_0:
  rep #$20                       ; 0f71: c2 20
!al
  nxt                            ; 0f73: 02

!text 0, "KEY?", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
is_key:
  sep #$20                       ; 0f7d: e2 20
!as
  lda $0dc4                      ; 0f7f: ad c4 0d
  mmu #$00                       ; 0f82: ef 00
  lda $0304                      ; 0f84: ad 04 03
  cmp $0305                      ; 0f87: cd 05 03
  rep #$20                       ; 0f8a: c2 20
!al
  beq .is_key_0                  ; 0f8c: f0 04
  pea $ffff                      ; 0f8e: f4 ff ff
  nxt                            ; 0f91: 02
.is_key_0:
  pea $0000                      ; 0f92: f4 00 00
  nxt                            ; 0f95: 02

!text 0, "KEY", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
KEY:
  sep #$20                       ; 0f9e: e2 20
!as
  lda $0dc4                      ; 0fa0: ad c4 0d
  mmu #$00                       ; 0fa3: ef 00
.KEY_1:
  lda $0304                      ; 0fa5: ad 04 03
  cmp $0305                      ; 0fa8: cd 05 03
  bne .KEY_0                     ; 0fab: d0 03
  wai                            ; 0fad: cb
  bra .KEY_1                     ; 0fae: 80 f5
.KEY_0:
  lda $0306                      ; 0fb0: ad 06 03
  zea                            ; 0fb3: 8f
  inc $0304                      ; 0fb4: ee 04 03
  rep #$20                       ; 0fb7: c2 20
!al
  pha                            ; 0fb9: 48
  nxt                            ; 0fba: 02

!text 0, "AT-XY", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
at_xy:
  sep #$20                       ; 0fc5: e2 20
!as
  lda $0dc4                      ; 0fc7: ad c4 0d
  mmu #$00                       ; 0fca: ef 00
  plx                            ; 0fcc: fa
  txa                            ; 0fcd: 8a
  sta $0302                      ; 0fce: 8d 02 03
  plx                            ; 0fd1: fa
  txa                            ; 0fd2: 8a
  sta $0301                      ; 0fd3: 8d 01 03
  rep #$20                       ; 0fd6: c2 20
!al
  nxt                            ; 0fd8: 02

!text 0, "(.\")", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_str_lit:
  ent                            ; 0fe2: 22
  !16 pull_r ; R>                ; 0fe3: 2f 07
.print_str_lit_1:
  !16 DUP                        ; 0fe5: 49 06
  !16 c_load ; C@                ; 0fe7: 7f 07
  !16 dup_if ; ?DUP              ; 0fe9: 56 06
  !16 branch_if, .print_str_lit_0 ; 0feb: 7d 05 f7 0f
  !16 EMIT                       ; 0fef: 07 0f
  !16 add1 ; 1+                  ; 0ff1: d1 08
  !16 branch, .print_str_lit_1   ; 0ff3: 6b 05 e5 0f
.print_str_lit_0:
  !16 add1 ; 1+                  ; 0ff7: d1 08
  !16 push_r ; >R                ; 0ff9: 25 07
  !16 EXIT                       ; 0ffb: 5c 05

!text 0, "SPACE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SPACE:
  ent                            ; 1007: 22
  !16 BL                         ; 1008: 37 0b
  !16 EMIT                       ; 100a: 07 0f
  !16 EXIT                       ; 100c: 5c 05

!text 0, "TYPE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TYPE:
  ent                            ; 1017: 22
.TYPE_1:
  !16 DUP                        ; 1018: 49 06
  !16 c_load ; C@                ; 101a: 7f 07
  !16 dup_if ; ?DUP              ; 101c: 56 06
  !16 branch_if, .TYPE_0         ; 101e: 7d 05 2a 10
  !16 EMIT                       ; 1022: 07 0f
  !16 add1 ; 1+                  ; 1024: d1 08
  !16 branch, .TYPE_1            ; 1026: 6b 05 18 10
.TYPE_0:
  !16 DROP                       ; 102a: 75 06
  !16 EXIT                       ; 102c: 5c 05

!text 0, ".", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_int:
  ent                            ; 1034: 22
  !16 DUP                        ; 1035: 49 06
  !16 lt0 ; 0<                   ; 1037: 36 09
  !16 branch_if, .print_int_0    ; 1039: 7d 05 4f 10
  !16 NEGATE                     ; 103d: c3 08
  !16 UITOA                      ; 103f: 46 0b
  !16 sub1 ; 1-                  ; 1041: dc 08
  !16 lit, 0x002d                ; 1043: 50 05 2d 00
  !16 OVER                       ; 1047: b3 06
  !16 c_store ; C!               ; 1049: 64 07
  !16 branch, .print_int_1       ; 104b: 6b 05 51 10
.print_int_0:
  !16 UITOA                      ; 104f: 46 0b
.print_int_1:
  !16 TYPE                       ; 1051: 17 10
  !16 SPACE                      ; 1053: 07 10
  !16 EXIT                       ; 1055: 5c 05

!text 0, "U.", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_uint:
  ent                            ; 105e: 22
  !16 UITOA                      ; 105f: 46 0b
  !16 TYPE                       ; 1061: 17 10
  !16 SPACE                      ; 1063: 07 10
  !16 EXIT                       ; 1065: 5c 05

!text 0, "/MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
div_mod:
  ent                            ; 1070: 22
  !16 OVER                       ; 1071: b3 06
  !16 lt0 ; 0<                   ; 1073: 36 09
  !16 SWAP                       ; 1075: 8d 06
  !16 fm_div_mod ; FM/MOD        ; 1077: 05 08
  !16 EXIT                       ; 1079: 5c 05

!text 0, "/", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_div:
  ent                            ; 1081: 22
  !16 div_mod ; /MOD             ; 1082: 70 10
  !16 DROP                       ; 1084: 75 06
  !16 EXIT                       ; 1086: 5c 05

!text 0, "MOD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
MOD:
  ent                            ; 1090: 22
  !16 div_mod ; /MOD             ; 1091: 70 10
  !16 NIP                        ; 1093: 0b 07
  !16 EXIT                       ; 1095: 5c 05

!text 0, "ABORT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ABORT:
  ent                            ; 10a1: 22
  !16 SP0                        ; 10a2: 78 16
  !16 sp_store ; SP!             ; 10a4: f3 08
  !16 QUIT                       ; 10a6: 29 18

!text 0, "TIBPTR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBPTR:
  ent                            ; 10b3: 22
  !16 DOVAR, 0x0000              ; 10b4: 34 05 00 00

!text 0, "VOCAB", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
VOCAB:
  ent                            ; 10c2: 22
  !16 DOVAR, COLD                ; 10c3: 34 05 71 1f

!text 0, "(HERE)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
here_var:
  ent                            ; 10d2: 22
  !16 DOVAR, end                 ; 10d3: 34 05 c5 1f

!text 0, "HERE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HERE:
  ent                            ; 10e0: 22
  !16 here_var ; (HERE)          ; 10e1: d2 10
  !16 load ; @                   ; 10e3: 73 07
  !16 EXIT                       ; 10e5: 5c 05

!text 0, "TOP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TOP:
  ent                            ; 10ef: 22
  !16 DOVAR, 0x0000              ; 10f0: 34 05 00 00

!text 0, "STATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
STATE:
  ent                            ; 10fe: 22
  !16 DOVAR, 0x0000              ; 10ff: 34 05 00 00

!text 0, "PROBE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PROBE:
  ent                            ; 110d: 22
  !16 lit, 0x1fff                ; 110e: 50 05 ff 1f
.PROBE_1:
  !16 DUP                        ; 1112: 49 06
  !16 lit, 0x2000                ; 1114: 50 05 00 20
  !16 _add ; +                   ; 1118: 8f 07
  !16 DUP                        ; 111a: 49 06
  !16 c_load ; C@                ; 111c: 7f 07
  !16 DUP                        ; 111e: 49 06
  !16 INVERT                     ; 1120: b2 08
  !16 _2over ; 2OVER             ; 1122: c1 06
  !16 store ; !                  ; 1124: 38 07
  !16 DUP                        ; 1126: 49 06
  !16 _2over ; 2OVER             ; 1128: c1 06
  !16 c_load ; C@                ; 112a: 7f 07
  !16 eq ; =                     ; 112c: e5 09
  !16 SWAP                       ; 112e: 8d 06
  !16 _2over ; 2OVER             ; 1130: c1 06
  !16 c_store ; C!               ; 1132: 64 07
  !16 branch_if, .PROBE_0        ; 1134: 7d 05 3c 11
  !16 DROP                       ; 1138: 75 06
  !16 EXIT                       ; 113a: 5c 05
.PROBE_0:
  !16 NIP                        ; 113c: 0b 07
  !16 DUP                        ; 113e: 49 06
  !16 lit, 0xffff                ; 1140: 50 05 ff ff
  !16 eq ; =                     ; 1144: e5 09
  !16 branch_if, .PROBE_1        ; 1146: 7d 05 12 11
  !16 EXIT                       ; 114a: 5c 05

!text 0, "FREE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FREE:
  ent                            ; 1155: 22
  !16 TOP                        ; 1156: ef 10
  !16 load ; @                   ; 1158: 73 07
  !16 HERE                       ; 115a: e0 10
  !16 _sub ; -                   ; 115c: 9c 07
  !16 EXIT                       ; 115e: 5c 05

!text 0, "ALLOT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ALLOT:
  ent                            ; 116a: 22
  !16 DUP                        ; 116b: 49 06
  !16 lit, 0x0002                ; 116d: 50 05 02 00
  !16 _add ; +                   ; 1171: 8f 07
  !16 FREE                       ; 1173: 55 11
  !16 ugt ; U>                   ; 1175: a2 09
  !16 branch_if, .ALLOT_0        ; 1177: 7d 05 8f 11
  !16 print_str_lit ; (.")       ; 117b: e2 0f
  !text "Out of memory", 0
  !16 CR                         ; 118b: c7 0e
  !16 ABORT                      ; 118d: a1 10
.ALLOT_0:
  !16 HERE                       ; 118f: e0 10
  !16 SWAP                       ; 1191: 8d 06
  !16 here_var ; (HERE)          ; 1193: d2 10
  !16 inc_word ; +!              ; 1195: 44 07
  !16 EXIT                       ; 1197: 5c 05

!text 0, ",", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push:
  ent                            ; 119f: 22
  !16 CELL                       ; 11a0: fd 09
  !16 ALLOT                      ; 11a2: 6a 11
  !16 store ; !                  ; 11a4: 38 07
  !16 EXIT                       ; 11a6: 5c 05

!text 0, ",C", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push_char:
  ent                            ; 11af: 22
  !16 lit, 0x0001                ; 11b0: 50 05 01 00
  !16 ALLOT                      ; 11b4: 6a 11
  !16 c_store ; C!               ; 11b6: 64 07
  !16 EXIT                       ; 11b8: 5c 05

!text 0, ",S", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
allot_push_str:
  ent                            ; 11c1: 22
.allot_push_str_1:
  !16 DUP                        ; 11c2: 49 06
  !16 c_load ; C@                ; 11c4: 7f 07
  !16 branch_if, .allot_push_str_0 ; 11c6: 7d 05 d6 11
  !16 DUP                        ; 11ca: 49 06
  !16 c_load ; C@                ; 11cc: 7f 07
  !16 allot_push_char ; ,C       ; 11ce: af 11
  !16 add1 ; 1+                  ; 11d0: d1 08
  !16 branch, .allot_push_str_1  ; 11d2: 6b 05 c2 11
.allot_push_str_0:
  !16 DROP                       ; 11d6: 75 06
  !16 lit, 0x0000                ; 11d8: 50 05 00 00
  !16 allot_push_char ; ,C       ; 11dc: af 11
  !16 EXIT                       ; 11de: 5c 05

!text 0, "TIBWORD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBWORD:
  ent                            ; 11ec: 22
  !16 TIBPTR                     ; 11ed: b3 10
  !16 load ; @                   ; 11ef: 73 07
  !16 WORD                       ; 11f1: 98 0b
  !16 SWAP                       ; 11f3: 8d 06
  !16 TIBPTR                     ; 11f5: b3 10
  !16 store ; !                  ; 11f7: 38 07
  !16 EXIT                       ; 11f9: 5c 05

!text 0, "TIBSPLIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TIBSPLIT:
  ent                            ; 1208: 22
  !16 TIBPTR                     ; 1209: b3 10
  !16 load ; @                   ; 120b: 73 07
  !16 SWAP                       ; 120d: 8d 06
  !16 SPLIT                      ; 120f: 3b 0c
  !16 SWAP                       ; 1211: 8d 06
  !16 TIBPTR                     ; 1213: b3 10
  !16 store ; !                  ; 1215: 38 07
  !16 EXIT                       ; 1217: 5c 05

!text 0, "HEADER", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HEADER:
  ent                            ; 1224: 22
  !16 lit, 0x0000                ; 1225: 50 05 00 00
  !16 allot_push_char ; ,C       ; 1229: af 11
  !16 TIBWORD                    ; 122b: ec 11
  !16 allot_push_str ; ,S        ; 122d: c1 11
  !16 lit, 0x0000                ; 122f: 50 05 00 00
  !16 allot_push_char ; ,C       ; 1233: af 11
  !16 VOCAB                      ; 1235: c2 10
  !16 load ; @                   ; 1237: 73 07
  !16 allot_push ; ,             ; 1239: 9f 11
  !16 HERE                       ; 123b: e0 10
  !16 VOCAB                      ; 123d: c2 10
  !16 store ; !                  ; 123f: 38 07
  !16 EXIT                       ; 1241: 5c 05

!text 0, "CONSTANT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CONSTANT:
  ent                            ; 1250: 22
  !16 HEADER                     ; 1251: 24 12
  !16 lit, 0x0022                ; 1253: 50 05 22 00
  !16 allot_push_char ; ,C       ; 1257: af 11
  !16 lit, DOCON                 ; 1259: 50 05 24 05
  !16 allot_push ; ,             ; 125d: 9f 11
  !16 allot_push ; ,             ; 125f: 9f 11
  !16 EXIT                       ; 1261: 5c 05

!text 0, "CREATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
CREATE:
  ent                            ; 126e: 22
  !16 HEADER                     ; 126f: 24 12
  !16 lit, 0x0022                ; 1271: 50 05 22 00
  !16 allot_push_char ; ,C       ; 1275: af 11
  !16 lit, DOVAR                 ; 1277: 50 05 34 05
  !16 allot_push ; ,             ; 127b: 9f 11
  !16 EXIT                       ; 127d: 5c 05

!text 0, "VARIABLE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
VARIABLE:
  ent                            ; 128c: 22
  !16 CREATE                     ; 128d: 6e 12
  !16 lit, 0x0000                ; 128f: 50 05 00 00
  !16 allot_push ; ,             ; 1293: 9f 11
  !16 EXIT                       ; 1295: 5c 05

!text 0, "[", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
comp_enter:
  ent                            ; 129d: 22
  !16 lit, 0x0001                ; 129e: 50 05 01 00
  !16 STATE                      ; 12a2: fe 10
  !16 store ; !                  ; 12a4: 38 07
  !16 EXIT                       ; 12a6: 5c 05

!text 0, "]", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
comp_exit:
  ent                            ; 12ae: 22
  !16 lit, 0x0000                ; 12af: 50 05 00 00
  !16 STATE                      ; 12b3: fe 10
  !16 store ; !                  ; 12b5: 38 07
  !16 EXIT                       ; 12b7: 5c 05

!text 0, "HIDE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
HIDE:
  ent                            ; 12c2: 22
  !16 VOCAB                      ; 12c3: c2 10
  !16 load ; @                   ; 12c5: 73 07
  !16 lit, 0x0003                ; 12c7: 50 05 03 00
  !16 _sub ; -                   ; 12cb: 9c 07
  !16 DUP                        ; 12cd: 49 06
  !16 c_load ; C@                ; 12cf: 7f 07
  !16 lit, 0x0002                ; 12d1: 50 05 02 00
  !16 OR                         ; 12d5: 93 08
  !16 SWAP                       ; 12d7: 8d 06
  !16 c_store ; C!               ; 12d9: 64 07
  !16 EXIT                       ; 12db: 5c 05

!text 0, "REVEAL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
REVEAL:
  ent                            ; 12e8: 22
  !16 VOCAB                      ; 12e9: c2 10
  !16 load ; @                   ; 12eb: 73 07
  !16 lit, 0x0003                ; 12ed: 50 05 03 00
  !16 _sub ; -                   ; 12f1: 9c 07
  !16 DUP                        ; 12f3: 49 06
  !16 c_load ; C@                ; 12f5: 7f 07
  !16 lit, 0x0001                ; 12f7: 50 05 01 00
  !16 _and ; AND                 ; 12fb: 86 08
  !16 SWAP                       ; 12fd: 8d 06
  !16 c_store ; C!               ; 12ff: 64 07
  !16 EXIT                       ; 1301: 5c 05

!text 0, "IMMEDIATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IMMEDIATE:
  ent                            ; 1311: 22
  !16 VOCAB                      ; 1312: c2 10
  !16 load ; @                   ; 1314: 73 07
  !16 lit, 0x0003                ; 1316: 50 05 03 00
  !16 _sub ; -                   ; 131a: 9c 07
  !16 DUP                        ; 131c: 49 06
  !16 c_load ; C@                ; 131e: 7f 07
  !16 lit, 0x0001                ; 1320: 50 05 01 00
  !16 OR                         ; 1324: 93 08
  !16 SWAP                       ; 1326: 8d 06
  !16 c_store ; C!               ; 1328: 64 07
  !16 EXIT                       ; 132a: 5c 05

!text 0, "(does)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_does:
  ent                            ; 1337: 22
  !16 pull_r ; R>                ; 1338: 2f 07
  !16 VOCAB                      ; 133a: c2 10
  !16 load ; @                   ; 133c: 73 07
  !16 add1 ; 1+                  ; 133e: d1 08
  !16 store ; !                  ; 1340: 38 07
  !16 EXIT                       ; 1342: 5c 05

!text 0, "DOES>", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
does_right:
  ent                            ; 134e: 22
  !16 lit, _does                 ; 134f: 50 05 37 13
  !16 allot_push ; ,             ; 1353: 9f 11
  !16 lit, 0x0022                ; 1355: 50 05 22 00
  !16 allot_push_char ; ,C       ; 1359: af 11
  !16 lit, DODOES                ; 135b: 50 05 43 05
  !16 allot_push ; ,             ; 135f: 9f 11
  !16 EXIT                       ; 1361: 5c 05

!text 0, ":", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
compile:
  ent                            ; 1369: 22
  !16 HEADER                     ; 136a: 24 12
  !16 HIDE                       ; 136c: c2 12
  !16 lit, 0x0022                ; 136e: 50 05 22 00
  !16 allot_push_char ; ,C       ; 1372: af 11
  !16 comp_enter ; [             ; 1374: 9d 12
  !16 EXIT                       ; 1376: 5c 05

!text 0, ";", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
compile_end:
  ent                            ; 137e: 22
  !16 lit, EXIT                  ; 137f: 50 05 5c 05
  !16 allot_push ; ,             ; 1383: 9f 11
  !16 comp_exit ; ]              ; 1385: ae 12
  !16 REVEAL                     ; 1387: e8 12
  !16 EXIT                       ; 1389: 5c 05

!text 0, "IF", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
IF:
  ent                            ; 1392: 22
  !16 lit, branch_if             ; 1393: 50 05 7d 05
  !16 allot_push ; ,             ; 1397: 9f 11
  !16 HERE                       ; 1399: e0 10
  !16 lit, 0x0000                ; 139b: 50 05 00 00
  !16 allot_push ; ,             ; 139f: 9f 11
  !16 lit, 0x0000                ; 13a1: 50 05 00 00
  !16 EXIT                       ; 13a5: 5c 05

!text 0, "THEN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
THEN:
  ent                            ; 13b0: 22
  !16 DROP                       ; 13b1: 75 06
  !16 HERE                       ; 13b3: e0 10
  !16 SWAP                       ; 13b5: 8d 06
  !16 store ; !                  ; 13b7: 38 07
  !16 EXIT                       ; 13b9: 5c 05

!text 0, "ELSE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
ELSE:
  ent                            ; 13c4: 22
  !16 DROP                       ; 13c5: 75 06
  !16 lit, branch                ; 13c7: 50 05 6b 05
  !16 allot_push ; ,             ; 13cb: 9f 11
  !16 HERE                       ; 13cd: e0 10
  !16 lit, 0x0000                ; 13cf: 50 05 00 00
  !16 allot_push ; ,             ; 13d3: 9f 11
  !16 SWAP                       ; 13d5: 8d 06
  !16 HERE                       ; 13d7: e0 10
  !16 SWAP                       ; 13d9: 8d 06
  !16 store ; !                  ; 13db: 38 07
  !16 lit, 0x0000                ; 13dd: 50 05 00 00
  !16 EXIT                       ; 13e1: 5c 05

!text 0, ".\"", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
print_str:
  ent                            ; 13ea: 22
  !16 lit, print_str_lit         ; 13eb: 50 05 e2 0f
  !16 allot_push ; ,             ; 13ef: 9f 11
  !16 lit, 0x0022                ; 13f1: 50 05 22 00
  !16 TIBSPLIT                   ; 13f5: 08 12
  !16 allot_push_str ; ,S        ; 13f7: c1 11
  !16 EXIT                       ; 13f9: 5c 05

!text 0, "BEGIN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
BEGIN:
  ent                            ; 1405: 22
  !16 HERE                       ; 1406: e0 10
  !16 lit, 0x0000                ; 1408: 50 05 00 00
  !16 EXIT                       ; 140c: 5c 05

!text 0, "AGAIN", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
AGAIN:
  ent                            ; 1418: 22
  !16 DROP                       ; 1419: 75 06
  !16 lit, branch                ; 141b: 50 05 6b 05
  !16 allot_push ; ,             ; 141f: 9f 11
  !16 allot_push ; ,             ; 1421: 9f 11
  !16 EXIT                       ; 1423: 5c 05

!text 0, "UNTIL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
UNTIL:
  ent                            ; 142f: 22
  !16 DROP                       ; 1430: 75 06
  !16 lit, branch_if             ; 1432: 50 05 7d 05
  !16 allot_push ; ,             ; 1436: 9f 11
  !16 allot_push ; ,             ; 1438: 9f 11
  !16 EXIT                       ; 143a: 5c 05

!text 0, "WHILE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
WHILE:
  ent                            ; 1446: 22
  !16 lit, branch_if             ; 1447: 50 05 7d 05
  !16 allot_push ; ,             ; 144b: 9f 11
  !16 HERE                       ; 144d: e0 10
  !16 lit, 0x0000                ; 144f: 50 05 00 00
  !16 allot_push ; ,             ; 1453: 9f 11
  !16 lit, 0x0000                ; 1455: 50 05 00 00
  !16 EXIT                       ; 1459: 5c 05

!text 0, "REPEAT", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
REPEAT:
  ent                            ; 1466: 22
  !16 DROP                       ; 1467: 75 06
  !16 NIP                        ; 1469: 0b 07
  !16 SWAP                       ; 146b: 8d 06
  !16 lit, branch                ; 146d: 50 05 6b 05
  !16 allot_push ; ,             ; 1471: 9f 11
  !16 allot_push ; ,             ; 1473: 9f 11
  !16 HERE                       ; 1475: e0 10
  !16 SWAP                       ; 1477: 8d 06
  !16 store ; !                  ; 1479: 38 07
  !16 EXIT                       ; 147b: 5c 05

!text 0, "DO", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
DO:
  ent                            ; 1484: 22
  !16 lit, do                    ; 1485: 50 05 8d 05
  !16 allot_push ; ,             ; 1489: 9f 11
  !16 HERE                       ; 148b: e0 10
  !16 lit, 0x0000                ; 148d: 50 05 00 00
  !16 allot_push ; ,             ; 1491: 9f 11
  !16 HERE                       ; 1493: e0 10
  !16 SWAP                       ; 1495: 8d 06
  !16 EXIT                       ; 1497: 5c 05

!text 0, "?DO", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
do_if:
  ent                            ; 14a1: 22
  !16 lit, _do_if                ; 14a2: 50 05 a2 05
  !16 allot_push ; ,             ; 14a6: 9f 11
  !16 HERE                       ; 14a8: e0 10
  !16 lit, 0x0000                ; 14aa: 50 05 00 00
  !16 allot_push ; ,             ; 14ae: 9f 11
  !16 HERE                       ; 14b0: e0 10
  !16 SWAP                       ; 14b2: 8d 06
  !16 EXIT                       ; 14b4: 5c 05

!text 0, "LOOP", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LOOP:
  ent                            ; 14bf: 22
  !16 SWAP                       ; 14c0: 8d 06
  !16 lit, loop                  ; 14c2: 50 05 bf 05
  !16 allot_push ; ,             ; 14c6: 9f 11
  !16 allot_push ; ,             ; 14c8: 9f 11
  !16 lit, UNLOOP                ; 14ca: 50 05 14 06
  !16 allot_push ; ,             ; 14ce: 9f 11
  !16 HERE                       ; 14d0: e0 10
  !16 SWAP                       ; 14d2: 8d 06
  !16 store ; !                  ; 14d4: 38 07
  !16 EXIT                       ; 14d6: 5c 05

!text 0, "+LOOP", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
loop_add:
  ent                            ; 14e2: 22
  !16 SWAP                       ; 14e3: 8d 06
  !16 lit, _loop_add             ; 14e5: 50 05 de 05
  !16 allot_push ; ,             ; 14e9: 9f 11
  !16 allot_push ; ,             ; 14eb: 9f 11
  !16 lit, UNLOOP                ; 14ed: 50 05 14 06
  !16 allot_push ; ,             ; 14f1: 9f 11
  !16 HERE                       ; 14f3: e0 10
  !16 SWAP                       ; 14f5: 8d 06
  !16 store ; !                  ; 14f7: 38 07
  !16 EXIT                       ; 14f9: 5c 05

!text 0, "LEAVE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LEAVE:
  ent                            ; 1505: 22
  !16 lit, 0x0001                ; 1506: 50 05 01 00
.LEAVE_1:
  !16 DUP                        ; 150a: 49 06
  !16 PICK                       ; 150c: 9b 06
  !16 eq0 ; 0=                   ; 150e: 13 09
  !16 branch_if, .LEAVE_0        ; 1510: 7d 05 1e 15
  !16 lit, 0x0002                ; 1514: 50 05 02 00
  !16 _add ; +                   ; 1518: 8f 07
  !16 branch, .LEAVE_1           ; 151a: 6b 05 0a 15
.LEAVE_0:
  !16 lit, leave                 ; 151e: 50 05 00 06
  !16 allot_push ; ,             ; 1522: 9f 11
  !16 PICK                       ; 1524: 9b 06
  !16 lit, 0x0002                ; 1526: 50 05 02 00
  !16 _sub ; -                   ; 152a: 9c 07
  !16 allot_push ; ,             ; 152c: 9f 11
  !16 EXIT                       ; 152e: 5c 05

!text 0, "\\", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
line_comment:
  ent                            ; 1536: 22
  !16 lit, 0x000d                ; 1537: 50 05 0d 00
  !16 TIBSPLIT                   ; 153b: 08 12
  !16 DROP                       ; 153d: 75 06
  !16 EXIT                       ; 153f: 5c 05

!text 0, "(", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
paren_comment:
  ent                            ; 1547: 22
  !16 lit, 0x0029                ; 1548: 50 05 29 00
  !16 TIBSPLIT                   ; 154c: 08 12
  !16 DROP                       ; 154e: 75 06
  !16 EXIT                       ; 1550: 5c 05

!text 0, "(\")", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
str_lit:
  ent                            ; 155a: 22
  !16 pull_r ; R>                ; 155b: 2f 07
  !16 DUP                        ; 155d: 49 06
.str_lit_1:
  !16 DUP                        ; 155f: 49 06
  !16 c_load ; C@                ; 1561: 7f 07
  !16 branch_if, .str_lit_0      ; 1563: 7d 05 6d 15
  !16 add1 ; 1+                  ; 1567: d1 08
  !16 branch, .str_lit_1         ; 1569: 6b 05 5f 15
.str_lit_0:
  !16 add1 ; 1+                  ; 156d: d1 08
  !16 push_r ; >R                ; 156f: 25 07
  !16 EXIT                       ; 1571: 5c 05

!text 0, "\"", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
str:
  ent                            ; 1579: 22
  !16 lit, str_lit               ; 157a: 50 05 5a 15
  !16 allot_push ; ,             ; 157e: 9f 11
  !16 lit, 0x0022                ; 1580: 50 05 22 00
  !16 TIBSPLIT                   ; 1584: 08 12
  !16 allot_push_str ; ,S        ; 1586: c1 11
  !16 EXIT                       ; 1588: 5c 05

!text 0, "TIMES", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
TIMES:
  ent                            ; 1594: 22
  !16 STATE                      ; 1595: fe 10
  !16 load ; @                   ; 1597: 73 07
  !16 eq0 ; 0=                   ; 1599: 13 09
  !16 branch_if, .TIMES_0        ; 159b: 7d 05 bb 15
  !16 find_name ; '              ; 159f: f1 18
  !16 SWAP                       ; 15a1: 8d 06
  !16 lit, 0x0000                ; 15a3: 50 05 00 00
  !16 _do_if, .TIMES_1           ; 15a7: a2 05 b5 15
.TIMES_2:
  !16 DUP                        ; 15ab: 49 06
  !16 EXECUTE                    ; 15ad: 3d 06
  !16 loop, .TIMES_2             ; 15af: bf 05 ab 15
  !16 UNLOOP                     ; 15b3: 14 06
.TIMES_1:
  !16 DROP                       ; 15b5: 75 06
  !16 branch, .TIMES_3           ; 15b7: 6b 05 f1 15
.TIMES_0:
  !16 find_name ; '              ; 15bb: f1 18
  !16 lit, lit                   ; 15bd: 50 05 50 05
  !16 allot_push ; ,             ; 15c1: 9f 11
  !16 lit, 0x0000                ; 15c3: 50 05 00 00
  !16 allot_push ; ,             ; 15c7: 9f 11
  !16 lit, _do_if                ; 15c9: 50 05 a2 05
  !16 allot_push ; ,             ; 15cd: 9f 11
  !16 HERE                       ; 15cf: e0 10
  !16 lit, 0x000a                ; 15d1: 50 05 0a 00
  !16 _add ; +                   ; 15d5: 8f 07
  !16 allot_push ; ,             ; 15d7: 9f 11
  !16 allot_push ; ,             ; 15d9: 9f 11
  !16 HERE                       ; 15db: e0 10
  !16 lit, 0x0002                ; 15dd: 50 05 02 00
  !16 _sub ; -                   ; 15e1: 9c 07
  !16 lit, loop                  ; 15e3: 50 05 bf 05
  !16 allot_push ; ,             ; 15e7: 9f 11
  !16 allot_push ; ,             ; 15e9: 9f 11
  !16 lit, UNLOOP                ; 15eb: 50 05 14 06
  !16 allot_push ; ,             ; 15ef: 9f 11
.TIMES_3:
  !16 EXIT                       ; 15f1: 5c 05

!text 0, "LITERAL", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
LITERAL:
  ent                            ; 15ff: 22
  !16 find_name ; '              ; 1600: f1 18
  !16 lit, lit                   ; 1602: 50 05 50 05
  !16 allot_push ; ,             ; 1606: 9f 11
  !16 allot_push ; ,             ; 1608: 9f 11
  !16 EXIT                       ; 160a: 5c 05

!text 0, "POSTPONE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
POSTPONE:
  ent                            ; 1619: 22
  !16 find_name ; '              ; 161a: f1 18
  !16 DUP                        ; 161c: 49 06
  !16 lit, 0x0003                ; 161e: 50 05 03 00
  !16 _sub ; -                   ; 1622: 9c 07
  !16 c_load ; C@                ; 1624: 7f 07
  !16 lit, 0x0001                ; 1626: 50 05 01 00
  !16 _and ; AND                 ; 162a: 86 08
  !16 branch_if, .POSTPONE_0     ; 162c: 7d 05 36 16
  !16 allot_push ; ,             ; 1630: 9f 11
  !16 branch, .POSTPONE_1        ; 1632: 6b 05 3e 16
.POSTPONE_0:
  !16 lit, lit                   ; 1636: 50 05 50 05
  !16 allot_push ; ,             ; 163a: 9f 11
  !16 allot_push ; ,             ; 163c: 9f 11
.POSTPONE_1:
  !16 EXIT                       ; 163e: 5c 05

!text 0, "RECURSE", 0 ; name
!8 .FLAG_IMM
!16 prev
!set prev = *
RECURSE:
  ent                            ; 164c: 22
  !16 VOCAB                      ; 164d: c2 10
  !16 load ; @                   ; 164f: 73 07
  !16 allot_push ; ,             ; 1651: 9f 11
  !16 EXIT                       ; 1653: 5c 05

!text 0, "TICKS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
TICKS:
  ent                            ; 165f: 22
.TICKS_1:
  !16 dup_if ; ?DUP              ; 1660: 56 06
  !16 branch_if, .TICKS_0        ; 1662: 7d 05 6e 16
  !16 TICK                       ; 1666: a5 0d
  !16 sub1 ; 1-                  ; 1668: dc 08
  !16 branch, .TICKS_1           ; 166a: 6b 05 60 16
.TICKS_0:
  !16 EXIT                       ; 166e: 5c 05

!text 0, "SP0", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SP0:
  ent                            ; 1678: 22
  !16 DOCON, 0x0200              ; 1679: 24 05 00 02

!text 0, "RP0", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
RP0:
  ent                            ; 1685: 22
  !16 DOCON, 0x0300              ; 1686: 24 05 00 03

!text 0, ">NAME", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
to_name:
  ent                            ; 1694: 22
  !16 lit, 0x0005                ; 1695: 50 05 05 00
  !16 _sub ; -                   ; 1699: 9c 07
  !16 DUP                        ; 169b: 49 06
  !16 RSTRLEN                    ; 169d: cd 0a
  !16 _sub ; -                   ; 169f: 9c 07
  !16 add1 ; 1+                  ; 16a1: d1 08
  !16 EXIT                       ; 16a3: 5c 05

!text 0, "NAME>", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
from_name:
  ent                            ; 16af: 22
  !16 DUP                        ; 16b0: 49 06
  !16 STRLEN                     ; 16b2: a9 0a
  !16 _add ; +                   ; 16b4: 8f 07
  !16 lit, 0x0006                ; 16b6: 50 05 06 00
  !16 _add ; +                   ; 16ba: 8f 07
  !16 EXIT                       ; 16bc: 5c 05

!text 0, "FIND", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FIND:
  ent                            ; 16c7: 22
  !16 VOCAB                      ; 16c8: c2 10
  !16 load ; @                   ; 16ca: 73 07
.FIND_4:
  !16 DUP                        ; 16cc: 49 06
  !16 branch_if, .FIND_0         ; 16ce: 7d 05 04 17
  !16 _2dup ; 2DUP               ; 16d2: 65 06
  !16 to_name ; >NAME            ; 16d4: 94 16
  !16 STRCMP                     ; 16d6: 8f 0c
  !16 eq0 ; 0=                   ; 16d8: 13 09
  !16 OVER                       ; 16da: b3 06
  !16 lit, 0x0003                ; 16dc: 50 05 03 00
  !16 _sub ; -                   ; 16e0: 9c 07
  !16 c_load ; C@                ; 16e2: 7f 07
  !16 lit, 0x0002                ; 16e4: 50 05 02 00
  !16 _and ; AND                 ; 16e8: 86 08
  !16 eq0 ; 0=                   ; 16ea: 13 09
  !16 _and ; AND                 ; 16ec: 86 08
  !16 branch_if, .FIND_1         ; 16ee: 7d 05 f8 16
  !16 TRUE                       ; 16f2: ef 0a
  !16 branch, .FIND_2            ; 16f4: 6b 05 00 17
.FIND_1:
  !16 CELL                       ; 16f8: fd 09
  !16 _sub ; -                   ; 16fa: 9c 07
  !16 load ; @                   ; 16fc: 73 07
  !16 FALSE                      ; 16fe: fe 0a
.FIND_2:
  !16 branch, .FIND_3            ; 1700: 6b 05 06 17
.FIND_0:
  !16 TRUE                       ; 1704: ef 0a
.FIND_3:
  !16 branch_if, .FIND_4         ; 1706: 7d 05 cc 16
  !16 NIP                        ; 170a: 0b 07
  !16 EXIT                       ; 170c: 5c 05

!text 0, "ACCEPT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
ACCEPT:
  ent                            ; 1719: 22
  !16 OVER                       ; 171a: b3 06
  !16 _add ; +                   ; 171c: 8f 07
  !16 sub1 ; 1-                  ; 171e: dc 08
  !16 OVER                       ; 1720: b3 06
.ACCEPT_4:
  !16 KEY                        ; 1722: 9e 0f
  !16 DUP                        ; 1724: 49 06
  !16 lit, 0x000d                ; 1726: 50 05 0d 00
  !16 neq ; <>                   ; 172a: 48 09
  !16 branch_if, .ACCEPT_0       ; 172c: 7d 05 62 17
  !16 DUP                        ; 1730: 49 06
  !16 lit, 0x0008                ; 1732: 50 05 08 00
  !16 eq ; =                     ; 1736: e5 09
  !16 branch_if, .ACCEPT_1       ; 1738: 7d 05 50 17
  !16 DROP                       ; 173c: 75 06
  !16 _2over ; 2OVER             ; 173e: c1 06
  !16 OVER                       ; 1740: b3 06
  !16 lt ; <                     ; 1742: 5d 09
  !16 branch_if, .ACCEPT_2       ; 1744: 7d 05 4c 17
  !16 BS                         ; 1748: 55 0f
  !16 sub1 ; 1-                  ; 174a: dc 08
.ACCEPT_2:
  !16 branch, .ACCEPT_3          ; 174c: 6b 05 5e 17
.ACCEPT_1:
  !16 DUP                        ; 1750: 49 06
  !16 EMIT                       ; 1752: 07 0f
  !16 OVER                       ; 1754: b3 06
  !16 c_store ; C!               ; 1756: 64 07
  !16 add1 ; 1+                  ; 1758: d1 08
  !16 OVER                       ; 175a: b3 06
  !16 MIN                        ; 175c: 28 0a
.ACCEPT_3:
  !16 branch, .ACCEPT_4          ; 175e: 6b 05 22 17
.ACCEPT_0:
  !16 DROP                       ; 1762: 75 06
  !16 MIN                        ; 1764: 28 0a
  !16 lit, 0x0000                ; 1766: 50 05 00 00
  !16 SWAP                       ; 176a: 8d 06
  !16 c_store ; C!               ; 176c: 64 07
  !16 EXIT                       ; 176e: 5c 05

!text 0, "0SP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
_0sp:
  ent                            ; 1778: 22
  !16 SP0                        ; 1779: 78 16
  !16 sp_store ; SP!             ; 177b: f3 08
  !16 EXIT                       ; 177d: 5c 05

!text 0, "INTERPRET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
INTERPRET:
  ent                            ; 178d: 22
.INTERPRET_10:
  !16 WORD                       ; 178e: 98 0b
  !16 DUP                        ; 1790: 49 06
  !16 STRLEN                     ; 1792: a9 0a
  !16 neq0 ; 0<>                 ; 1794: 26 09
  !16 branch_if, .INTERPRET_0    ; 1796: 7d 05 1a 18
  !16 SWAP                       ; 179a: 8d 06
  !16 TIBPTR                     ; 179c: b3 10
  !16 store ; !                  ; 179e: 38 07
  !16 DUP                        ; 17a0: 49 06
  !16 FIND                       ; 17a2: c7 16
  !16 dup_if ; ?DUP              ; 17a4: 56 06
  !16 branch_if, .INTERPRET_1    ; 17a6: 7d 05 da 17
  !16 NIP                        ; 17aa: 0b 07
  !16 STATE                      ; 17ac: fe 10
  !16 load ; @                   ; 17ae: 73 07
  !16 branch_if, .INTERPRET_2    ; 17b0: 7d 05 d4 17
  !16 DUP                        ; 17b4: 49 06
  !16 lit, 0x0003                ; 17b6: 50 05 03 00
  !16 _sub ; -                   ; 17ba: 9c 07
  !16 c_load ; C@                ; 17bc: 7f 07
  !16 lit, 0x0001                ; 17be: 50 05 01 00
  !16 _and ; AND                 ; 17c2: 86 08
  !16 branch_if, .INTERPRET_3    ; 17c4: 7d 05 ce 17
  !16 EXECUTE                    ; 17c8: 3d 06
  !16 branch, .INTERPRET_4       ; 17ca: 6b 05 d0 17
.INTERPRET_3:
  !16 allot_push ; ,             ; 17ce: 9f 11
.INTERPRET_4:
  !16 branch, .INTERPRET_5       ; 17d0: 6b 05 d6 17
.INTERPRET_2:
  !16 EXECUTE                    ; 17d4: 3d 06
.INTERPRET_5:
  !16 branch, .INTERPRET_6       ; 17d6: 6b 05 12 18
.INTERPRET_1:
  !16 DUP                        ; 17da: 49 06
  !16 c_load ; C@                ; 17dc: 7f 07
  !16 ISNUM                      ; 17de: e2 0c
  !16 branch_if, .INTERPRET_7    ; 17e0: 7d 05 fa 17
  !16 ATOI                       ; 17e4: 55 0d
  !16 STATE                      ; 17e6: fe 10
  !16 load ; @                   ; 17e8: 73 07
  !16 branch_if, .INTERPRET_8    ; 17ea: 7d 05 f6 17
  !16 lit, lit                   ; 17ee: 50 05 50 05
  !16 allot_push ; ,             ; 17f2: 9f 11
  !16 allot_push ; ,             ; 17f4: 9f 11
.INTERPRET_8:
  !16 branch, .INTERPRET_6       ; 17f6: 6b 05 12 18
.INTERPRET_7:
  !16 print_str_lit ; (.")       ; 17fa: e2 0f
  !text "Unknown Token: ", 0
  !16 TYPE                       ; 180c: 17 10
  !16 CR                         ; 180e: c7 0e
  !16 ABORT                      ; 1810: a1 10
.INTERPRET_6:
  !16 TIBPTR                     ; 1812: b3 10
  !16 load ; @                   ; 1814: 73 07
  !16 branch, .INTERPRET_10      ; 1816: 6b 05 8e 17
.INTERPRET_0:
  !16 DROP                       ; 181a: 75 06
  !16 DROP                       ; 181c: 75 06
  !16 EXIT                       ; 181e: 5c 05

!text 0, "QUIT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
QUIT:
  ent                            ; 1829: 22
  !16 RP0                        ; 182a: 85 16
  !16 rp_store ; RP!             ; 182c: 09 09
  !16 lit, 0x0000                ; 182e: 50 05 00 00
  !16 STATE                      ; 1832: fe 10
  !16 store ; !                  ; 1834: 38 07
.QUIT_3:
  !16 DEPTH                      ; 1836: b6 18
  !16 lt0 ; 0<                   ; 1838: 36 09
  !16 branch_if, .QUIT_0         ; 183a: 7d 05 50 18
  !16 print_str_lit ; (.")       ; 183e: e2 0f
  !text "Empty Stack", 0
  !16 SP0                        ; 184c: 78 16
  !16 sp_store ; SP!             ; 184e: f3 08
.QUIT_0:
  !16 CR                         ; 1850: c7 0e
  !16 STATE                      ; 1852: fe 10
  !16 load ; @                   ; 1854: 73 07
  !16 eq0 ; 0=                   ; 1856: 13 09
  !16 branch_if, .QUIT_1         ; 1858: 7d 05 65 18
  !16 print_str_lit ; (.")       ; 185c: e2 0f
  !text "> ", 0
  !16 branch, .QUIT_2            ; 1861: 6b 05 71 18
.QUIT_1:
  !16 print_str_lit ; (.")       ; 1865: e2 0f
  !text "compile: ", 0
.QUIT_2:
  !16 TIB                        ; 1871: 1c 0b
  !16 lit, 0x0078                ; 1873: 50 05 78 00
  !16 ACCEPT                     ; 1877: 19 17
  !16 SPACE                      ; 1879: 07 10
  !16 INTERPRET                  ; 187b: 8d 17
  !16 branch, .QUIT_3            ; 187d: 6b 05 36 18

!text 0, "WORDS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WORDS:
  ent                            ; 188b: 22
  !16 VOCAB                      ; 188c: c2 10
  !16 load ; @                   ; 188e: 73 07
.WORDS_1:
  !16 DUP                        ; 1890: 49 06
  !16 branch_if, .WORDS_0        ; 1892: 7d 05 a8 18
  !16 DUP                        ; 1896: 49 06
  !16 to_name ; >NAME            ; 1898: 94 16
  !16 TYPE                       ; 189a: 17 10
  !16 SPACE                      ; 189c: 07 10
  !16 CELL                       ; 189e: fd 09
  !16 _sub ; -                   ; 18a0: 9c 07
  !16 load ; @                   ; 18a2: 73 07
  !16 branch, .WORDS_1           ; 18a4: 6b 05 90 18
.WORDS_0:
  !16 DROP                       ; 18a8: 75 06
  !16 EXIT                       ; 18aa: 5c 05

!text 0, "DEPTH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DEPTH:
  ent                            ; 18b6: 22
  !16 sp_load ; SP@              ; 18b7: e8 08
  !16 SP0                        ; 18b9: 78 16
  !16 SWAP                       ; 18bb: 8d 06
  !16 _sub ; -                   ; 18bd: 9c 07
  !16 div2 ; 2/                  ; 18bf: 51 08
  !16 EXIT                       ; 18c1: 5c 05

!text 0, ".S", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
print_stack:
  ent                            ; 18ca: 22
  !16 DEPTH                      ; 18cb: b6 18
  !16 DUP                        ; 18cd: 49 06
  !16 lit, 0x0000                ; 18cf: 50 05 00 00
  !16 _do_if, .print_stack_0     ; 18d3: a2 05 e7 18
.print_stack_1:
  !16 DUP                        ; 18d7: 49 06
  !16 I                          ; 18d9: 1d 06
  !16 _sub ; -                   ; 18db: 9c 07
  !16 PICK                       ; 18dd: 9b 06
  !16 print_int ; .              ; 18df: 34 10
  !16 loop, .print_stack_1       ; 18e1: bf 05 d7 18
  !16 UNLOOP                     ; 18e5: 14 06
.print_stack_0:
  !16 DROP                       ; 18e7: 75 06
  !16 EXIT                       ; 18e9: 5c 05

!text 0, "'", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
find_name:
  ent                            ; 18f1: 22
  !16 TIBWORD                    ; 18f2: ec 11
  !16 DUP                        ; 18f4: 49 06
  !16 FIND                       ; 18f6: c7 16
  !16 dup_if ; ?DUP              ; 18f8: 56 06
  !16 eq0 ; 0=                   ; 18fa: 13 09
  !16 branch_if, .find_name_0    ; 18fc: 7d 05 1c 19
  !16 print_str_lit ; (.")       ; 1900: e2 0f
  !text "Unknown Token: ", 0
  !16 TYPE                       ; 1912: 17 10
  !16 CR                         ; 1914: c7 0e
  !16 ABORT                      ; 1916: a1 10
  !16 branch, .find_name_1       ; 1918: 6b 05 1e 19
.find_name_0:
  !16 NIP                        ; 191c: 0b 07
.find_name_1:
  !16 EXIT                       ; 191e: 5c 05

!text 0, "FORGET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FORGET:
  ent                            ; 192b: 22
  !16 find_name ; '              ; 192c: f1 18
  !16 DUP                        ; 192e: 49 06
  !16 to_name ; >NAME            ; 1930: 94 16
  !16 sub1 ; 1-                  ; 1932: dc 08
  !16 here_var ; (HERE)          ; 1934: d2 10
  !16 store ; !                  ; 1936: 38 07
  !16 CELL                       ; 1938: fd 09
  !16 _sub ; -                   ; 193a: 9c 07
  !16 load ; @                   ; 193c: 73 07
  !16 VOCAB                      ; 193e: c2 10
  !16 store ; !                  ; 1940: 38 07
  !16 EXIT                       ; 1942: 5c 05

!text 0, "IOXADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXADDR:
  ent                            ; 1950: 22
  !16 DOVAR, 0x0003              ; 1951: 34 05 03 00

!text 0, "IOX@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
iox_read:
  ent                            ; 195e: 22
  !16 IOXADDR                    ; 195f: 50 19
  !16 load ; @                   ; 1961: 73 07
  !16 rbp_store ; RBP!           ; 1963: b0 0d
  !16 lit, 0x0300                ; 1965: 50 05 00 03
  !16 load ; @                   ; 1969: 73 07
  !16 EXIT                       ; 196b: 5c 05

!text 0, "IOX!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
iox_write:
  ent                            ; 1976: 22
  !16 IOXADDR                    ; 1977: 50 19
  !16 load ; @                   ; 1979: 73 07
  !16 rbp_store ; RBP!           ; 197b: b0 0d
  !16 lit, 0x0302                ; 197d: 50 05 02 03
  !16 store ; !                  ; 1981: 38 07
  !16 EXIT                       ; 1983: 5c 05

!text 0, "IOXSET", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXSET:
  ent                            ; 1990: 22
  !16 IOXADDR                    ; 1991: 50 19
  !16 load ; @                   ; 1993: 73 07
  !16 rbp_store ; RBP!           ; 1995: b0 0d
  !16 lit, 0x0302                ; 1997: 50 05 02 03
  !16 load ; @                   ; 199b: 73 07
  !16 OR                         ; 199d: 93 08
  !16 lit, 0x0302                ; 199f: 50 05 02 03
  !16 store ; !                  ; 19a3: 38 07
  !16 EXIT                       ; 19a5: 5c 05

!text 0, "IOXRST", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
IOXRST:
  ent                            ; 19b2: 22
  !16 IOXADDR                    ; 19b3: 50 19
  !16 load ; @                   ; 19b5: 73 07
  !16 rbp_store ; RBP!           ; 19b7: b0 0d
  !16 INVERT                     ; 19b9: b2 08
  !16 lit, 0x0302                ; 19bb: 50 05 02 03
  !16 load ; @                   ; 19bf: 73 07
  !16 _and ; AND                 ; 19c1: 86 08
  !16 lit, 0x0302                ; 19c3: 50 05 02 03
  !16 store ; !                  ; 19c7: 38 07
  !16 EXIT                       ; 19c9: 5c 05

!text 0, "DISKADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKADDR:
  ent                            ; 19d8: 22
  !16 DOVAR, 0x0002              ; 19d9: 34 05 02 00

!text 0, "DISKNAME\"", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
diskname_str:
  ent                            ; 19eb: 22
  !16 lit, 0x0022                ; 19ec: 50 05 22 00
  !16 TIBSPLIT                   ; 19f0: 08 12
  !16 DISKADDR                   ; 19f2: d8 19
  !16 load ; @                   ; 19f4: 73 07
  !16 rbp_store ; RBP!           ; 19f6: b0 0d
  !16 lit, 0x0300                ; 19f8: 50 05 00 03
  !16 OVER                       ; 19fc: b3 06
  !16 STRLEN                     ; 19fe: a9 0a
  !16 add1 ; 1+                  ; 1a00: d1 08
  !16 MOVE                       ; 1a02: 39 0a
  !16 lit, 0x0002                ; 1a04: 50 05 02 00
  !16 lit, 0x0382                ; 1a08: 50 05 82 03
  !16 c_store ; C!               ; 1a0c: 64 07
.diskname_str_1:
  !16 lit, 0x0382                ; 1a0e: 50 05 82 03
  !16 c_load ; C@                ; 1a12: 7f 07
  !16 lit, 0x0002                ; 1a14: 50 05 02 00
  !16 eq ; =                     ; 1a18: e5 09
  !16 branch_if, .diskname_str_0 ; 1a1a: 7d 05 24 1a
  !16 TICK                       ; 1a1e: a5 0d
  !16 branch, .diskname_str_1    ; 1a20: 6b 05 0e 1a
.diskname_str_0:
  !16 EXIT                       ; 1a24: 5c 05

!text 0, "DISKID", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKID:
  ent                            ; 1a31: 22
  !16 DISKADDR                   ; 1a32: d8 19
  !16 load ; @                   ; 1a34: 73 07
  !16 rbp_store ; RBP!           ; 1a36: b0 0d
  !16 lit, 0x0003                ; 1a38: 50 05 03 00
  !16 lit, 0x0382                ; 1a3c: 50 05 82 03
  !16 c_store ; C!               ; 1a40: 64 07
.DISKID_1:
  !16 lit, 0x0382                ; 1a42: 50 05 82 03
  !16 c_load ; C@                ; 1a46: 7f 07
  !16 lit, 0x0003                ; 1a48: 50 05 03 00
  !16 eq ; =                     ; 1a4c: e5 09
  !16 branch_if, .DISKID_0       ; 1a4e: 7d 05 58 1a
  !16 TICK                       ; 1a52: a5 0d
  !16 branch, .DISKID_1          ; 1a54: 6b 05 42 1a
.DISKID_0:
  !16 lit, 0x0300                ; 1a58: 50 05 00 03
  !16 SCRATCH                    ; 1a5c: 0f 0b
  !16 lit, 0x0040                ; 1a5e: 50 05 40 00
  !16 MOVE                       ; 1a62: 39 0a
  !16 SCRATCH                    ; 1a64: 0f 0b
  !16 TYPE                       ; 1a66: 17 10
  !16 EXIT                       ; 1a68: 5c 05

!text 0, "DISKWS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKWS:
  ent                            ; 1a75: 22
  !16 DISKADDR                   ; 1a76: d8 19
  !16 load ; @                   ; 1a78: 73 07
  !16 rbp_store ; RBP!           ; 1a7a: b0 0d
  !16 lit, 0x0380                ; 1a7c: 50 05 80 03
  !16 store ; !                  ; 1a80: 38 07
  !16 lit, 0x0300                ; 1a82: 50 05 00 03
  !16 lit, 0x0080                ; 1a86: 50 05 80 00
  !16 MOVE                       ; 1a8a: 39 0a
  !16 lit, 0x0005                ; 1a8c: 50 05 05 00
  !16 lit, 0x0382                ; 1a90: 50 05 82 03
  !16 c_store ; C!               ; 1a94: 64 07
.DISKWS_1:
  !16 lit, 0x0382                ; 1a96: 50 05 82 03
  !16 c_load ; C@                ; 1a9a: 7f 07
  !16 lit, 0x0005                ; 1a9c: 50 05 05 00
  !16 eq ; =                     ; 1aa0: e5 09
  !16 branch_if, .DISKWS_0       ; 1aa2: 7d 05 ac 1a
  !16 TICK                       ; 1aa6: a5 0d
  !16 branch, .DISKWS_1          ; 1aa8: 6b 05 96 1a
.DISKWS_0:
  !16 EXIT                       ; 1aac: 5c 05

!text 0, "DISKRS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
DISKRS:
  ent                            ; 1ab9: 22
  !16 DISKADDR                   ; 1aba: d8 19
  !16 load ; @                   ; 1abc: 73 07
  !16 rbp_store ; RBP!           ; 1abe: b0 0d
  !16 lit, 0x0380                ; 1ac0: 50 05 80 03
  !16 store ; !                  ; 1ac4: 38 07
  !16 lit, 0x0004                ; 1ac6: 50 05 04 00
  !16 lit, 0x0382                ; 1aca: 50 05 82 03
  !16 c_store ; C!               ; 1ace: 64 07
.DISKRS_1:
  !16 lit, 0x0382                ; 1ad0: 50 05 82 03
  !16 c_load ; C@                ; 1ad4: 7f 07
  !16 lit, 0x0004                ; 1ad6: 50 05 04 00
  !16 eq ; =                     ; 1ada: e5 09
  !16 branch_if, .DISKRS_0       ; 1adc: 7d 05 e6 1a
  !16 TICK                       ; 1ae0: a5 0d
  !16 branch, .DISKRS_1          ; 1ae2: 6b 05 d0 1a
.DISKRS_0:
  !16 lit, 0x0300                ; 1ae6: 50 05 00 03
  !16 SWAP                       ; 1aea: 8d 06
  !16 lit, 0x0080                ; 1aec: 50 05 80 00
  !16 MOVE                       ; 1af0: 39 0a
  !16 EXIT                       ; 1af2: 5c 05

!text 0, "SAVE\"", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
save_str:
  ent                            ; 1afe: 22
  !16 diskname_str ; DISKNAME"   ; 1aff: eb 19
  !16 lit, start                 ; 1b01: 50 05 00 05
  !16 HERE                       ; 1b05: e0 10
  !16 lit, 0x0481                ; 1b07: 50 05 81 04
  !16 _sub ; -                   ; 1b0b: 9c 07
  !16 lit, 0x0007                ; 1b0d: 50 05 07 00
  !16 shr ; U>>                  ; 1b11: 60 08
  !16 lit, 0x0000                ; 1b13: 50 05 00 00
  !16 do, .save_str_0            ; 1b17: 8d 05 2d 1b
.save_str_1:
  !16 DUP                        ; 1b1b: 49 06
  !16 I                          ; 1b1d: 1d 06
  !16 DISKWS                     ; 1b1f: 75 1a
  !16 lit, 0x0080                ; 1b21: 50 05 80 00
  !16 _add ; +                   ; 1b25: 8f 07
  !16 loop, .save_str_1          ; 1b27: bf 05 1b 1b
  !16 UNLOOP                     ; 1b2b: 14 06
.save_str_0:
  !16 EXIT                       ; 1b2d: 5c 05

!text 0, "(blkbuf)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkbuf:
  ent                            ; 1b3c: 22
  !16 DOVAR, 0x0000              ; 1b3d: 34 05 00 00

!text 0, "(blkno)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkno:
  ent                            ; 1b4d: 22
  !16 DOVAR, 0x0000              ; 1b4e: 34 05 00 00

!text 0, "(blkup)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkup:
  ent                            ; 1b5e: 22
  !16 DOVAR, 0x0000              ; 1b5f: 34 05 00 00

!text 0, "(blkload)", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
blkload:
  ent                            ; 1b71: 22
  !16 DOVAR, 0x0000              ; 1b72: 34 05 00 00

!text 0, "FLUSH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
FLUSH:
  ent                            ; 1b80: 22
  !16 blkbuf ; (blkbuf)          ; 1b81: 3c 1b
  !16 load ; @                   ; 1b83: 73 07
  !16 blkno ; (blkno)            ; 1b85: 4d 1b
  !16 load ; @                   ; 1b87: 73 07
  !16 sub1 ; 1-                  ; 1b89: dc 08
  !16 lit, 0x0003                ; 1b8b: 50 05 03 00
  !16 shl ; <<                   ; 1b8f: 70 08
  !16 lit, 0x0008                ; 1b91: 50 05 08 00
  !16 lit, 0x0000                ; 1b95: 50 05 00 00
  !16 do, .FLUSH_0               ; 1b99: 8d 05 b3 1b
.FLUSH_1:
  !16 _2dup ; 2DUP               ; 1b9d: 65 06
  !16 DISKWS                     ; 1b9f: 75 1a
  !16 SWAP                       ; 1ba1: 8d 06
  !16 lit, 0x0080                ; 1ba3: 50 05 80 00
  !16 _add ; +                   ; 1ba7: 8f 07
  !16 SWAP                       ; 1ba9: 8d 06
  !16 add1 ; 1+                  ; 1bab: d1 08
  !16 loop, .FLUSH_1             ; 1bad: bf 05 9d 1b
  !16 UNLOOP                     ; 1bb1: 14 06
.FLUSH_0:
  !16 _2drop ; 2DROP             ; 1bb3: 81 06
  !16 lit, 0x0000                ; 1bb5: 50 05 00 00
  !16 blkup ; (blkup)            ; 1bb9: 5e 1b
  !16 store ; !                  ; 1bbb: 38 07
  !16 EXIT                       ; 1bbd: 5c 05

!text 0, "REVERT", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
REVERT:
  ent                            ; 1bca: 22
  !16 lit, 0x0000                ; 1bcb: 50 05 00 00
  !16 blkup ; (blkup)            ; 1bcf: 5e 1b
  !16 store ; !                  ; 1bd1: 38 07
  !16 blkbuf ; (blkbuf)          ; 1bd3: 3c 1b
  !16 load ; @                   ; 1bd5: 73 07
  !16 blkno ; (blkno)            ; 1bd7: 4d 1b
  !16 load ; @                   ; 1bd9: 73 07
  !16 sub1 ; 1-                  ; 1bdb: dc 08
  !16 lit, 0x0003                ; 1bdd: 50 05 03 00
  !16 shl ; <<                   ; 1be1: 70 08
  !16 lit, 0x0008                ; 1be3: 50 05 08 00
  !16 lit, 0x0000                ; 1be7: 50 05 00 00
  !16 do, .REVERT_0              ; 1beb: 8d 05 05 1c
.REVERT_1:
  !16 _2dup ; 2DUP               ; 1bef: 65 06
  !16 DISKRS                     ; 1bf1: b9 1a
  !16 SWAP                       ; 1bf3: 8d 06
  !16 lit, 0x0080                ; 1bf5: 50 05 80 00
  !16 _add ; +                   ; 1bf9: 8f 07
  !16 SWAP                       ; 1bfb: 8d 06
  !16 add1 ; 1+                  ; 1bfd: d1 08
  !16 loop, .REVERT_1            ; 1bff: bf 05 ef 1b
  !16 UNLOOP                     ; 1c03: 14 06
.REVERT_0:
  !16 _2drop ; 2DROP             ; 1c05: 81 06
  !16 EXIT                       ; 1c07: 5c 05

!text 0, "BLOCK", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
BLOCK:
  ent                            ; 1c13: 22
  !16 blkbuf ; (blkbuf)          ; 1c14: 3c 1b
  !16 load ; @                   ; 1c16: 73 07
  !16 eq0 ; 0=                   ; 1c18: 13 09
  !16 branch_if, .BLOCK_0        ; 1c1a: 7d 05 28 1c
  !16 lit, 0x0400                ; 1c1e: 50 05 00 04
  !16 ALLOT                      ; 1c22: 6a 11
  !16 blkbuf ; (blkbuf)          ; 1c24: 3c 1b
  !16 store ; !                  ; 1c26: 38 07
.BLOCK_0:
  !16 DUP                        ; 1c28: 49 06
  !16 blkno ; (blkno)            ; 1c2a: 4d 1b
  !16 load ; @                   ; 1c2c: 73 07
  !16 eq ; =                     ; 1c2e: e5 09
  !16 branch_if, .BLOCK_1        ; 1c30: 7d 05 3c 1c
  !16 DROP                       ; 1c34: 75 06
  !16 blkbuf ; (blkbuf)          ; 1c36: 3c 1b
  !16 load ; @                   ; 1c38: 73 07
  !16 EXIT                       ; 1c3a: 5c 05
.BLOCK_1:
  !16 blkno ; (blkno)            ; 1c3c: 4d 1b
  !16 load ; @                   ; 1c3e: 73 07
  !16 neq0 ; 0<>                 ; 1c40: 26 09
  !16 branch_if, .BLOCK_2        ; 1c42: 7d 05 48 1c
  !16 FLUSH                      ; 1c46: 80 1b
.BLOCK_2:
  !16 blkno ; (blkno)            ; 1c48: 4d 1b
  !16 store ; !                  ; 1c4a: 38 07
  !16 REVERT                     ; 1c4c: ca 1b
  !16 blkbuf ; (blkbuf)          ; 1c4e: 3c 1b
  !16 load ; @                   ; 1c50: 73 07
  !16 EXIT                       ; 1c52: 5c 05

!text 0, "UPDATE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
UPDATE:
  ent                            ; 1c5f: 22
  !16 lit, 0x0001                ; 1c60: 50 05 01 00
  !16 blkup ; (blkup)            ; 1c64: 5e 1b
  !16 store ; !                  ; 1c66: 38 07
  !16 EXIT                       ; 1c68: 5c 05

!text 0, "LIST", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
LIST:
  ent                            ; 1c73: 22
  !16 BLOCK                      ; 1c74: 13 1c
  !16 CR                         ; 1c76: c7 0e
  !16 lit, 0x000a                ; 1c78: 50 05 0a 00
  !16 RADIX                      ; 1c7c: 2b 0b
  !16 store ; !                  ; 1c7e: 38 07
  !16 lit, 0x0010                ; 1c80: 50 05 10 00
  !16 lit, 0x0000                ; 1c84: 50 05 00 00
  !16 do, .LIST_0                ; 1c88: 8d 05 c0 1c
.LIST_4:
  !16 I                          ; 1c8c: 1d 06
  !16 lit, 0x000a                ; 1c8e: 50 05 0a 00
  !16 lt ; <                     ; 1c92: 5d 09
  !16 branch_if, .LIST_1         ; 1c94: 7d 05 9a 1c
  !16 SPACE                      ; 1c98: 07 10
.LIST_1:
  !16 I                          ; 1c9a: 1d 06
  !16 print_int ; .              ; 1c9c: 34 10
  !16 lit, 0x0040                ; 1c9e: 50 05 40 00
  !16 lit, 0x0000                ; 1ca2: 50 05 00 00
  !16 do, .LIST_2                ; 1ca6: 8d 05 b8 1c
.LIST_3:
  !16 DUP                        ; 1caa: 49 06
  !16 c_load ; C@                ; 1cac: 7f 07
  !16 EMIT                       ; 1cae: 07 0f
  !16 add1 ; 1+                  ; 1cb0: d1 08
  !16 loop, .LIST_3              ; 1cb2: bf 05 aa 1c
  !16 UNLOOP                     ; 1cb6: 14 06
.LIST_2:
  !16 CR                         ; 1cb8: c7 0e
  !16 loop, .LIST_4              ; 1cba: bf 05 8c 1c
  !16 UNLOOP                     ; 1cbe: 14 06
.LIST_0:
  !16 DROP                       ; 1cc0: 75 06
  !16 EXIT                       ; 1cc2: 5c 05

!text 0, "WIPE", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
WIPE:
  ent                            ; 1ccd: 22
  !16 UPDATE                     ; 1cce: 5f 1c
  !16 blkbuf ; (blkbuf)          ; 1cd0: 3c 1b
  !16 load ; @                   ; 1cd2: 73 07
  !16 lit, 0x0400                ; 1cd4: 50 05 00 04
  !16 lit, 0x0020                ; 1cd8: 50 05 20 00
  !16 FILL                       ; 1cdc: 58 0a
  !16 EXIT                       ; 1cde: 5c 05

!text 0, "PP", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
PP:
  ent                            ; 1ce7: 22
  !16 UPDATE                     ; 1ce8: 5f 1c
  !16 lit, 0x0006                ; 1cea: 50 05 06 00
  !16 shl ; <<                   ; 1cee: 70 08
  !16 blkbuf ; (blkbuf)          ; 1cf0: 3c 1b
  !16 load ; @                   ; 1cf2: 73 07
  !16 _add ; +                   ; 1cf4: 8f 07
  !16 DUP                        ; 1cf6: 49 06
  !16 lit, 0x0040                ; 1cf8: 50 05 40 00
  !16 lit, 0x0020                ; 1cfc: 50 05 20 00
  !16 FILL                       ; 1d00: 58 0a
  !16 lit, 0x000d                ; 1d02: 50 05 0d 00
  !16 TIBSPLIT                   ; 1d06: 08 12
  !16 TUCK                       ; 1d08: 18 07
  !16 STRLEN                     ; 1d0a: a9 0a
  !16 lit, 0x0040                ; 1d0c: 50 05 40 00
  !16 MIN                        ; 1d10: 28 0a
  !16 MOVE                       ; 1d12: 39 0a
  !16 EXIT                       ; 1d14: 5c 05

!text 0, "LOAD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
LOAD:
  ent                            ; 1d1f: 22
  !16 BLOCK                      ; 1d20: 13 1c
  !16 blkload ; (blkload)        ; 1d22: 71 1b
  !16 store ; !                  ; 1d24: 38 07
  !16 lit, 0x0000                ; 1d26: 50 05 00 00
  !16 TIB                        ; 1d2a: 1c 0b
  !16 lit, 0x0040                ; 1d2c: 50 05 40 00
  !16 _add ; +                   ; 1d30: 8f 07
  !16 c_store ; C!               ; 1d32: 64 07
  !16 lit, 0x0010                ; 1d34: 50 05 10 00
  !16 lit, 0x0000                ; 1d38: 50 05 00 00
  !16 do, .LOAD_0                ; 1d3c: 8d 05 64 1d
.LOAD_1:
  !16 blkload ; (blkload)        ; 1d40: 71 1b
  !16 load ; @                   ; 1d42: 73 07
  !16 TIB                        ; 1d44: 1c 0b
  !16 lit, 0x0040                ; 1d46: 50 05 40 00
  !16 MOVE                       ; 1d4a: 39 0a
  !16 TIB                        ; 1d4c: 1c 0b
  !16 TIBPTR                     ; 1d4e: b3 10
  !16 store ; !                  ; 1d50: 38 07
  !16 TIB                        ; 1d52: 1c 0b
  !16 INTERPRET                  ; 1d54: 8d 17
  !16 lit, 0x0040                ; 1d56: 50 05 40 00
  !16 blkload ; (blkload)        ; 1d5a: 71 1b
  !16 inc_word ; +!              ; 1d5c: 44 07
  !16 loop, .LOAD_1              ; 1d5e: bf 05 40 1d
  !16 UNLOOP                     ; 1d62: 14 06
.LOAD_0:
  !16 EXIT                       ; 1d64: 5c 05

!text 0, "SORTADDR", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTADDR:
  ent                            ; 1d73: 22
  !16 DOVAR, 0x0004              ; 1d74: 34 05 04 00

!text 0, "SORTCMD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTCMD:
  ent                            ; 1d84: 22
  !16 SORTADDR                   ; 1d85: 73 1d
  !16 load ; @                   ; 1d87: 73 07
  !16 rbp_store ; RBP!           ; 1d89: b0 0d
  !16 DUP                        ; 1d8b: 49 06
  !16 lit, 0x0300                ; 1d8d: 50 05 00 03
  !16 c_store ; C!               ; 1d91: 64 07
.SORTCMD_1:
  !16 DUP                        ; 1d93: 49 06
  !16 lit, 0x0300                ; 1d95: 50 05 00 03
  !16 c_load ; C@                ; 1d99: 7f 07
  !16 eq ; =                     ; 1d9b: e5 09
  !16 branch_if, .SORTCMD_0      ; 1d9d: 7d 05 a7 1d
  !16 TICK                       ; 1da1: a5 0d
  !16 branch, .SORTCMD_1         ; 1da3: 6b 05 93 1d
.SORTCMD_0:
  !16 DROP                       ; 1da7: 75 06
  !16 lit, 0x0300                ; 1da9: 50 05 00 03
  !16 c_load ; C@                ; 1dad: 7f 07
  !16 lit, 0x00ff                ; 1daf: 50 05 ff 00
  !16 eq ; =                     ; 1db3: e5 09
  !16 branch_if, .SORTCMD_2      ; 1db5: 7d 05 cc 1d
  !16 print_str_lit ; (.")       ; 1db9: e2 0f
  !text "Sorter Error", 0
  !16 CR                         ; 1dc8: c7 0e
  !16 ABORT                      ; 1dca: a1 10
.SORTCMD_2:
  !16 EXIT                       ; 1dcc: 5c 05

!text 0, "SORTSLOTS", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTSLOTS:
  ent                            ; 1ddc: 22
  !16 lit, 0x0001                ; 1ddd: 50 05 01 00
  !16 SORTCMD                    ; 1de1: 84 1d
  !16 lit, 0x0302                ; 1de3: 50 05 02 03
  !16 load ; @                   ; 1de7: 73 07
  !16 EXIT                       ; 1de9: 5c 05

!text 0, "SORTSLOT@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortslot_read:
  ent                            ; 1df9: 22
  !16 SORTADDR                   ; 1dfa: 73 1d
  !16 load ; @                   ; 1dfc: 73 07
  !16 rbp_store ; RBP!           ; 1dfe: b0 0d
  !16 lit, 0x0302                ; 1e00: 50 05 02 03
  !16 store ; !                  ; 1e04: 38 07
  !16 lit, 0x0002                ; 1e06: 50 05 02 00
  !16 SORTCMD                    ; 1e0a: 84 1d
  !16 lit, 0x0306                ; 1e0c: 50 05 06 03
  !16 load ; @                   ; 1e10: 73 07
  !16 lit, 0x0304                ; 1e12: 50 05 04 03
  !16 load ; @                   ; 1e16: 73 07
  !16 lit, 0x0301                ; 1e18: 50 05 01 03
  !16 c_load ; C@                ; 1e1c: 7f 07
  !16 EXIT                       ; 1e1e: 5c 05

!text 0, "SORTPULL", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTPULL:
  ent                            ; 1e2d: 22
  !16 SORTADDR                   ; 1e2e: 73 1d
  !16 load ; @                   ; 1e30: 73 07
  !16 rbp_store ; RBP!           ; 1e32: b0 0d
  !16 lit, 0x0302                ; 1e34: 50 05 02 03
  !16 store ; !                  ; 1e38: 38 07
  !16 lit, 0x0301                ; 1e3a: 50 05 01 03
  !16 c_store ; C!               ; 1e3e: 64 07
  !16 lit, 0x0003                ; 1e40: 50 05 03 00
  !16 SORTCMD                    ; 1e44: 84 1d
  !16 lit, 0x0301                ; 1e46: 50 05 01 03
  !16 c_load ; C@                ; 1e4a: 7f 07
  !16 EXIT                       ; 1e4c: 5c 05

!text 0, "SORTCOLOR@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortcolor_read:
  ent                            ; 1e5d: 22
  !16 SORTADDR                   ; 1e5e: 73 1d
  !16 load ; @                   ; 1e60: 73 07
  !16 rbp_store ; RBP!           ; 1e62: b0 0d
  !16 lit, 0x030c                ; 1e64: 50 05 0c 03
  !16 c_load ; C@                ; 1e68: 7f 07
  !16 EXIT                       ; 1e6a: 5c 05

!text 0, "SORTCOLOR!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortcolor_write:
  ent                            ; 1e7b: 22
  !16 SORTADDR                   ; 1e7c: 73 1d
  !16 load ; @                   ; 1e7e: 73 07
  !16 rbp_store ; RBP!           ; 1e80: b0 0d
  !16 lit, 0x030c                ; 1e82: 50 05 0c 03
  !16 c_store ; C!               ; 1e86: 64 07
  !16 EXIT                       ; 1e88: 5c 05

!text 0, "SORTPAT@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortpat_read:
  ent                            ; 1e97: 22
  !16 SORTADDR                   ; 1e98: 73 1d
  !16 load ; @                   ; 1e9a: 73 07
  !16 rbp_store ; RBP!           ; 1e9c: b0 0d
  !16 lit, 0x0306                ; 1e9e: 50 05 06 03
  !16 load ; @                   ; 1ea2: 73 07
  !16 lit, 0x0304                ; 1ea4: 50 05 04 03
  !16 load ; @                   ; 1ea8: 73 07
  !16 EXIT                       ; 1eaa: 5c 05

!text 0, "SORTPAT!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortpat_write:
  ent                            ; 1eb9: 22
  !16 SORTADDR                   ; 1eba: 73 1d
  !16 load ; @                   ; 1ebc: 73 07
  !16 rbp_store ; RBP!           ; 1ebe: b0 0d
  !16 lit, 0x0304                ; 1ec0: 50 05 04 03
  !16 store ; !                  ; 1ec4: 38 07
  !16 lit, 0x0306                ; 1ec6: 50 05 06 03
  !16 store ; !                  ; 1eca: 38 07
  !16 EXIT                       ; 1ecc: 5c 05

!text 0, "SORTINCOL@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortincol_read:
  ent                            ; 1edd: 22
  !16 SORTADDR                   ; 1ede: 73 1d
  !16 load ; @                   ; 1ee0: 73 07
  !16 rbp_store ; RBP!           ; 1ee2: b0 0d
  !16 lit, 0x030d                ; 1ee4: 50 05 0d 03
  !16 c_load ; C@                ; 1ee8: 7f 07
  !16 EXIT                       ; 1eea: 5c 05

!text 0, "SORTINCOL!", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortincol_write:
  ent                            ; 1efb: 22
  !16 SORTADDR                   ; 1efc: 73 1d
  !16 load ; @                   ; 1efe: 73 07
  !16 rbp_store ; RBP!           ; 1f00: b0 0d
  !16 lit, 0x030d                ; 1f02: 50 05 0d 03
  !16 c_store ; C!               ; 1f06: 64 07
  !16 EXIT                       ; 1f08: 5c 05

!text 0, "SORTDMG@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortdmg_read:
  ent                            ; 1f17: 22
  !16 SORTADDR                   ; 1f18: 73 1d
  !16 load ; @                   ; 1f1a: 73 07
  !16 rbp_store ; RBP!           ; 1f1c: b0 0d
  !16 lit, 0x0308                ; 1f1e: 50 05 08 03
  !16 load ; @                   ; 1f22: 73 07
  !16 EXIT                       ; 1f24: 5c 05

!text 0, "SORTDMGMAX@", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
sortdmgmax_read:
  ent                            ; 1f36: 22
  !16 SORTADDR                   ; 1f37: 73 1d
  !16 load ; @                   ; 1f39: 73 07
  !16 rbp_store ; RBP!           ; 1f3b: b0 0d
  !16 lit, 0x030a                ; 1f3d: 50 05 0a 03
  !16 load ; @                   ; 1f41: 73 07
  !16 EXIT                       ; 1f43: 5c 05

!text 0, "SORTMATCH", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
SORTMATCH:
  ent                            ; 1f53: 22
  !16 SORTADDR                   ; 1f54: 73 1d
  !16 load ; @                   ; 1f56: 73 07
  !16 rbp_store ; RBP!           ; 1f58: b0 0d
  !16 lit, 0x0301                ; 1f5a: 50 05 01 03
  !16 c_store ; C!               ; 1f5e: 64 07
  !16 lit, 0x0004                ; 1f60: 50 05 04 00
  !16 SORTCMD                    ; 1f64: 84 1d
  !16 EXIT                       ; 1f66: 5c 05

!text 0, "COLD", 0 ; name
!8 .FLAG_NONE
!16 prev
!set prev = *
COLD:
  ent                            ; 1f71: 22
  !16 lit, 0x0000                ; 1f72: 50 05 00 00
  !16 c_load ; C@                ; 1f76: 7f 07
  !16 DISKADDR                   ; 1f78: d8 19
  !16 store ; !                  ; 1f7a: 38 07
  !16 lit, 0x0001                ; 1f7c: 50 05 01 00
  !16 c_load ; C@                ; 1f80: 7f 07
  !16 TERMADDR                   ; 1f82: c1 0d
  !16 store ; !                  ; 1f84: 38 07
  !16 CR                         ; 1f86: c7 0e
  !16 CR                         ; 1f88: c7 0e
  !16 print_str_lit ; (.")       ; 1f8a: e2 0f
  !text "MineOS XP V1.2 Initialized", 0
  !16 CR                         ; 1fa7: c7 0e
  !16 PROBE                      ; 1fa9: 0d 11
  !16 TOP                        ; 1fab: ef 10
  !16 store ; !                  ; 1fad: 38 07
  !16 FREE                       ; 1faf: 55 11
  !16 print_uint ; U.            ; 1fb1: 5e 10
  !16 print_str_lit ; (.")       ; 1fb3: e2 0f
  !text "bytes free.", 0
  !16 CR                         ; 1fc1: c7 0e
  !16 QUIT                       ; 1fc3: 29 18

end:
  !align 128, 0, 0
