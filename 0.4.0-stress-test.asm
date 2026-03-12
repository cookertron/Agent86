ORG 100h

; --- STRESS 1: The Hex Parsing Trap ---
; The lexer checks isdigit() to start parsing a number.
; 0ABCDh starts with '0', so it parses correctly as a number.
; ABCDh starts with 'A', so readIdentifier() grabs it and marks it as a symbol.
; Uncommenting the second line will likely cause an "unresolved symbol" error.
MOV AX, 0ABCDh
; MOV AX, ABCDh      

; --- STRESS 2: The Silent Invalid Register Flaw ---
; Your parseMemoryOperand function only checks for BX, BP, SI, DI.
; It treats CX as a displacement token. evalExpr will fail to evaluate it,
; default to 0, and silently compile this as MOV DX, [0] instead of erroring.
MOV DX, [CX]
MOV SI, [BX + BP] ; Will likely compile silently as [BX+0]

; --- STRESS 3: The [BP] ModR/M Exception ---
; Encoder::encodeMemOperand has special logic for [BP] without displacement.
; It must encode as [BP+0] (mod=01, rm=110), otherwise mod=00 rm=110 means [disp16].
MOV CX, [BP]

; --- STRESS 4: Pessimistic Jump Padding ---
; Encoder::estimateSize assumes 5 bytes for this conditional jump.
; In pass 2, it calculates a short relative distance and emits 2 bytes.
; It should pad the remaining 3 bytes with NOPs (0x90) to keep addresses stable.
CMP AX, 0
JZ  .skip_ahead
ADD AX, 1
.skip_ahead:

; --- STRESS 5: Complex Displacement Arithmetic ---
; Stresses evalExpr and parseAddSub/parseMulDiv to ensure operator precedence 
; and forward reference tracking works within brackets.
MOV DI, [BX + SI + DATA_VAL - 10h]

; --- STRESS 6: Sign-Extended ALU Operations ---
; Encoder::encodeALU checks if the immediate fits in a signed byte (-128 to 127).
; The first should use the 83h opcode (sign-extended byte), the second 81h (full word).
ADD AX, -5
ADD AX, 1000h

; --- STRESS 7: Local Label Scope Tracking ---
; Verifies SymbolTable::qualify correctly prepends the global scope.
MainLoop:
    DEC CX
    JNZ .local_target 
    JMP exit
.local_target:
    NOP
    JMP MainLoop

exit:
    RET

; --- STRESS 8: Forward EQU Resolution ---
; Evaluates if pass 2 correctly resolves EQU directives that were undefined in pass 1.
DATA_VAL EQU 20h
FORWARD_EQU EQU 1234h