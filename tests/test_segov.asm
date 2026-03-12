; Test segment override prefix syntax: ES:[reg], CS:[reg], SS:[reg], DS:[reg]
ORG 100h

    ; Setup: ES = 0x1000 (separate segment), DS = 0
    MOV AX, 1000h
    MOV ES, AX

    ; Write a known value to ES:0000 via segment swap
    ; (ES:0000 = physical 0x10000)
    MOV AX, ES
    MOV DS, AX          ; DS = 0x1000 temporarily
    MOV WORD [0], 1234h ; DS:0000 = 0x1234
    MOV BYTE [2], 42h   ; DS:0002 = 0x42
    XOR AX, AX
    MOV DS, AX          ; DS = 0 again

    ; Test 1: MOV reg, ES:[mem] — read from ES segment
    MOV DI, 0
    MOV AX, ES:[DI]
    ASSERT_EQ AX, 1234h

    ; Test 2: MOV with displacement ES:[DI+2]
    MOV AL, ES:[DI+2]
    ASSERT_EQ AX, 1242h   ; AH still 12h from previous, AL now 42h

    ; Test 3: MOV ES:[mem], reg — write via ES override
    MOV WORD ES:[DI+4], 5678h
    MOV AX, ES:[DI+4]
    ASSERT_EQ AX, 5678h

    ; Test 4: ADD with ES segment override
    MOV AX, 0
    ADD AX, ES:[DI]      ; AX += ES:[0] = 0x1234
    ASSERT_EQ AX, 1234h

    ; Test 5: CMP with ES segment override
    CMP WORD ES:[DI], 1234h
    JNE .fail
    JMP .pass5
.fail:
    HLT
.pass5:

    ; Test 6: BYTE size override + segment override
    MOV AL, BYTE ES:[DI+2]
    ASSERT_EQ AX, 1242h   ; AH unchanged, AL = 42h

    ; Test 7: Verify bytes via HEX dump of a simple instruction
    HEX_START
    MOV AX, ES:[DI]       ; should be: 26 8B 05
    HEX_END

    ; Test 8: SS segment override
    ; SS:SP area — write and read back
    MOV BP, SP
    SUB SP, 2
    MOV WORD SS:[BP-2], 0AAAAh
    MOV AX, SS:[BP-2]
    ASSERT_EQ AX, 0AAAAh
    ADD SP, 2

    ; Success
    MOV AX, 4C00h
    INT 21h
