; test_log.asm — Test LOG and LOG_ONCE runtime debug directives
    ORG 100h

    ; --- Test 1: LOG with message only ---
    MOV AX, 42
    LOG "checkpoint alpha"

    ; --- Test 2: LOG with register ---
    MOV BX, 1024
    LOG "AX value", AX

    ; --- Test 3: LOG with BYTE memory ---
    MOV BYTE [0x200], 0x48
    LOG "byte at 0x200", BYTE [0x200]

    ; --- Test 4: LOG with WORD memory ---
    MOV WORD [0x202], 0xBEEF
    LOG "word at 0x202", WORD [0x202]

    ; --- Test 5: LOG_ONCE in a loop ---
    MOV CX, 5
.loop:
    LOG_ONCE loop_entry, "entered loop", CX
    LOG "iteration", CX
    DEC CX
    JNZ .loop

    ; --- Test 6: Another LOG_ONCE with same label should NOT fire ---
    LOG_ONCE loop_entry, "should not appear", AX

    HLT
