; test_hello25.asm — Print "Hello World!" 25 times, breakpoint after 10 with VRAMOUT
ORG 0x100
SCREEN CGA80

    MOV CX, 25
.loop:
    BREAKPOINT after10, 10 : VRAMOUT
    PUSH CX

    ; Print "Hello World!\r\n" via INT 21h AH=09h
    MOV AH, 09h
    MOV DX, msg
    INT 21h

    POP CX
    DEC CX
    JNZ .loop

    HLT

msg: DB "Hello World!", 0Dh, 0Ah, '$'
