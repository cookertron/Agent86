; Test \uXXXX unicode escape in --events JSON
; Usage: agent86 tests/test_unicode_esc.asm --build_trace --screen CGA80 --events '[{"keys":"\u0000\u0044"}]'
;
; Injects F10 (extended key: 0x00 prefix + 0x44 scan code) via \u escapes

    ORG 100h
    SCREEN CGA80

; ---- Test: F10 via INT 21h AH=06h ----
; First call: should return AL=0x00 (extended prefix)
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JZ fail_no_key1
    ASSERT_EQ AX, 0x0600     ; AL=0x00 extended prefix

; Second call: should return AL=0x44 (F10 scan code)
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JZ fail_no_key2
    ASSERT_EQ AX, 0x0644     ; AL=0x44 F10 scan code

; No more keys
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JNZ fail_extra_key

    BREAKPOINT pass : REGS
    INT 20h

fail_no_key1:
    BREAKPOINT fail_no_key1 : REGS
    INT 20h
fail_no_key2:
    BREAKPOINT fail_no_key2 : REGS
    INT 20h
fail_extra_key:
    BREAKPOINT fail_extra_key : REGS
    INT 20h
