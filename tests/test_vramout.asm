; test_vramout.asm — VRAMOUT debug directive integration test
; Tests standalone VRAMOUT, BREAKPOINT:VRAMOUT, PARTIAL mode, ATTRS
ORG 0x100
SCREEN CGA80

    ; Set up segment registers for VRAM access
    MOV AX, 0B800h
    MOV ES, AX

    ; Write "Hi" at row 0, cols 0-1 with attribute 07h (white on black)
    MOV AX, 0x0748   ; 'H' with attr 07h
    MOV DI, 0
    STOSW             ; ES:[DI] = 0748h, DI += 2
    MOV AX, 0x0769   ; 'i' with attr 07h
    STOSW             ; ES:[DI] = 0769h, DI += 2

    ; Write "AB" at row 1, cols 0-1 with attribute 0Fh (bright white)
    MOV DI, 160       ; row 1 = 80*2 = 160
    MOV AX, 0x0F41    ; 'A' with attr 0Fh
    STOSW
    MOV AX, 0x0F42    ; 'B' with attr 0Fh
    STOSW

    ; Standalone VRAMOUT — full screen, no attrs (snapshot 1)
    VRAMOUT

    ; Standalone VRAMOUT — full with attrs (snapshot 2)
    VRAMOUT FULL, ATTRS

    ; Standalone VRAMOUT — partial region (snapshot 3)
    VRAMOUT PARTIAL 0, 0, 10, 2

    ; Hit breakpoint with VRAMOUT FULL, ATTRS to verify screen in BREAKPOINT JSON
    BREAKPOINT : VRAMOUT FULL, ATTRS

    ; Should not reach here
    HLT
