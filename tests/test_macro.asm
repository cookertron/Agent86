; test_macro.asm — Test MACRO/IRP support
ORG 0x100

; Define PushAll/PopAll macros (like notepad uses)
PushAll MACRO
    IRP r, <AX, BX, CX, DX, SI, DI>
        PUSH r
    ENDM
ENDM

PopAll MACRO
    IRP r, <DI, SI, DX, CX, BX, AX>
        POP r
    ENDM
ENDM

; Test 1: PushAll/PopAll round-trip
    MOV AX, 1111h
    MOV BX, 2222h
    MOV CX, 3333h
    MOV DX, 4444h
    MOV SI, 5555h
    MOV DI, 6666h

    PushAll

    ; Clobber all regs
    XOR AX, AX
    XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    XOR SI, SI
    XOR DI, DI

    PopAll

    ; Verify all restored
    ASSERT_EQ AX, 1111h
    ASSERT_EQ BX, 2222h
    ASSERT_EQ CX, 3333h
    ASSERT_EQ DX, 4444h
    ASSERT_EQ SI, 5555h
    ASSERT_EQ DI, 6666h

    HLT
