ORG 100h
MOV AH, 9
MOV DX, msg
INT 21h
INT 20h
msg:
DB 'Hello!', '$'
