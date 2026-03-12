; Test far conditional jump trampoline
ORG 100h
    CMP AX, 0
    JZ far_target    ; must trampoline: inverted JNZ +3, then JMP NEAR

; 200 bytes of padding
RESB 200

far_target:
    INT 20h
