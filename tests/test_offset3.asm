; test_offset3.asm — Add tui_video.inc to find the 4-byte shift
ORG 0x100

    JMP main

INCLUDE ..\notepad\TUI\tui_const.inc
INCLUDE ..\notepad\TUI\tui_macros.inc
INCLUDE ..\notepad\TUI\tui_video.inc

main:
    MOV AH, 0Fh
    INT 10h
    HLT
