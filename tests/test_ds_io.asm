; test_ds_io.asm — verify INT 21h respects DS segment for I/O
; Tests: AH=09h print, AH=3Ch/40h/3Fh file write/read with non-zero DS
; Also tests memory allocator returns segment >= 0x1000

ORG 100h

; ── Test 1: Memory allocator returns segment >= 0x1000 ────────
    MOV AH, 48h         ; allocate memory
    MOV BX, 100h        ; 256 paragraphs (4KB)
    INT 21h
    JC .alloc_fail
    ; AX = allocated segment, must be >= 0x1000
    CMP AX, 1000h
    JB .alloc_fail
    MOV [alloc_seg], AX  ; save for later

    ; Free it
    MOV ES, AX
    MOV AH, 49h
    INT 21h

; ── Test 2: AH=09h reads string from DS segment ──────────────
    ; Allocate a segment
    MOV AH, 48h
    MOV BX, 10h         ; 16 paragraphs (256 bytes)
    INT 21h
    JC .alloc_fail
    MOV [alloc_seg], AX

    ; Write "Hi$" to allocated segment at offset 0
    MOV ES, AX
    MOV BYTE ES:[0000h], 'H'
    MOV BYTE ES:[0001h], 'i'
    MOV BYTE ES:[0002h], '$'

    ; Now set DS to allocated segment and print from DS:DX
    PUSH DS              ; save original DS
    MOV DS, AX
    MOV AH, 09h
    MOV DX, 0000h       ; DS:0000 = "Hi$"
    INT 21h
    POP DS               ; restore DS

; ── Test 3: AH=3Ch/40h write file with non-zero DS ───────────
    ; Create test file (DS still points to COM segment here)
    MOV AH, 3Ch
    XOR CX, CX
    MOV DX, fname
    INT 21h
    JC .file_fail
    MOV [fhandle], AX

    ; Write "AB" into the allocated segment at offset 0010h
    MOV AX, [alloc_seg]
    MOV ES, AX
    MOV BYTE ES:[0010h], 'A'
    MOV BYTE ES:[0011h], 'B'

    ; Save handle to BX before switching DS
    MOV BX, [fhandle]

    ; Set DS to allocated segment, write 2 bytes from DS:0010h
    PUSH DS
    MOV AX, [alloc_seg]
    MOV DS, AX
    MOV AH, 40h
    ; BX already has handle
    MOV CX, 2
    MOV DX, 0010h
    INT 21h
    POP DS
    ASSERT_EQ AX, 2          ; 2 bytes written

    ; Close file
    MOV AH, 3Eh
    MOV BX, [fhandle]
    INT 21h

; ── Test 4: AH=3Dh/3Fh read file into non-zero DS ───────────
    ; Reopen for reading
    MOV AH, 3Dh
    MOV AL, 0
    MOV DX, fname
    INT 21h
    JC .file_fail
    MOV [fhandle], AX

    ; Clear the read target area in allocated segment
    MOV AX, [alloc_seg]
    MOV ES, AX
    MOV BYTE ES:[0020h], 0
    MOV BYTE ES:[0021h], 0

    ; Save handle before switching DS
    MOV BX, [fhandle]

    ; Read 2 bytes into allocated segment at DS:0020h
    PUSH DS
    MOV AX, [alloc_seg]
    MOV DS, AX
    MOV AH, 3Fh
    ; BX already has handle
    MOV CX, 2
    MOV DX, 0020h
    INT 21h
    POP DS
    ASSERT_EQ AX, 2          ; 2 bytes read

    ; Verify the bytes were read to the correct location
    MOV AX, [alloc_seg]
    MOV ES, AX
    ; Check ES:[0020h] = 'A' (0x41)
    XOR AX, AX
    MOV AL, ES:[0020h]
    ASSERT_EQ AX, 41h
    ; Check ES:[0021h] = 'B' (0x42)
    XOR AX, AX
    MOV AL, ES:[0021h]
    ASSERT_EQ AX, 42h

    ; Close and delete test file
    MOV AH, 3Eh
    MOV BX, [fhandle]
    INT 21h
    MOV AH, 41h
    MOV DX, fname
    INT 21h

    ; Free allocated memory
    MOV AX, [alloc_seg]
    MOV ES, AX
    MOV AH, 49h
    INT 21h

    ; Success
    MOV AH, 4Ch
    MOV AL, 0
    INT 21h

.alloc_fail:
    BREAKPOINT alloc_fail
    MOV AH, 4Ch
    MOV AL, 1
    INT 21h

.file_fail:
    BREAKPOINT file_fail
    MOV AH, 4Ch
    MOV AL, 2
    INT 21h

; ── Data ──────────────────────────────────────────────────────
alloc_seg:  DW 0
fhandle:    DW 0
fname:      DB '_dstest.tmp', 0
