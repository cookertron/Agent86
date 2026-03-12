; test_include.asm — test INCLUDE directive
    ORG 100h

    MOV DX, greeting
    MOV AH, 09h
    INT 21h
    INT 20h

INCLUDE "test_inc.inc"
