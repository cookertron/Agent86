; test_dos21.asm — Integration test for expanded INT 21h services
; Tests: stubs, file I/O, console input, CHDIR/CWD, memory alloc/free

ORG 0x100

    ; ──────────────────────────────────────────────────
    ; Section 1: Stubs (DOS version, date, time, PSP, DTA, IVT)
    ; ──────────────────────────────────────────────────

    ; AH=30h — Get DOS version → AL should be 5
    MOV AH, 0x30
    INT 0x21
    ; AL=5 (major), AH=0 (minor) → AX=0x0005
ASSERT_EQ AX, 0x0005

    ; AH=2Ah — Get date → CX should be 2026
    MOV AH, 0x2A
    INT 0x21
ASSERT_EQ CX, 2026

    ; AH=2Ch — Get time → CH=12, CL=0 → CX=0x0C00
    MOV AH, 0x2C
    INT 0x21
ASSERT_EQ CX, 0x0C00

    ; AH=62h — Get PSP → BX should be 0
    MOV AH, 0x62
    INT 0x21
ASSERT_EQ BX, 0

    ; AH=1Ah / AH=2Fh — Set/Get DTA round-trip
    MOV DX, 0x200
    MOV AH, 0x1A
    INT 0x21
    MOV AH, 0x2F
    INT 0x21
ASSERT_EQ BX, 0x200

    ; AH=25h — Set IVT (should not crash, just stub)
    MOV AH, 0x25
    MOV AL, 0x00
    INT 0x21

    ; AH=35h — Get IVT → ES:BX = 0:0
    MOV AH, 0x35
    MOV AL, 0x00
    INT 0x21
ASSERT_EQ BX, 0

    ; ──────────────────────────────────────────────────
    ; Section 2: File I/O — create, write, close, reopen, read, verify, delete
    ; ──────────────────────────────────────────────────

    ; Create file
    MOV AH, 0x3C
    MOV CX, 0          ; normal attributes
    LEA DX, [FNAME]
    INT 0x21
    JC .FAIL
    MOV [FHANDLE], AX   ; save handle

    ; Write "HELLO" (5 bytes)
    MOV AH, 0x40
    MOV BX, [FHANDLE]
    MOV CX, 5
    LEA DX, [FDATA]
    INT 0x21
    JC .FAIL
ASSERT_EQ AX, 5

    ; Close file
    MOV AH, 0x3E
    MOV BX, [FHANDLE]
    INT 0x21
    JC .FAIL

    ; Reopen for reading
    MOV AH, 0x3D
    MOV AL, 0          ; read-only
    LEA DX, [FNAME]
    INT 0x21
    JC .FAIL
    MOV [FHANDLE], AX

    ; Read 5 bytes into buffer
    MOV AH, 0x3F
    MOV BX, [FHANDLE]
    MOV CX, 5
    LEA DX, [RBUF]
    INT 0x21
    JC .FAIL
ASSERT_EQ AX, 5

    ; Verify first byte = 'H' (0x48)
ASSERT_EQ BYTE [RBUF], 0x48

    ; Verify last byte = 'O' (0x4F)
ASSERT_EQ BYTE [RBUF+4], 0x4F

    ; Seek to beginning (AL=0 = SEEK_SET, CX:DX = 0:0)
    MOV AH, 0x42
    MOV AL, 0
    MOV BX, [FHANDLE]
    XOR CX, CX
    XOR DX, DX
    INT 0x21
    JC .FAIL
ASSERT_EQ AX, 0

    ; Seek to end to get file size
    MOV AH, 0x42
    MOV AL, 2           ; SEEK_END
    MOV BX, [FHANDLE]
    XOR CX, CX
    XOR DX, DX
    INT 0x21
    JC .FAIL
ASSERT_EQ AX, 5         ; file is 5 bytes

    ; AH=57h — Get file date/time (just check it doesn't crash)
    MOV AH, 0x57
    MOV AL, 0
    MOV BX, [FHANDLE]
    INT 0x21

    ; AH=44h/00 — IOCTL get device info for file handle
    MOV AX, 0x4400
    MOV BX, [FHANDLE]
    INT 0x21
    JC .FAIL
ASSERT_EQ DX, 0x0000    ; disk file

    ; AH=44h/00 — IOCTL for stdout (device)
    MOV AX, 0x4400
    MOV BX, 1
    INT 0x21
    JC .FAIL
ASSERT_EQ DX, 0x80D3    ; device

    ; Close
    MOV AH, 0x3E
    MOV BX, [FHANDLE]
    INT 0x21

    ; Delete file
    MOV AH, 0x41
    LEA DX, [FNAME]
    INT 0x21
    JC .FAIL

    ; Try to open deleted file — should fail (CF=1)
    MOV AH, 0x3D
    MOV AL, 0
    LEA DX, [FNAME]
    INT 0x21
    JC .DELETE_OK
    ; If we get here, it didn't fail — that's a problem
    JMP .FAIL

.DELETE_OK:

    ; ──────────────────────────────────────────────────
    ; Section 3: Memory allocate / free
    ; ──────────────────────────────────────────────────

    ; Allocate 16 paragraphs (256 bytes)
    MOV AH, 0x48
    MOV BX, 16
    INT 0x21
    JC .FAIL
    MOV [MSEG], AX      ; save segment

    ; Free it
    MOV ES, [MSEG]
    MOV AH, 0x49
    INT 0x21
    JC .FAIL

    ; ──────────────────────────────────────────────────
    ; Section 4: AH=40h stdout write (handle 1)
    ; ──────────────────────────────────────────────────

    MOV AH, 0x40
    MOV BX, 1           ; stdout
    MOV CX, 4
    LEA DX, [PASS_MSG]
    INT 0x21

    ; ──────────────────────────────────────────────────
    ; Success — terminate
    ; ──────────────────────────────────────────────────

    MOV AH, 0x4C
    MOV AL, 0
    INT 0x21

.FAIL:
    ; Print FAIL and exit
    MOV AH, 0x09
    LEA DX, [FAIL_MSG]
    INT 0x21
    MOV AH, 0x4C
    MOV AL, 1
    INT 0x21

; ── Data ──────────────────────────────────────────────

FNAME:   DB "_test_dos21.tmp", 0
FDATA:   DB "HELLO"
RBUF:    DB 0,0,0,0,0,0,0,0
FHANDLE: DW 0
MSEG:    DW 0
PASS_MSG: DB "OK", 0x0D, 0x0A
FAIL_MSG: DB "FAIL$"
