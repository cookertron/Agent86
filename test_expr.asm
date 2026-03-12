; test_expr.asm — exercise extended expression evaluator
; Tests: parentheses, modulo, bitwise AND/OR/XOR/NOT, shifts, nesting
; Expected: all MOV values match, program exits cleanly via INT 20h

ORG 100h

; === EQU constants for testing ===
A       EQU  5
B       EQU  3
C       EQU  4

; --- Test 1: (A + B) * C  =>  (5+3)*4 = 32 ---
    MOV AX, (A + B) * C        ; expect 32 = 0020h

; --- Test 2: modulo ---
    MOV BX, 100 % 16           ; expect 4

; --- Test 3: bitwise AND mask ---
    MOV CX, 1234h & 0FFh       ; expect 34h = 52

; --- Test 4: bitwise OR ---
    MOV DX, 0F0h | 0Fh         ; expect FFh = 255

; --- Test 5: bitwise XOR ---
    MOV SI, 0FFh ^ 0AAh        ; expect 55h = 85

; --- Test 6: bitwise NOT (truncated to 16-bit) ---
    MOV DI, ~0FFh & 0FFFFh     ; expect FF00h

; --- Test 7: shift left ---
    MOV AX, 1 << 8             ; expect 100h = 256

; --- Test 8: shift right ---
    MOV BX, 0FF00h >> 4        ; expect 0FF0h = 4080

; --- Test 9: nested parens ((A+1) * (B-1)) => (6*2) = 12 ---
    MOV CX, ((A + 1) * (B - 1))  ; expect 12

; --- Test 10: ($ - table) address math via JMP-over ---
    JMP skip_data
table:
    DB 'ABCD'
table_end:
skip_data:
TABLE_SZ EQU (table_end - table)  ; should be 4
    MOV DX, TABLE_SZ              ; expect 4

; --- Test 11: combined ops  (sz % 16) | (1 << 4) ---
SZ      EQU  35
    MOV SI, (SZ % 16) | (1 << 4)  ; 35%16=3, 1<<4=16, 3|16=19

; --- Test 12: precedence: & binds tighter than | ---
    MOV DI, 0F0h | 03h & 0Fh     ; & first: 03h&0Fh=03h, then 0F0h|03h=0F3h=243

; --- Verify all results ---
    CMP AX, 256
    JNE .fail
    CMP BX, 4080
    JNE .fail
    CMP CX, 12
    JNE .fail
    CMP DX, 4
    JNE .fail
    CMP SI, 19
    JNE .fail
    CMP DI, 0F3h
    JNE .fail

    ; Print "OK"
    MOV AH, 02h
    MOV DL, 'O'
    INT 21h
    MOV DL, 'K'
    INT 21h
    INT 20h

.fail:
    MOV AH, 02h
    MOV DL, '!'
    INT 21h
    INT 20h
