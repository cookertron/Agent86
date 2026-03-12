; test_macro2.asm — Test parameterized macros and standalone IRP
ORG 0x100

; Parameterized macro: load register with value
LoadReg MACRO reg, val
    MOV reg, val
ENDM

; Test parameterized macro
    LoadReg AX, 42h
    ASSERT_EQ AX, 42h
    LoadReg BX, 99h
    ASSERT_EQ BX, 99h

; Test standalone IRP (not inside a macro)
    IRP val, <10h, 20h, 30h>
        ADD AX, val
    ENDM
    ; AX was 42h, + 10h + 20h + 30h = A2h
    ASSERT_EQ AX, 0A2h

    HLT
