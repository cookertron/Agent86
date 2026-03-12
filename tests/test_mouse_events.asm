; test_mouse_events.asm — Test unified mouse + keyboard sequential event stream
;
; Events: [keys:"A", mouse:{buttons:1,x:80,y:40}, keys:"B", mouse:{buttons:0,x:160,y:80}, keys:"C"]
;
; Mouse events are lazy barriers — only applied when INT 33h AX=0003h is called.
;
; Init: inject "A", cursor stops at mouse1 (barrier)
; Consume "A": advanceSequential → still stopped at mouse1
; INT 33h AX=3: apply mouse1{1,80,40}, advance → inject "B", stop at mouse2
; Consume "B": advanceSequential → still stopped at mouse2
; INT 33h AX=3: apply mouse2{0,160,80}, advance → inject "C"
; Consume "C": done
;
; Run: agent86 tests/test_mouse_events.asm --build_trace --events '[{"keys":"A"},{"mouse":{"buttons":1,"x":80,"y":40}},{"keys":"B"},{"mouse":{"buttons":0,"x":160,"y":80}},{"keys":"C"}]'
ORG 0x100

    ; Reset mouse driver
    XOR AX, AX
    INT 33h
    ASSERT_EQ AX, 0FFFFh     ; driver present

    ; Mouse not yet queried — should still be at reset defaults (0,0,0)
    ; (mouse1 is a barrier, not yet applied)

    ; --- Consume "A" ---
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 01E41h     ; 'A' scancode=0x1E ascii=0x41

    ; Query mouse — triggers mouse1{1,80,40}, then injects "B"
    MOV AX, 0003h
    INT 33h
    ASSERT_EQ BX, 1           ; left button (mouse1)
    ASSERT_EQ CX, 80          ; x=80 (mouse1)
    ASSERT_EQ DX, 40          ; y=40 (mouse1)

    ; --- Consume "B" ---
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 03042h     ; 'B' scancode=0x30 ascii=0x42

    ; Query mouse — triggers mouse2{0,160,80}, then injects "C"
    MOV AX, 0003h
    INT 33h
    ASSERT_EQ BX, 0           ; no buttons (mouse2)
    ASSERT_EQ CX, 160         ; x=160 (mouse2)
    ASSERT_EQ DX, 80          ; y=80 (mouse2)

    ; --- Consume "C" ---
    MOV AH, 00h
    INT 16h
    ASSERT_EQ AX, 02E43h     ; 'C' scancode=0x2E ascii=0x43

    ; Mouse state unchanged (no more events)
    MOV AX, 0003h
    INT 33h
    ASSERT_EQ CX, 160
    ASSERT_EQ DX, 80

    HLT
