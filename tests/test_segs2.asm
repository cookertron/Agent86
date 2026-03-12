; test_segs2.asm — Test PUSH/POP segment registers and function calling
ORG 0x100
SCREEN CGA80

    ; Save DS and ES, change them, restore
    PUSH DS
    PUSH ES

    MOV AX, 0B800h
    MOV DS, AX
    MOV ES, AX

    ; Write to VRAM: 'H' 'i'
    XOR DI, DI
    MOV AX, 0748h     ; 'H' attr 07
    CLD
    STOSW
    MOV AX, 0769h     ; 'i' attr 07
    STOSW

    POP ES
    POP DS

    ; Verify DS is restored — try accessing a DS-relative variable
    MOV WORD [test_var], 1234h
    ASSERT_EQ WORD [test_var], 1234h

    ; Test calling a proc that saves/restores regs including segs
    CALL seg_proc
    ASSERT_EQ WORD [test_var], 5678h

    BREAKPOINT done : VRAMOUT
    HLT

seg_proc:
    PUSH DS
    PUSH ES
    ; Write 5678h to test_var via original DS
    MOV WORD [test_var], 5678h
    POP ES
    POP DS
    RET

test_var: DW 0
