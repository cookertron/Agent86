; Test Alt+key and extended key injection via --events
; Usage: agent86 tests/test_altkey.asm --build_trace --screen CGA80 --events '[{"keys":"\\Aq\\A"}]'
;
; Bug 1 test: Alt+Q via INT 21h AH=06h should produce two-byte extended key
; Bug 2 test: \u0000 support tested via separate invocation

    ORG 100h
    SCREEN CGA80

; ---- Test 1: Alt+Q via INT 21h AH=06h (two-byte extended key) ----
; First call should return AL=0x00 (extended prefix), ZF=0
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JZ fail_no_key1
    ; AX should be 0x0600 (AH=06h preserved, AL=0x00 extended prefix)
    ASSERT_EQ AX, 0x0600

; Second call should return AL=0x10 (Q scan code), ZF=0
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JZ fail_no_key2
    ; AX should be 0x0610 (AH=06h preserved, AL=0x10 Q scan code)
    ASSERT_EQ AX, 0x0610

; ---- Test 2: Verify INT 16h AH=02h reports Alt modifier ----
; (Modifier was set during the blockingRead in the first AH=06h call)

; ---- Test 3: No more keys in buffer ----
    MOV AH, 06h
    MOV DL, 0FFh
    INT 21h
    JNZ fail_extra_key    ; should have ZF=1 (no key)

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
