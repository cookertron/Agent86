; stress.asm — Comprehensive assembler + expression evaluator stress test
; Tests ~60 checks across 12 sections. Prints '.' per pass, '!' per fail.
; Usage: agent86 stress.asm && agent86 stress.com --run

ORG 100h
    JMP main

; ============================================================
; Variables
; ============================================================
pass_count: DW 0
fail_count: DW 0
byte_var:   DB 0
word_var:   DW 0
byte_var2:  DB 0
word_var2:  DW 0

; ============================================================
; EQU constants (chains, bitwise, char, label math)
; ============================================================
E_A     EQU  10
E_B     EQU  20
E_C     EQU  E_A + E_B               ; 30
E_D     EQU  E_C * 2                 ; 60
E_MASK  EQU  0FFh & 0F0h             ; F0h
E_SHIFT EQU  1 << 4                  ; 16
E_CHAR  EQU  'Z'                     ; 90

; ============================================================
; DB / DW test data
; ============================================================
db_data:
    DB 10, 20, 30
    DB (5 + 3), 0FFh & 0Fh           ; 8, 15
    DB 'A' | 80h                      ; 0C1h = 193
db_end:
DB_LEN  EQU  db_end - db_data        ; 6

dw_data:
    DW 1234h, 5678h
    DW (100 + 200)                    ; 300 = 012Ch
    DW -1                            ; FFFFh
dw_end:
DW_CNT  EQU  (dw_end - dw_data) / 2  ; 4

; ============================================================
; Subroutines  (also tests CALL near direct + RET — first time!)
; ============================================================

; check16: AX=actual, DX=expected. Prints '.' or '!'
check16 PROC
    CMP AX, DX
    JNE .fail
    INC WORD [pass_count]
    MOV DL, '.'
    JMP .print
.fail:
    INC WORD [fail_count]
    MOV DL, '!'
.print:
    MOV AH, 02h
    INT 21h
    RET
check16 ENDP

; print '$'-terminated string at DS:DX
print_str PROC
    MOV AH, 09h
    INT 21h
    RET
print_str ENDP

; print hex nibble (low 4 bits of AL)
print_nib PROC
    AND AL, 0Fh
    ADD AL, 30h
    CMP AL, 39h
    JBE .ok
    ADD AL, 7
.ok:
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET
print_nib ENDP

; print hex byte in AL
print_byte PROC
    PUSH AX
    SHR AL, 1
    SHR AL, 1
    SHR AL, 1
    SHR AL, 1
    CALL print_nib
    POP AX
    CALL print_nib
    RET
print_byte ENDP

; print hex word in AX
print_word PROC
    PUSH AX
    MOV AL, AH
    CALL print_byte
    POP AX
    CALL print_byte
    RET
print_word ENDP

; --- Local label scoping test functions ---
; Both use .done — must resolve to DIFFERENT addresses
func_add PROC
    MOV AX, 10
    MOV BX, 5
    CMP BX, 0
    JE .done
    ADD AX, BX
.done:
    RET
func_add ENDP

func_sub PROC
    MOV AX, 10
    MOV BX, 5
    CMP BX, 0
    JE .done
    SUB AX, BX
.done:
    RET
func_sub ENDP

; ============================================================
; MAIN
; ============================================================
main:

; ==================== SECTION 1: Expressions ==================
    MOV DX, s1_msg
    CALL print_str

    ; 1.01  nested parens
    MOV AX, ((1 + 2) * (3 + 4))
    MOV DX, 21
    CALL check16

    ; 1.02  unary minus on paren
    MOV AX, -(5 + 3)
    MOV DX, 0FFF8h
    CALL check16

    ; 1.03  double negation
    MOV AX, --5
    MOV DX, 5
    CALL check16

    ; 1.04  double bitwise NOT
    MOV AX, ~~0F0h
    MOV DX, 0F0h
    CALL check16

    ; 1.05  precedence: & before |
    MOV AX, 2 | 4 & 6
    MOV DX, 6                       ; 4&6=4, 2|4=6
    CALL check16

    ; 1.06  precedence: ^ between & and |
    MOV AX, 0Fh | 0F0h ^ 0FFh
    MOV DX, 0Fh | (0F0h ^ 0FFh)    ; F0^FF=0F, F|0F=0Fh
    CALL check16

    ; 1.07  shift left max
    MOV AX, 1 << 15
    MOV DX, 8000h
    CALL check16

    ; 1.08  shift right
    MOV AX, 0FFFFh >> 8
    MOV DX, 00FFh
    CALL check16

    ; 1.09  XOR self = 0
    MOV AX, 0ABCDh ^ 0ABCDh
    MOV DX, 0
    CALL check16

    ; 1.10  AND mask
    MOV AX, 1234h & 0F00h
    MOV DX, 0200h
    CALL check16

    ; 1.11  modulo
    MOV AX, 100 % 7
    MOV DX, 2
    CALL check16

    ; 1.12  NOT zero masked 16-bit
    MOV AX, ~0 & 0FFFFh
    MOV DX, 0FFFFh
    CALL check16

    ; 1.13  shift with paren amount
    MOV AX, 3 << (1 + 1)
    MOV DX, 12
    CALL check16

    ; 1.14  combined: (1<<8) | (FFh & AAh) ^ 0Fh
    ; Precedence: & first → AAh; ^ next → AA^0F=A5; | last → 100|A5=1A5
    MOV AX, (1 << 8) | (0FFh & 0AAh) ^ 0Fh
    MOV DX, 01A5h
    CALL check16

; ==================== SECTION 2: EQU Chains ===================
    MOV DX, s2_msg
    CALL print_str

    ; 2.01
    MOV AX, E_A
    MOV DX, 10
    CALL check16

    ; 2.02  EQU + EQU
    MOV AX, E_C
    MOV DX, 30
    CALL check16

    ; 2.03  EQU * EQU
    MOV AX, E_D
    MOV DX, 60
    CALL check16

    ; 2.04  EQU with &
    MOV AX, E_MASK
    MOV DX, 0F0h
    CALL check16

    ; 2.05  EQU with <<
    MOV AX, E_SHIFT
    MOV DX, 16
    CALL check16

    ; 2.06  EQU with char literal
    MOV AX, E_CHAR
    MOV DX, 90
    CALL check16

    ; 2.07  EQU from label subtraction
    MOV AX, DB_LEN
    MOV DX, 6
    CALL check16

    ; 2.08  EQU with /
    MOV AX, DW_CNT
    MOV DX, 4
    CALL check16

; ==================== SECTION 3: DB/DW Data ====================
    MOV DX, s3_msg
    CALL print_str

    ; 3.01  DB first byte
    MOV AL, BYTE [db_data]
    XOR AH, AH
    MOV DX, 10
    CALL check16

    ; 3.02  DB second byte
    MOV AL, BYTE [db_data + 1]
    XOR AH, AH
    MOV DX, 20
    CALL check16

    ; 3.03  DB expression (5+3)
    MOV AL, BYTE [db_data + 3]
    XOR AH, AH
    MOV DX, 8
    CALL check16

    ; 3.04  DB bitwise AND expr (FFh & Fh)
    MOV AL, BYTE [db_data + 4]
    XOR AH, AH
    MOV DX, 15
    CALL check16

    ; 3.05  DB char OR expr ('A' | 80h)
    MOV AL, BYTE [db_data + 5]
    XOR AH, AH
    MOV DX, 0C1h
    CALL check16

    ; 3.06  DW first word
    MOV AX, WORD [dw_data]
    MOV DX, 1234h
    CALL check16

    ; 3.07  DW expression (100+200)
    MOV AX, WORD [dw_data + 4]
    MOV DX, 300
    CALL check16

    ; 3.08  DW -1
    MOV AX, WORD [dw_data + 6]
    MOV DX, 0FFFFh
    CALL check16

; ================ SECTION 4: NOT/NEG on Memory ================
    MOV DX, s4_msg
    CALL print_str

    ; 4.01  NOT BYTE [mem]
    MOV BYTE [byte_var], 0F0h
    NOT BYTE [byte_var]
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 0Fh
    CALL check16

    ; 4.02  NOT WORD [mem]
    MOV WORD [word_var], 0FF00h
    NOT WORD [word_var]
    MOV AX, WORD [word_var]
    MOV DX, 00FFh
    CALL check16

    ; 4.03  NEG BYTE [mem]
    MOV BYTE [byte_var], 5
    NEG BYTE [byte_var]
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 0FBh
    CALL check16

    ; 4.04  NEG WORD [mem]
    MOV WORD [word_var], 100
    NEG WORD [word_var]
    MOV AX, WORD [word_var]
    MOV DX, 0FF9Ch
    CALL check16

; ============= SECTION 5: Shifts/Rotates on Memory ============
    MOV DX, s5_msg
    CALL print_str

    ; 5.01  SHL BYTE [mem], 1
    MOV BYTE [byte_var], 01h
    SHL BYTE [byte_var], 1
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 02h
    CALL check16

    ; 5.02  SHR WORD [mem], 1
    MOV WORD [word_var], 0100h
    SHR WORD [word_var], 1
    MOV AX, WORD [word_var]
    MOV DX, 0080h
    CALL check16

    ; 5.03  SHL BYTE [mem], CL
    MOV BYTE [byte_var], 01h
    MOV CL, 4
    SHL BYTE [byte_var], CL
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 10h
    CALL check16

    ; 5.04  SHR WORD [mem], CL
    MOV WORD [word_var], 0FF00h
    MOV CL, 4
    SHR WORD [word_var], CL
    MOV AX, WORD [word_var]
    MOV DX, 0FF0h
    CALL check16

    ; 5.05  ROL BYTE [mem], 1  (bit 7 wraps to bit 0)
    MOV BYTE [byte_var], 80h
    ROL BYTE [byte_var], 1
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 01h
    CALL check16

    ; 5.06  ROR WORD [mem], CL (bit 0 wraps to bit 15)
    MOV WORD [word_var], 0001h
    MOV CL, 1
    ROR WORD [word_var], CL
    MOV AX, WORD [word_var]
    MOV DX, 8000h
    CALL check16

; ================ SECTION 6: ALU on Memory ====================
    MOV DX, s6_msg
    CALL print_str

    ; 6.01  ADD [mem], reg
    MOV WORD [word_var], 100
    MOV AX, 50
    ADD WORD [word_var], AX
    MOV AX, WORD [word_var]
    MOV DX, 150
    CALL check16

    ; 6.02  SUB reg, [mem]
    MOV WORD [word_var], 30
    MOV AX, 100
    SUB AX, WORD [word_var]
    MOV DX, 70
    CALL check16

    ; 6.03  AND BYTE [mem], imm
    MOV BYTE [byte_var], 0FFh
    AND BYTE [byte_var], 0Fh
    MOV AL, BYTE [byte_var]
    XOR AH, AH
    MOV DX, 0Fh
    CALL check16

    ; 6.04  OR WORD [mem], imm
    MOV WORD [word_var], 0F00h
    OR WORD [word_var], 0Fh
    MOV AX, WORD [word_var]
    MOV DX, 0F0Fh
    CALL check16

    ; 6.05  XOR reg, [mem]
    MOV WORD [word_var], 0FFFFh
    MOV AX, 0FF00h
    XOR AX, WORD [word_var]
    MOV DX, 00FFh
    CALL check16

    ; 6.06  ADD WORD [mem], small imm (sign-extended 83h path)
    MOV WORD [word_var], 100
    ADD WORD [word_var], 5
    MOV AX, WORD [word_var]
    MOV DX, 105
    CALL check16

; ====================== SECTION 7: LEA ========================
    MOV DX, s7_msg
    CALL print_str

    ; 7.01  LEA direct address
    LEA AX, [word_var]
    MOV DX, word_var
    CALL check16

    ; 7.02  LEA BX + disp
    MOV BX, 10
    LEA AX, [BX + 5]
    MOV DX, 15
    CALL check16

    ; 7.03  LEA BX + SI
    MOV BX, 100
    MOV SI, 50
    LEA AX, [BX + SI]
    MOV DX, 150
    CALL check16

    ; 7.04  LEA BX + SI + disp
    MOV BX, 100
    MOV SI, 50
    LEA AX, [BX + SI + 10]
    MOV DX, 160
    CALL check16

; ================ SECTION 8: INC/DEC short forms ==============
    MOV DX, s8_msg
    CALL print_str

    ; 8.01-8.06  INC all non-SP regs, check via AX
    MOV AX, 0
    INC AX
    MOV DX, 1
    CALL check16

    MOV CX, 0
    INC CX
    MOV AX, CX
    MOV DX, 1
    CALL check16

    MOV BX, 0
    INC BX
    MOV AX, BX
    MOV DX, 1
    CALL check16

    MOV BP, 0
    INC BP
    MOV AX, BP
    MOV DX, 1
    CALL check16

    MOV SI, 0
    INC SI
    MOV AX, SI
    MOV DX, 1
    CALL check16

    MOV DI, 0
    INC DI
    MOV AX, DI
    MOV DX, 1
    CALL check16

    ; 8.07  DEC
    MOV AX, 10
    DEC AX
    MOV DX, 9
    CALL check16

    ; 8.08  DEC CX
    MOV CX, 10
    DEC CX
    MOV AX, CX
    MOV DX, 9
    CALL check16

; ============= SECTION 9: PUSH/POP mem, XCHG ================
    MOV DX, s9_msg
    CALL print_str

    ; 9.01  PUSH WORD [mem] → POP AX
    MOV WORD [word_var], 0BEEFh
    PUSH WORD [word_var]
    POP AX
    MOV DX, 0BEEFh
    CALL check16

    ; 9.02  PUSH AX → POP WORD [mem]
    MOV AX, 0CAFEh
    PUSH AX
    POP WORD [word_var]
    MOV AX, WORD [word_var]
    MOV DX, 0CAFEh
    CALL check16

    ; 9.03  XCHG reg, reg (non-AX, 87h form)
    MOV CX, 0AAh
    MOV BX, 55h
    XCHG CX, BX
    MOV AX, CX
    MOV DX, 55h
    CALL check16

    ; 9.04  XCHG AX, reg (90+r short form)
    MOV AX, 1111h
    MOV BX, 2222h
    XCHG AX, BX
    MOV DX, 2222h
    CALL check16

; ================ SECTION 10: MUL / DIV ======================
    MOV DX, s10_msg
    CALL print_str

    ; 10.01  MUL 8-bit: AL * BL → AX
    MOV AL, 10
    MOV BL, 20
    MUL BL
    MOV DX, 200
    CALL check16

    ; 10.02  MUL 16-bit: AX * CX → DX:AX
    MOV AX, 100
    MOV CX, 50
    MUL CX
    MOV DX, 5000
    CALL check16

    ; 10.03  DIV 8-bit: AX / BL → AL=quot AH=rem
    MOV AX, 100
    MOV BL, 7
    DIV BL
    XOR AH, AH
    MOV DX, 14
    CALL check16

    ; 10.04  DIV 16-bit: DX:AX / CX → AX=quot
    MOV DX, 0
    MOV AX, 10000
    MOV CX, 300
    DIV CX
    MOV DX, 33
    CALL check16

; ============ SECTION 11: Local Label Scoping =================
    MOV DX, s11_msg
    CALL print_str

    ; 11.01  func_add: 10 + 5 = 15
    CALL func_add
    MOV DX, 15
    CALL check16

    ; 11.02  func_sub: 10 - 5 = 5
    CALL func_sub
    MOV DX, 5
    CALL check16

; =========== SECTION 12: TEST, SREG mem, expr-in-disp =========
    MOV DX, s12_msg
    CALL print_str

    ; 12.01  TEST reg, imm — ZF set when AND=0
    MOV AX, 0F0h
    TEST AX, 0Fh
    JZ .t1_ok
    MOV AX, 0
    JMP .t1_chk
.t1_ok:
    MOV AX, 1
.t1_chk:
    MOV DX, 1
    CALL check16

    ; 12.02  TEST reg, imm — ZF clear when AND!=0
    MOV AX, 0FFh
    TEST AX, 0Fh
    JNZ .t2_ok
    MOV AX, 0
    JMP .t2_chk
.t2_ok:
    MOV AX, 1
.t2_chk:
    MOV DX, 1
    CALL check16

    ; 12.03  MOV [mem], SREG / MOV SREG, [mem] round-trip
    MOV WORD [word_var], ES              ; save ES
    MOV AX, 1234h
    MOV ES, AX
    MOV WORD [word_var2], ES             ; store new ES to mem
    MOV ES, WORD [word_var]              ; restore original ES
    MOV AX, WORD [word_var2]
    MOV DX, 1234h
    CALL check16

    ; 12.04  expression in memory displacement: [BX + (2*1 + 1)]
    ; db_data bytes: 10, 20, 30, 8, 15, 193
    MOV BX, db_data
    MOV AL, BYTE [BX + (2 * 1 + 1)]     ; disp=3, loads byte_var[3] = 8
    XOR AH, AH
    MOV DX, 8
    CALL check16

    ; 12.05  RETF round-trip via manual stack setup
    PUSH CS
    MOV AX, .retf_ok
    PUSH AX
    RETF
.retf_ok:
    MOV AX, 1
    MOV DX, 1
    CALL check16

; ============================================================
; SUMMARY
; ============================================================
    MOV DX, nl_msg
    CALL print_str

    ; Print "NN/NN passed"
    MOV AX, WORD [pass_count]
    CALL print_word
    MOV DL, '/'
    MOV AH, 02h
    INT 21h
    MOV AX, WORD [pass_count]
    ADD AX, WORD [fail_count]
    CALL print_word
    MOV DX, pass_msg
    CALL print_str

    ; Exit with fail_count as return code
    MOV AX, WORD [fail_count]
    MOV AH, 4Ch
    INT 21h

; ============================================================
; String data
; ============================================================
s1_msg:  DB 0Dh, 0Ah, 'Expr  $'
s2_msg:  DB 0Dh, 0Ah, 'EQU   $'
s3_msg:  DB 0Dh, 0Ah, 'DB/DW $'
s4_msg:  DB 0Dh, 0Ah, 'N/Neg $'
s5_msg:  DB 0Dh, 0Ah, 'Shift $'
s6_msg:  DB 0Dh, 0Ah, 'ALU   $'
s7_msg:  DB 0Dh, 0Ah, 'LEA   $'
s8_msg:  DB 0Dh, 0Ah, 'I/Dec $'
s9_msg:  DB 0Dh, 0Ah, 'Stk   $'
s10_msg: DB 0Dh, 0Ah, 'M/Div $'
s11_msg: DB 0Dh, 0Ah, 'Scope $'
s12_msg: DB 0Dh, 0Ah, 'Misc  $'
nl_msg:  DB 0Dh, 0Ah, '$'
pass_msg: DB ' passed', 0Dh, 0Ah, '$'
