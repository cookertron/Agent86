; Test file for newly added instructions
; Exercises: segment regs, XCHG, IN/OUT, LDS/LES, string ops,
;            flag ops, BCD, indirect JMP/CALL, RET imm, shifts on memory, etc.

ORG 100h

start:
    ; === Segment register MOV ===
    MOV AX, DS          ; 8C D8
    MOV ES, AX          ; 8E C0
    MOV SS, BX          ; 8E D3

    ; === PUSH/POP segment registers ===
    PUSH ES             ; 06
    PUSH CS             ; 0E
    PUSH SS             ; 16
    PUSH DS             ; 1E
    POP ES              ; 07
    POP SS              ; 17
    POP DS              ; 1F

    ; === XCHG ===
    XCHG AX, BX         ; 93
    XCHG CX, AX         ; 91
    XCHG DX, BX         ; 87 D3
    XCHG AL, BL         ; 86 C3

    ; === Flag instructions ===
    CLC                 ; F8
    STC                 ; F9
    CLI                 ; FA
    STI                 ; FB
    CLD                 ; FC
    STD                 ; FD
    CMC                 ; F5
    LAHF                ; 9F
    SAHF                ; 9E
    PUSHF               ; 9C
    POPF                ; 9D

    ; === BCD ===
    DAA                 ; 27
    DAS                 ; 2F
    AAA                 ; 37
    AAS                 ; 3F
    AAM                 ; D4 0A
    AAD                 ; D5 0A

    ; === Misc single-byte ===
    NOP                 ; 90
    HLT                 ; F4
    WAIT                ; 9B
    CBW                 ; 98
    CWD                 ; 99
    INTO                ; CE
    XLAT                ; D7
    IRET                ; CF

    ; === INT 3 special case ===
    INT 3               ; CC
    INT 21h             ; CD 21

    ; === RET with operand ===
    RET 4               ; C2 04 00

    ; === String operations ===
    MOVSB               ; A4
    MOVSW               ; A5
    STOSB               ; AA
    STOSW               ; AB
    LODSB               ; AC
    LODSW               ; AD
    CMPSB               ; A6
    CMPSW               ; A7
    SCASB               ; AE
    SCASW               ; AF

    ; === REP prefixed string ops ===
    REP MOVSB           ; F3 A4
    REP STOSW           ; F3 AB
    REPE CMPSB          ; F3 A6
    REPNE SCASB         ; F2 AE

    ; === IN/OUT ===
    IN AL, 60h          ; E4 60
    IN AX, 60h          ; E5 60
    OUT 61h, AL         ; E6 61
    OUT 61h, AX         ; E7 61
    IN AL, DX           ; EC
    IN AX, DX           ; ED
    OUT DX, AL          ; EE
    OUT DX, AX          ; EF

    ; === New shift/rotate variants ===
    RCL AX, 1           ; D1 D0
    RCR BX, 1           ; D1 DB
    SAR CX, 1           ; D1 F9
    RCL AL, CL          ; D2 D0
    RCR BL, CL          ; D2 DB
    SAR DL, CL          ; D2 FA

    ; === IMUL/IDIV ===
    IMUL BX              ; F7 EB
    IDIV CX              ; F7 F9

    ; === Indirect JMP/CALL ===
    JMP BX               ; FF E3
    CALL SI              ; FF D6

    ; === LOCK prefix ===
    LOCK                 ; F0

    ; End with INT 20h
    INT 20h              ; CD 20
