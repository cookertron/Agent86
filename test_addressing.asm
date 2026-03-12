; ==============================================
; Exhaustive 16-bit addressing mode test
; ==============================================
ORG 100h

; --- Register direct (mod=11) ---
MOV AX, BX
MOV CL, DH

; --- Immediate ---
MOV AX, 42
MOV CL, 0FFh

; --- Direct address [disp16] (mod=00, r/m=110) ---
MOV AX, [data_word]
MOV [data_word], AX
MOV AL, [data_byte]
MOV [data_byte], AL

; --- [BX] (mod=00, r/m=111) ---
MOV AX, [BX]
MOV [BX], AX
MOV AL, [BX]
MOV [BX], AL

; --- [BX + disp8] (mod=01, r/m=111) ---
MOV AX, [BX + 5]
MOV [BX + 5], AX

; --- [BX + disp16] (mod=10, r/m=111) ---
MOV AX, [BX + 1000]
MOV [BX + 1000], AX

; --- [BP] (special: encoded as [BP + disp8=0], mod=01, r/m=110) ---
MOV AX, [BP]
MOV [BP], AX

; --- [BP + disp8] (mod=01, r/m=110) ---
MOV AX, [BP + 5]
MOV [BP + 5], AX

; --- [BP + disp16] (mod=10, r/m=110) ---
MOV AX, [BP + 1000]
MOV [BP + 1000], AX

; --- [SI] (mod=00, r/m=100) ---
MOV AX, [SI]
MOV [SI], AX

; --- [SI + disp8] (mod=01, r/m=100) ---
MOV AX, [SI + 5]
MOV [SI + 5], AX

; --- [DI] (mod=00, r/m=101) ---
MOV AX, [DI]
MOV [DI], AX

; --- [DI + disp8] (mod=01, r/m=101) ---
MOV AX, [DI + 5]
MOV [DI + 5], AX

; --- [BX + SI] (mod=00, r/m=000) ---
MOV AX, [BX + SI]
MOV [BX + SI], AX

; --- [BX + SI + disp8] (mod=01, r/m=000) ---
MOV AX, [BX + SI + 5]
MOV [BX + SI + 5], AX

; --- [BX + SI + disp16] (mod=10, r/m=000) ---
MOV AX, [BX + SI + 1000]
MOV [BX + SI + 1000], AX

; --- [BX + DI] (mod=00, r/m=001) ---
MOV AX, [BX + DI]
MOV [BX + DI], AX

; --- [BX + DI + disp8] (mod=01, r/m=001) ---
MOV AX, [BX + DI + 5]
MOV [BX + DI + 5], AX

; --- [BP + SI] (mod=00, r/m=010) ---
MOV AX, [BP + SI]
MOV [BP + SI], AX

; --- [BP + SI + disp8] (mod=01, r/m=010) ---
MOV AX, [BP + SI + 5]
MOV [BP + SI + 5], AX

; --- [BP + DI] (mod=00, r/m=011) ---
MOV AX, [BP + DI]
MOV [BP + DI], AX

; --- [BP + DI + disp8] (mod=01, r/m=011) ---
MOV AX, [BP + DI + 5]
MOV [BP + DI + 5], AX

; --- [BX + label] (mod=10, r/m=111, disp16=label) ---
MOV AX, [BX + data_word]
MOV [BX + data_word], AX

; --- BYTE/WORD overrides on memory ---
MOV BYTE [data_byte], 42
MOV WORD [data_word], 1000
INC WORD [data_word]
INC BYTE [data_byte]

; --- [SI + label] ---
MOV AX, [SI + data_word]

; --- [DI + label] ---
MOV AX, [DI + data_word]

; --- [BP + label] ---
MOV AX, [BP + data_word]

; --- [BX + SI + label] ---
MOV AX, [BX + SI + data_word]

; --- [BX + DI + label] ---
MOV AX, [BX + DI + data_word]

; --- [BP + SI + label] ---
MOV AX, [BP + SI + data_word]

; --- [BP + DI + label] ---
MOV AX, [BP + DI + data_word]

; Exit
INT 20h

; --- Data ---
data_word: DW 1234h
data_byte: DB 56h
