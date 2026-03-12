ORG 0x100
    JMP main
INCLUDE ..\notepad\TUI\tui_const.inc
INCLUDE ..\notepad\TUI\tui_macros.inc
INCLUDE ..\notepad\TUI\tui_video.inc
INCLUDE ..\notepad\TUI\tui_window.inc
INCLUDE ..\notepad\TUI\tui_control.inc
INCLUDE ..\notepad\TUI\tui_menu.inc
INCLUDE ..\notepad\TUI\tui_mouse.inc
INCLUDE ..\notepad\TUI\tui_event.inc
INCLUDE ..\notepad\TUI\tui_dialog.inc
INCLUDE ..\notepad\TUI\tui_data.inc
main:
    MOV AH, 0Fh
    INT 10h
    HLT
