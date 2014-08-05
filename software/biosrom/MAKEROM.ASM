INCLUDE	OPTROM.INC
;**************************
;
;  ROMｲﾒｰｼﾞ出力
;
;**************************
CODE SEGMENT DWORD COMMON 'CODE'

    ASSUME  CS:CODE,DS:NOTHING,ES:NOTHING

        ORG 81h
CmdLin  LABEL BYTE

        ORG 100h
Main    PROC NEAR

;ｺﾏﾝﾄﾞﾗｲﾝ取得
;--------------------------
        CALL    GetCmdLin
        JC      ErrorUsage

;ﾒﾓﾘ確保
;---------------------------
        MOV     BX,2000H  ;本体(64KB)+ReadBuffer(32KB)+WriteBuffer(32KB)
        MOV     AH,4AH
        INT     21H
        STI
        JC      ErrorOutOfMemory
        MOV     AX,CS
        ADD     AX,1000h
        MOV     [ReadBuffSeg],AX
        ADD     AX,0800h
        MOV     [WriteBuffSeg],AX

;ﾌｧｲﾙを開く
;-------------------------------------
    ASSUME  DS:CODE
        MOV     DX,OFFSET ReadFileName
        MOV     AX,3D00H       ;Read
        INT     21H
        JC      ErrorOpenSource
        MOV     [ReadHandle],AX
        MOV     [PointerReadBuff],0
        MOV     [ReadBuffSize],0

        MOV     DX,OFFSET WriteFileName
        MOV     AH,3CH       ;Create
        XOR     CX,CX
        INT     21H
        JC      ErrorCreateDest
        MOV     [WriteHandle],AX
        MOV     [PointerWriteBuff],0

;ファイルサイズ取得
;-------------------------------------
        MOV     AX, 4202h
        MOV     BX, [ReadHandle]
        XOR     CX, CX
        XOR     DX, DX
        INT     21h

        MOV     WORD PTR [ROMImageSize],AX
        MOV     WORD PTR [ROMImageSize+2],DX

        MOV     AX, 4200h
        MOV     BX, [ReadHandle]
        XOR     CX, CX
        XOR     DX, DX
        INT     21h

;ROMイメージ読み込み
;-------------------------------------
        XOR     DL,DL

        ;Check EXE Header
        ;-------------------
        CALL    GetWord  ;Read EXE or ROM Signature
        JC      ErrorRead
        .IF AX == 'ZM'
            OR      [Flag], @WithExeHeader
            ;
            ; Skip EXE Header
            ;
            CALL    GetWord
            JC      ErrorRead
            CALL    GetWord
            JC      ErrorRead
            CALL    GetWord
            JC      ErrorRead
            CALL    GetWord
            JC      ErrorRead
            MOV     CL, 4
            SHL     AX, CL
            SUB     WORD PTR [ROMImageSize],AX
            SBB     WORD PTR [ROMImageSize+2],0
            MOV     CX, AX
            SUB     CX, 10
            JBE     ErrorInvalidEXE
            .REPEAT
                CALL    GetChar
                JC      ErrorRead
            .UNTILCXZ
            ;
            ;Read ROM Signature
            ;
            CALL    GetWord
            JC      ErrorRead
        .ENDIF
        SUB     DL, AL
        SUB     DL, AH
        CALL    PutWord
        JC      ErrorWrite

        ;Read ROM Size
        ;-----------------
        CALL    GetChar
        JC      ErrorRead
        MOV     AX, WORD PTR [ROMImageSize]
        MOV     BX, WORD PTR [ROMImageSize+2]
        ADD     AX, 1023 + 1   ; 1 is Checksum byte
        ADC     BX, 0
        AND     AX, NOT 1023
        PUSH    BX
        PUSH    AX

        SHR     BX, 1
        RCR     AX, 1
        MOV     AL, AH
        MOV     [ROMSize], AL
        SUB     DL, AL
        CALL    PutChar
        JC      ErrorWrite
        ;残りのROM Image Size計算
        ;-----------------
        MOV     BX, WORD PTR [ROMImageSize]
        MOV     CX, WORD PTR [ROMImageSize+2]
        SUB     BX, 3
        SBB     CX, 0

        ;PCIR構造体へのポインタまで、読み飛ばす
        ;------------------
        MOV     DH, 18h-3
        .REPEAT
            CALL    GetChar
            JC      ErrorRead

            SUB     BX, 1
            SBB     CX, 0
            SUB     DL, AL
            CALL    PutChar
            JC      ErrorWrite
            DEC     DH
        .UNTIL ZERO?

        ;PCIR構造体へのポインタ読み込み
        ;------------------
        CALL    GetWord
        JC      ErrorRead
        SUB     DL, AL
        SUB     DL, AH
        CALL    PutWord
        JC      ErrorWrite
        SUB     BX, 2
        SBB     CX, 0
        ;PCIR構造体がありそうだったら、そこまで読み飛ばす
        ;--------------------
        .IF (WORD PTR [ROMImageSize+2] != 0) || \
            (WORD PTR [ROMImageSize] > AX)
            SUB     AX, 18h+2          ;構造体ポインタまで読み込んだ分を引いて、構造体まで何バイト読むかの値にする
            .IF !CARRY
                MOV     SI, AX
                .REPEAT
                    CALL    GetChar
                    JC      ErrorRead

                    SUB     BX, 1
                    SBB     CX, 0
                    SUB     DL, AL
                    CALL    PutChar
                    JC      ErrorWrite
                    DEC     SI
                .UNTIL ZERO?
            .ENDIF
            ;PCIR構造体ヘッダ確認
            ;------------------------------
            CALL    GetWord
            JC      ErrorRead
            SUB     DL, AL
            SUB     DL, AH
            CALL    PutWord
            JC      ErrorWrite
            SUB     BX, 2
            SBB     CX, 0
            .IF AX == 'CP'
                CALL    GetWord
                JC      ErrorRead
                SUB     DL, AL
                SUB     DL, AH
                CALL    PutWord
                JC      ErrorWrite
                SUB     BX, 2
                SBB     CX, 0
                .IF AX == 'RI'
                    MOV     DH, PCIR_IMAGE_LEN - 4
                    .REPEAT
                        CALL    GetChar
                        JC      ErrorRead

                        SUB     BX, 1
                        SBB     CX, 0
                        SUB     DL, AL
                        CALL    PutChar
                        JC      ErrorWrite
                        DEC     DH
                    .UNTIL ZERO?
                    ;PCIR構造体ヘッダにROM長を書き込み
                    ;-------------------------
                    CALL    GetWord
                    JC      ErrorRead
                    XOR     AH, AH
                    MOV     AL, [ROMSize]
                    SUB     DL, AL
                    SUB     DL, AH
                    CALL    PutWord
                    JC      ErrorWrite
                    SUB     BX, 2
                    SBB     CX, 0
                .ENDIF
            .ENDIF
        .ENDIF
        ;残りのROM Imageを読み飛ばす
        ;--------------------------
        .REPEAT
            CALL    GetChar
            JC      ErrorRead

            SUB     DL, AL
            CALL    PutChar
            JC      ErrorWrite
            SUB     BX, 1
            SBB     CX, 0
        .UNTIL ZERO? && !(BX && BX)
        ;1024バイト単位に正規化
        ;--------------------------
        POP     BX
        POP     CX
        SUB     BX, WORD PTR [ROMImageSize]
        SBB     CX, WORD PTR [ROMImageSize+2]
        XOR     AL, AL
        .WHILE 1
            SUB     BX, 1
            SBB     CX, 0
            .BREAK .IF Carry?

            .IF !(BX & BX) && !(CX & CX)
                ;最後の1バイトにROM Check Sumを書き込む
                ;----------------------
                MOV     AL, DL
                CALL    PutChar
                JC      ErrorWrite
                .BREAK
            .ENDIF

            CALL    PutChar
            JC      ErrorWrite
        .ENDW
        CALL    FlushPutChar
        JC      ErrorWrite

;ﾌｧｲﾙを閉じる
;-------------------------------------
        MOV     BX,[ReadHandle]
        MOV     AH,3EH
        INT     21H
        MOV     BX,[WriteHandle]
        MOV     AH,3EH
        INT     21H

;正常終了ﾒｯｾｰｼﾞ表示
;---------------------------------------
        MOV     DX,OFFSET MsgComplete
        MOV     AH,9
        INT     21H

        MOV     AX,4C00H
        INT     21H

ErrorUsage:
        MOV     DX,OFFSET MsgUsage
        JMP     ErrorEnd

ErrorOutOfMemory:
        MOV     DX,OFFSET MsgErrorOutOfMemory
        JMP     ErrorEnd

ErrorInvalidEXE:
        MOV     DX,OFFSET MsgErrorInvalidEXE
        JMP     ErrorAllCloseEnd
ErrorWrite:
        MOV     DX,OFFSET MsgErrorWrite
        JMP     ErrorAllCloseEnd
ErrorRead:
        MOV     DX,OFFSET MsgErrorRead
        JMP     ErrorAllCloseEnd
ErrorCreateDest:
        MOV     DX,OFFSET MsgErrorCreateDest
        JMP     ErrorCloseEnd
ErrorOpenSource:
        MOV     DX,OFFSET MsgErrorOpenSource
        JMP     ErrorCloseEnd
ErrorAllCloseEnd:
        MOV     BX, [WriteHandle]
        MOV     AH,3Eh
        INT     21h
ErrorCloseEnd:
        MOV     BX, [ReadHandle]
        MOV     AH,3Eh
        INT     21h
ErrorEnd:
        MOV     AH,9
        INT     21H
        MOV     AX,4CFFH
        INT     21H

Main    ENDP
;********************************************************
;	1 Byte読み込み
;
;	INPUT	None
;	OUTPUT  AL  読み込みデータ
;               CY     0)読み込めた   1)読み込めない
;	BREAK	None
;
;********************************************************
GetChar PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        PUSH    DS
        PUSH    BX
        MOV     DS,[ReadBuffSeg]
    ASSUME  DS:NOTHING
        MOV     BX,[ReadBuffSize]
        .IF !(BX & BX)
            PUSH    AX
            PUSH    CX
            PUSH    DX
            MOV     AH, 3Fh
            MOV     BX, [ReadHandle]
            MOV     CX, 8000h
            XOR     DX, DX
            INT     21h
            POP     DX
            POP     CX
            POP     AX
            MOV     [ReadBuffSize], AX
            MOV     [PointerReadBuff], 0
            JC      ExitGetChar    ; Jump if error occure
        .ENDIF
        MOV     BX, [PointerReadBuff]
        MOV     AL, [BX]
        INC     BX
        MOV     [PointerReadBuff], BX
        DEC     [ReadBuffSize]

ExitGetChar:
        POP     BX
        POP     DS
    ASSUME  DS:CODE
        RET

GetChar ENDP

;********************************************************
;	1 Word読み込み
;
;	INPUT	None
;	OUTPUT  AX  読み込みデータ
;               CY     0)読み込めた   1)読み込めない
;	BREAK	None
;
;********************************************************
GetWord PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        CALL    GetChar
        .IF !Carry?
            MOV     AH, AL
            CALL    GetChar
            XCHG    AL, AH
        .ENDIF
        RET

GetWord ENDP

;********************************************************
;	1 Byte書き込み
;
;	INPUT   AL  書き込みデータ
;	OUTPUT  CY     0)書き込めた   1)書き込めない
;	BREAK	None
;
;********************************************************
PutChar PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        PUSH    DS
        PUSH    BX
        MOV     DS,[WriteBuffSeg]
    ASSUME  DS:NOTHING
        MOV     BX,[PointerWriteBuff]
        .IF BX == 8000h
            PUSH    AX
            PUSH    CX
            PUSH    DX
            MOV     AH, 40h
            MOV     BX, [WriteHandle]
            MOV     CX, 8000h
            XOR     DX, DX
            INT     21h
            MOV     BX, AX
            POP     DX
            POP     CX
            POP     AX
            MOV     [PointerWriteBuff], 0
            JC      @@ExitPutChar    ; Jump if error occure
            CMP     BX, 8000h
            STC
            JNE     @@ExitPutChar
        .ENDIF
        MOV     BX, [PointerWriteBuff]
        MOV     [BX], AL
        INC     BX
        MOV     [PointerWriteBuff], BX
        CLC

@@ExitPutChar:
        POP     BX
        POP     DS
    ASSUME  DS:CODE
        RET

PutChar ENDP

;********************************************************
;	1 Word書き込み
;
;	INPUT	AX  書き込みデータ
;	OUTPUT  CY     0)書き込めた   1)書き込めない
;	BREAK	None
;
;********************************************************
PutWord PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        CALL    PutChar
        .IF !Carry?
            XCHG     AL, AH
            CALL    PutChar
            XCHG     AL, AH
        .ENDIF
        RET

PutWord ENDP

;********************************************************
;	書き込みﾊﾞｯﾌｧﾌﾗｯｼｭ
;
;	INPUT   None
;	OUTPUT  CY     0)書き込めた   1)書き込めない
;	BREAK	None
;
;********************************************************
FlushPutChar PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        PUSH    DS
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     DS,[WriteBuffSeg]
    ASSUME  DS:NOTHING
        MOV     AH, 40h
        MOV     BX, [WriteHandle]
        MOV     CX, [PointerWriteBuff]
        XOR     DX, DX
        INT     21h
        MOV     [PointerWriteBuff], 0
        JC      @@ExitFlushPutChar    ; Jump if error occure
        CMP     AX, CX
        STC
        JNE     @@ExitFlushPutChar
        CLC

@@ExitFlushPutChar:
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POP     DS
    ASSUME  DS:CODE
        RET

FlushPutChar ENDP

;********************************************************
;	ｺﾏﾝﾄﾞﾗｲﾝ ﾊﾟﾗﾒｰﾀ取得
;
;	INPUT	なし
;	OUTPUT  CY     0)正常   1)正しいﾊﾟﾗﾒｰﾀではない
;	BREAK	AX,BX,CX,EDX
;
;********************************************************
GetCmdLin PROC NEAR

    ASSUME  DS:CODE,ES:CODE

        MOV     SI,OFFSET CmdLin
@@ArgLoop:
        CALL    GetArgument
        JCXZ    @@GetCmdLinEnd

        CMP     BYTE PTR [SI],'/'
        JE      @@GetOption

        INC     [ArgNum]
        CMP     [ArgNum], 2
        JA      @@ArgUsage
;
; ファイル名取得
;
        MOV     DI,OFFSET ReadFileName
        .IF [ArgNum] == 2
            MOV     DI,OFFSET WriteFileName
        .ENDIF
        CLD
        REP     MOVSB
        MOV     BYTE PTR [DI],0
        JMP     @@ArgLoop

@@GetOption:
        INC     SI
        DEC     CX
        JZ      @@ArgUsage
        MOV     AL,[SI]
        ADD     SI,CX
        AND     AL,0DFH
        JMP     @@ArgUsage
        JMP     @@ArgLoop

@@GetCmdLinEnd:

        CLC
        RET

@@ArgUsage:
        STC
        RET

GetCmdLin ENDP
;***********************************************
;
;	ｺﾏﾝﾄﾞﾗｲﾝﾊﾟﾗﾒｰﾀ取得
;
;	入力	SI	ｺﾏﾝﾄﾞﾗｲﾝ取得開始ｱﾄﾞﾚｽ
;	出力	CX	0)取得出来ず
;			≠0)ﾊﾟﾗﾒｰﾀの文字数
;		SI	ﾊﾟﾗﾒｰﾀ開始ｱﾄﾞﾚｽ
;	破壊	AL
;***********************************************
GetArgument	PROC	NEAR

    ASSUME  DS:CODE,ES:CODE

	XOR	CX,CX

;ﾊﾟﾗﾒｰﾀの前の空白文字を読み飛ばす
;-----------------------
        .REPEAT
            LODSB
            CMP     AL,0DH
            JE      @@GetArgEnd
        .UNTIL (AL!=' ') && (AL!=9)

;ﾊﾟﾗﾒｰﾀの文字数取得
;-------------------------
	DEC	SI
	PUSH	SI
        .REPEAT
            LODSB
            .BREAK .IF AL == 0DH
            .BREAK .IF AL == ' '
        .UNTILCXZ (AL==9)
	NEG	CX
	POP	SI
@@GetArgEnd:
	RET

GetArgument	ENDP

MsgComplete      DB 'Success',13,10,'$'
MsgErrorOpenSource DB "Could not open source file",13,10,'$'
MsgErrorCreateDest DB "Could not create ROM image file",13,10,'$'
MsgErrorWrite    DB 'File Write Error',13,10,'$'
MsgErrorRead     DB 'File Read Error',13,10,'$'
MsgErrorOutOfMemory DB 'Memory Allocation Error',13,10,'$'
MsgErrorInvalidEXE  DB 'ROM Image file is invalied EXE file',13,10,'$'

MsgUsage        DB      'Make ROM Image from EXE file V1.00 1999/4/9 by OSHOW',13,10
                DB      'Usage MAKEROM [EXEFileName] [ROMFileName]',13,10
                DB      '  [EXEFileName]',13,10
                DB      '      ROM Image file with EXE Header',13,10
                DB      '  [ROMFileName]',13,10
                DB      '      ROM Image file',13,10
                DB      'function',13,10
                DB      '  Remove EXE Header',13,10
                DB      '  Set ROM Size to ROM Header',13,10
                DB      '  Set ROM CheckSum',13,10
                DB      '$'

ArgNum          DB 0
Flag            DB 0
@WithExeHeader EQU 1 SHL 0
ReadBuffSeg     DW ?
WriteBuffSeg    DW ?
PointerReadBuff DW ?
PointerWriteBuff DW ?
ReadBuffSize    DW ?
ReadHandle      DW ?
WriteHandle     DW ?
ROMImageSize    DD ?
ROMSize         DB ?
ReadFileName    DB 128+1 DUP(?)
WriteFileName   DB 128+1 DUP(?)

CODE  ENDS
      END   MAIN
