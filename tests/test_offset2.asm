; test_offset2.asm — Test with TUI includes
ORG 0x100

    JMP main

INCLUDE ..\notepad\TUI\tui_const.inc
INCLUDE ..\notepad\TUI\tui_macros.inc

test_func:
    PushAll
    PopAll
    RET

main:
    MOV AX, 1234h
    CALL test_func
    ASSERT_EQ AX, 1234h
    HLT
