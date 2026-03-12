; test_offset5.asm — No macros, manually expanded, check alignment
ORG 0x100
    JMP main

; Some code to simulate the includes
func1:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    XOR AX, AX
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

func2:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    XOR BX, BX
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

main:
    MOV AH, 0Fh
    CALL func1
    CALL func2
    HLT
