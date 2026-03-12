; test_notepad_entry.asm — Test notepad entry up to tui_init
ORG 0x100
SCREEN CGA80

    JMP main

INCLUDE ..\notepad\TUI\tui.inc
INCLUDE ..\notepad\editor_const.inc
INCLUDE ..\notepad\editor_gap.inc
INCLUDE ..\notepad\editor_ctrl.inc
INCLUDE ..\notepad\editor_file.inc
INCLUDE ..\notepad\editor_clip.inc
INCLUDE ..\notepad\editor_find.inc
INCLUDE ..\notepad\editor_undo.inc

; ---- minimal stubs for handlers that notepad.asm defines ----
handler_file_new:
handler_file_open:
handler_file_save:
handler_file_save_as:
    RET

handler_file_exit: PROC
    MOV BYTE [fw_state + FW_RUNNING], 0
    RET
ENDP

handler_edit_undo:
handler_edit_redo:
handler_edit_cut:
handler_edit_copy:
handler_edit_paste:
handler_edit_select_all:
handler_edit_find:
handler_edit_find_next:
handler_edit_replace:
handler_help_about:
    RET

; ---- main entry ----
main:
    ; Step 1: get video mode
    MOV AH, 0Fh
    INT 10h
    CMP AL, 07h
    JZ .mda_exit

    ; Step 2: get current drive
    MOV AH, 19h
    INT 21h

    ; Step 3: save screen
    CALL _save_screen

    BREAKPOINT after_save : VRAMOUT
    HLT

.mda_exit:
    HLT

; --- Include notepad's screen save/restore ---
_save_screen: PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PUSH DS
    PUSH ES

    MOV AH, 03h
    XOR BH, BH
    INT 10h

    MOV AX, 0B800h
    MOV DS, AX
    MOV ES, AX
    XOR SI, SI
    MOV DI, 1000h
    MOV CX, 2000
    CLD
    REP MOVSW

    POP ES
    POP DS
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ENDP
