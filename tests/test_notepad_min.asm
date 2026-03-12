; test_notepad_min.asm — Minimal test of notepad-like features
ORG 0x100
SCREEN CGA80

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

    ; Test 1: INT 10h AH=0Fh (get video mode)
    MOV AH, 0Fh
    INT 10h
    ; AL should be 3 (CGA80 mode), AH should be 80 (cols)
    ASSERT_EQ AX, 5003h

    ; Test 2: INT 21h AH=19h (get current drive)
    MOV AH, 19h
    INT 21h
    ; AL should be 2 (C:)
    ASSERT_EQ AX, 1902h

    ; Test 3: INT 10h AH=01h (set cursor shape - hide)
    MOV AH, 01h
    MOV CX, 2000h   ; bit 5 = hidden
    INT 10h

    ; Test 4: INT 10h AH=03h (get cursor - should report hidden)
    MOV AH, 03h
    MOV BH, 0
    INT 10h
    ; CH should have bit 5 set (0x20)
    ASSERT_EQ CX, 2000h

    ; Test 5: INT 33h AX=0000h (reset mouse)
    XOR AX, AX
    INT 33h
    ASSERT_EQ AX, 0FFFFh
    ASSERT_EQ BX, 3

    ; Test 6: PushAll/PopAll with procedure-like call
    MOV AX, 1234h
    MOV BX, 5678h
    CALL test_proc
    ASSERT_EQ AX, 1234h
    ASSERT_EQ BX, 5678h

    ; Test 7: VRAM write via STOSW (like _save_screen)
    MOV AX, 0B800h
    MOV DX, DS        ; save DS
    ; Can't MOV ES,AX directly in our old model, but now segments work
    ; The notepad uses MOV ES, AX then REP MOVSW
    ; Let's test direct VRAM write
    MOV DI, 0
    MOV AX, 0748h     ; 'H' with attr 07
    MOV WORD [0B8000h], AX   ; Direct memory write to VRAM base

    BREAKPOINT done : VRAMOUT
    HLT

test_proc:
    PushAll
    ; Do some work
    XOR AX, AX
    XOR BX, BX
    PopAll
    RET
