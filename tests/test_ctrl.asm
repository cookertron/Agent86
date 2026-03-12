; Test Ctrl+letter modifier produces control codes
; \C toggles Ctrl on/off. \Cx\C = Ctrl+x.
ORG 100h

    ; Ctrl+A (lowercase) = 0x01
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 1E01h

    ; Ctrl+Z (lowercase) = 0x1A
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 2C1Ah

    ; Ctrl+C (lowercase) = 0x03
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 2E03h

    ; Ctrl+H (lowercase) = 0x08
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 2308h

    ; Plain 'x' = 0x78
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 2D78h

    MOV AX, 4C00h
    INT 21h
