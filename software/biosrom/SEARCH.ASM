INCLUDE	OPTROM.INC
.386
CODE SEGMENT BYTE PUBLIC 'CODE' USE16

    ASSUME  CS:CODE,DS:CODE,ES:CODE


	ORG	81h
CMDLIN	LABEL	BYTE

	ORG	100h

START	PROC NEAR

;
; Display Title Message
;
	MOV	DX, OFFSET titleMsg
	MOV	AH, 9
	INT	21H
;
; Search Option ROM
;
	MOV	DX, 0C000h
tryROMSearch:
	MOV	ES, DX
    ASSUME  ES:NOTHING
	;
	; Check ROM ID
	;
	MOV	CX, 512/16
	CMP	WORD PTR ES:[0],0AA55h
	JNE	nextUMB		; Jump if not Option ROM ID

	;
	; Compare idntify string
	;
	MOV	CL, ES:[2]
	XOR	CH, CH
	SHL	CX, 9-4
	PUSH	CX
	MOV	DI, 18h+2
	MOV	SI, OFFSET searchMsg
	MOV	CX, sizeSearchMsg
	CLD
	REP	CMPS BYTE PTR DS:[SI],BYTE PTR ES:[DI]
	POP	CX
	JNE	nextUMB		; Jump if unmatch identify string

	MOV	[flag], 1
;
; Display Parameters
;
	PUSH	CX
	PUSH	DX
	;
	; Make ROM address string
	;
	MOV	DI, OFFSET romAdrsStr
	CALL	binToHex4

	;
	; Make Mode String
	;
	MOV	SI, ES:[18h]
	ADD	SI, ES:[SI].PCIR_LEN
	MOV	AL, '0'
	ADD	AL, ES:[SI]
	MOV	[modeStr], AL

	;
	; Make Address String
	;
	MOV	DX, ES:[SI+1]
	MOV	DI, OFFSET adrStr
	CALL	binToHex4

	;
	; Copy String
	;
	MOV	DI, OFFSET strStr
	ADD	SI, 3
	MOV	CX, 16
copyString:
	MOV	AL, ES:[SI]
	TEST	AL, AL
	JZ	endString
	MOV	[DI], AL
	INC	DI
	INC	SI
	LOOP	copyString
endString:
	MOV	BYTE PTR [DI], "'"
	MOV	WORD PTR [DI+1], 0A0Dh
	MOV	WORD PTR [DI+3], '$'

	MOV	DX, OFFSET paramMsg
	MOV	AH, 9
	INT	21h
	POP	DX
	POP	CX
nextUMB:
	ADD	DX, CX
	JC	exit		; Jump if over option ROM area
	CMP	DX, 0F000h
	JB	tryROMSearch	; Try next ROM area
exit:
	CMP	[flag], 0
	JNE	foundROM
	MOV	DX, OFFSET notFoundMsg
	MOV	AH, 9
	INT	21h
foundROM:
	RET

START	ENDP
;*********************************
;
; Convert to Hex string
;
;  Entry:
;	DX	Convert value
;	DS:DI	Convert string store address
;  Exit:
;	none
;  Modify:
;	AL, CX
;*********************************
binToHex4	PROC NEAR

	MOV	CX, 4
nextAdrs:
	ROL	DX, 4
	MOV	AL, DL
	AND	AL, 0Fh
	ADD	AL, '0'
	CMP	AL, 10+'0'
	JB	storeAdrs
	ADD	AL, 'A'-'0'-10
storeAdrs:
	MOV	[DI], AL
	INC	DI
	LOOP	nextAdrs
	RET

binToHex4	ENDP

flag		DB	0

titleMsg	DB	'PCI Option BIOS ROM Search ASM Program Ver1.0 by SUGAWARA',13,10,'$'

paramMsg	DB	'Option ROM Found',13,10
		DB	'  ROM Address = '
romAdrsStr	DB	'00000h',13,10
		DB	'  Parameters',13,10
		DB	'    Mode    = '
modeStr		DB	'0',13,10
		DB	'    Address = '
adrStr		DB	'0000h',13,10
		DB	"    Strings = '"
strStr		DB	"0123456789ABCDEF'",13,10,'$'

notFoundMsg	DB	'Not found option ROM',13,10,'$'

searchMsg	DB	'Option ROM Sample Program Image ( for PC/AT ROM )',0
sizeSearchMsg	= $ - searchMsg

CODE	ENDS
	END	START
