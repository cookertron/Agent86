; test_offset.asm — Minimal test for address offset bug
ORG 0x100

    JMP main

; Include a macro definition (like notepad does)
PushAll MACRO
    IRP r, <AX, BX, CX, DX, SI, DI>
        PUSH r
    ENDM
ENDM

PopAll MACRO
    IRP r, <DI, SI, DX, CX, BX, AX>
        POP r
    ENDM
ENDM

test_func:
    PushAll
    PopAll
    RET

main:
    CALL test_func
    HLT
