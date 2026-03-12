; test_offset4.asm — Full TUI include, check MAIN alignment
ORG 0x100
    JMP main

INCLUDE ..\notepad\TUI\tui.inc

main:
    MOV AH, 0Fh
    INT 10h
    HLT
