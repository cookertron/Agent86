; test_segs.asm — Test segment register manipulation + REP MOVSW
ORG 0x100
SCREEN CGA80

    ; Write something to VRAM via segment manipulation
    ; (like notepad's _save_screen does)
    PUSH DS
    PUSH ES

    ; Set ES to VRAM segment
    MOV AX, 0B800h
    MOV ES, AX

    ; Write 'A' with attr 0x07 to first cell using STOSW
    XOR DI, DI
    MOV AX, 0741h      ; attr=07, char='A'
    CLD
    STOSW               ; Write to ES:DI (B800:0000)

    ; Write 'B' to second cell
    MOV AX, 0742h
    STOSW

    ; Now copy page 0 to page 1 (like notepad does)
    ; DS=ES=B800h, SI=0, DI=1000h
    MOV AX, 0B800h
    MOV DS, AX
    XOR SI, SI
    MOV DI, 1000h
    MOV CX, 2
    REP MOVSW

    POP ES
    POP DS

    BREAKPOINT vram_check : VRAMOUT
    HLT
