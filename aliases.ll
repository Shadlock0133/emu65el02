(lit) lit
(branch) branch
(?branch) branch_if
(do) do
(?do) _do_if
(loop) loop
(+loop) _loop_add
(leave) leave
?DUP dup_if
2DUP _2dup
2DROP _2drop
2OVER _2over
2SWAP _2swap
-ROT rot_rev
>R push_r
R> pull_r
! store
+! inc_word
-! dec_word
C! c_store
@ load
C@ c_load
+ _add
- _sub
M* m_mul
UM* um_mul
* _mul
U* umul
SM/REM sm_div_rem
FM/MOD fm_div_mod
UM/MOD um_div_mod
2* mul2
2/ div2
U>> shr
<< shl
AND _and
1+ add1
1- sub1
SP@ sp_load
SP! sp_store
RP@ rp_load
RP! rp_store
0= eq0
0<> neq0
0< lt0
<> neq
< lt
> gt
U< ult
U> ugt
<= le
>= ge
= eq
RBP! rbp_store // redbus pointer
KEY? is_key
AT-XY at_xy
(.") print_str_lit
. print_int
U. print_uint
/MOD div_mod
/ _div
(HERE) here_var
, allot_push
,C allot_push_char
,S allot_push_str
[ comp_enter
] comp_exit
(does) _does
DOES> does_right
: compile
; compile_end
." print_str
?DO do_if
+LOOP loop_add
\ line_comment
( paren_comment
(") str_lit
" str
>NAME to_name
NAME> from_name
0SP _0sp
.S print_stack
' find_name
IOX@ iox_read
IOX! iox_write
DISKNAME" diskname_str
SAVE" save_str
(blkbuf) blkbuf
(blkno) blkno
(blkup) blkup
(blkload) blkload
SORTSLOT@ sortslot_read
SORTCOLOR@ sortcolor_read
SORTCOLOR! sortcolor_write
SORTPAT@ sortpat_read
SORTPAT! sortpat_write
SORTINCOL@ sortincol_read
SORTINCOL! sortincol_write
SORTDMG@ sortdmg_read
SORTDMGMAX@ sortdmgmax_read