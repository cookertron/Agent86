; test_screen.asm — Integration test for video framebuffer + segmented addressing
; Run: agent86 test_screen.asm --build_run
; Verify: JSON output includes "screen" object with correct text
SCREEN CGA80
ORG 100h

    ; === Test 1: Direct VRAM write via STOSW (ES:DI) ===
    ; Set ES = B800h (CGA VRAM segment)
    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 0            ; row 0, col 0

    ; Write 'H' with attr 07h using STOSW
    MOV AX, 0748h        ; AH=07 (attr), AL=48h ('H') — little-endian: char first
    STOSW                 ; [ES:DI] = AX, DI += 2

    ; Write 'i' with attr 07h
    MOV AX, 0769h        ; 'i' with white-on-black
    STOSW

    ; === Test 2: INT 10h AH=02h - Set cursor position ===
    MOV AH, 02h
    MOV BH, 0            ; page 0
    MOV DH, 1            ; row 1
    MOV DL, 0            ; col 0
    INT 10h

    ; === Test 3: INT 10h AH=0Eh - Teletype output ===
    MOV AH, 0Eh
    MOV AL, 'O'
    INT 10h
    MOV AH, 0Eh
    MOV AL, 'K'
    INT 10h

    ; === Test 4: INT 10h AH=03h - Get cursor position ===
    ; After writing "OK" at row 1, cursor should be at row 1, col 2
    MOV AH, 03h
    MOV BH, 0
    INT 10h
    ; DH should be 1 (row), DL should be 2 (col)
    CMP DH, 1
    JNE .fail
    CMP DL, 2
    JNE .fail

    ; === Test 5: INT 10h AH=09h - Write char+attr at cursor ===
    ; Cursor is at row 1, col 2
    MOV AH, 09h
    MOV AL, '!'
    MOV BL, 0Fh          ; bright white
    MOV CX, 3            ; write 3 times
    INT 10h
    ; Should write "!!!" at (1,2), (1,3), (1,4) without moving cursor

    ; === Test 6: INT 10h AH=0Fh - Get video mode ===
    MOV AH, 0Fh
    INT 10h
    CMP AL, 03h           ; CGA80 = mode 3
    JNE .fail
    CMP AH, 80            ; 80 columns
    JNE .fail

    ; === Test 7: Direct VRAM write at last row via STOSW ===
    ; Row 24, col 0: offset = (24 * 80) * 2 = 3840
    MOV AX, 0B800h
    MOV ES, AX
    MOV DI, 3840
    MOV AX, 075Ah         ; 'Z' (5Ah) with attr 07h
    STOSW

    ; Print pass message to stderr via INT 21h
    MOV AH, 09h
    MOV DX, pass_msg
    INT 21h

    ; Exit successfully
    MOV AX, 4C00h
    INT 21h

.fail:
    MOV AH, 09h
    MOV DX, fail_msg
    INT 21h
    MOV AX, 4C01h
    INT 21h

pass_msg: DB 'SCREEN TEST PASSED$'
fail_msg: DB 'SCREEN TEST FAILED$'
