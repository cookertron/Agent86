; test_regs.asm — Test REGS debug modifier
    ORG 100h

    ; Set up some register values
    MOV AX, 42
    MOV BX, 1024
    MOV CX, 255
    MOV DX, 7

    ; Standalone REGS snapshot (should accumulate in reg_dumps)
    REGS

    ; Change registers
    MOV SI, 100
    MOV DI, 200

    ; Another standalone REGS
    REGS

    ; BREAKPOINT with REGS modifier — should halt and include regs in JSON
    BREAKPOINT : REGS

    ; This should not execute
    MOV AX, 9999
    HLT
