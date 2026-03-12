; ==============================================
; Exhaustive jump/branch test
; Tests short, near, and inverted-trampoline paths
; ==============================================
ORG 100h

; --- Short conditional jumps (rel8 in range) ---
    XOR AX, AX
    CMP AX, 0
    JZ short_target          ; short forward
    JE short_target          ; alias
    JNZ skip1
    JNE skip1
    JB skip1
    JC skip1
    JNAE skip1
    JAE skip1
    JNC skip1
    JNB skip1
    JBE skip1
    JNA skip1
    JA skip1
    JNBE skip1
    JS skip1
    JNS skip1
    JO skip1
    JNO skip1
    JP skip1
    JPE skip1
    JNP skip1
    JPO skip1
    JL skip1
    JNGE skip1
    JGE skip1
    JNL skip1
    JLE skip1
    JNG skip1
    JG skip1
    JNLE skip1
short_target:
skip1:

; --- JMP SHORT (backward, within range) ---
    JMP skip1                ; should encode as EB rel8

; --- LOOP variants ---
    MOV CX, 5
loop_top:
    DEC AX
    LOOP loop_top
    LOOPE loop_top
    LOOPNE loop_top

; --- JCXZ ---
    XOR CX, CX
    JCXZ jcxz_target
    NOP
jcxz_target:

; --- JMP NEAR (forward, definitely near) ---
    JMP far_target

; --- Fill space to push far_target out of short range ---
; 200 bytes of DB 90h (NOPs as data, not instructions)
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
DB 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h

far_target:
; --- Far conditional jump (must use inverted trampoline) ---
    CMP AX, 1
    JZ back_far              ; this should be inverted (JNZ +3, JMP NEAR back_far)

; Exit
    INT 20h

back_far:
    NOP
    INT 20h
