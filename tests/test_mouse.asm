; test_mouse.asm — Test INT 33h mouse driver
ORG 0x100

    ; Reset mouse driver (AX=0000h)
    XOR AX, AX
    INT 33h
    ; Should return AX=FFFFh (present), BX=3 (buttons)
    ASSERT_EQ AX, 0FFFFh
    ASSERT_EQ BX, 3

    ; Set horizontal range (AX=0007h, CX=min, DX=max)
    MOV AX, 0007h
    MOV CX, 0
    MOV DX, 319
    INT 33h

    ; Set vertical range (AX=0008h, CX=min, DX=max)
    MOV AX, 0008h
    MOV CX, 0
    MOV DX, 199
    INT 33h

    ; Show cursor (AX=0001h)
    MOV AX, 0001h
    INT 33h

    ; Get position (AX=0003h)
    MOV AX, 0003h
    INT 33h
    ; Should return BX=0 (no buttons), CX=0, DX=0
    ASSERT_EQ BX, 0
    ASSERT_EQ CX, 0
    ASSERT_EQ DX, 0

    ; Hide cursor (AX=0002h)
    MOV AX, 0002h
    INT 33h

    HLT
