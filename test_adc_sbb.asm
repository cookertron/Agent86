; Test ADC and SBB instructions
ORG 100h

; Test ADC (Add with Carry)
; 0xFF + 0x01 = 0x100 (sets carry)
; 0x00 + 0x00 + carry = 0x01
MOV AL, 0FFh
ADD AL, 01h      ; AL = 0x00, CF = 1
MOV AH, 00h
ADC AH, 00h      ; AH = 0x01 (adds carry flag)

; Test SBB (Subtract with Borrow)
; Clear carry, then subtract with borrow
CLC              ; Clear carry
MOV BL, 05h
SBB BL, 02h      ; BL = 0x03 (5 - 2 - 0)

STC              ; Set carry
MOV CL, 05h
SBB CL, 02h      ; CL = 0x02 (5 - 2 - 1)

; Test ADC with immediate on register
MOV DL, 10h
STC
ADC DL, 05h      ; DL = 0x16 (10h + 5h + 1)

; Test SBB with immediate on register
MOV DH, 20h
CLC
SBB DH, 08h      ; DH = 0x18 (20h - 8h - 0)

; Exit
INT 20h
