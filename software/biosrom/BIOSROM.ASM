INCLUDE OPTROM.INC
;***********************************************
;
;x86 PC/AT互換機用 PCI拡張ROMサンプルプログラム
;
;***********************************************
CODE1 SEGMENT PAGE COMMON 'CODE1'
.386p

    ASSUME  CS:CODE1,DS:NOTHING,ES:NOTHING

;***************************************
;PCIボード拡張ROM ヘッダ記述部
;***************************************
strROMData CATSTR <'PCIBoard OptionROM'>     ;デバイス固有領域(最大18バイト)
strROMName CATSTR <'Option ROM Sample Program Image ( for PC/AT ROM )',0> ;PCIボード名/拡張ROMバージョンなど
pcirVendorID = 3776h
pcirDeviceID = 8000h
pcirVPD      = 0000h
pcirClassBase = 00h
pcirClassSub  = 00h
pcirClassProg = 00h
pcirRevLvl    = 0000h
pcirCode      = 00h
pcirID        = 00h
initCodeLabel CATSTR <postCode>

        ROM_HEADER

MODE   DB      1
ADR    DW      0012h
STRS   DB      'IPV4/UDP        '

;*************************************************************************
;
;x86 PC/AT互換機用 PCI拡張ROMプログラム本体 開始
;
;**************************************************************************
;***************************
;
; 初期化コード
;
;***************************
postCode PROC FAR

        PUSH    CS
        POP     DS
    ASSUME  DS:CODE1

        MOV     SI,OFFSET TitleMsg
        CALL    dispTTY
;
; n秒間キー入力待ち
;
        MOV     DX,8
wait1s:
        MOV     CX,33333    ;33333*(15*2)us = 1s
wait15us1:
        IN      AL,61h
        TEST    AL,10h
        JZ      wait15us1
wait15us2:
        IN      AL,61h
        TEST    AL,10h
        JNZ     wait15us2

        MOV     AH,1
        INT     16h
        JNZ     getKey

        LOOP    wait15us1
        DEC     DX
        JNZ     wait1s
        JMP     exit
getKey:
        MOV     AH,0
        INT     16H
        CMP     AX,2C00H
        JNE     exit

        CALL    menu

exit:

;
; 初期化コード部をROM SIZEから削る
;
RET ; 削らない
        MOV     CX, OFFSET postCode+1
        ADD     CX, 511 ;1023
        SHR     CX, 9
        MOV     [ROM_SIZE], CL
        MOV     BYTE PTR [postCode], 0CBH ;RETF

        SHL     CX, 9
        DEC     CX
        XOR     AL, AL
        XOR     SI, SI
calcChkSumLoop:
        SUB     AL, [SI]
        INC     SI
        LOOP    calcChkSumLoop

        MOV     [SI], AL


;        MOV     AX,4C00H
;        INT     21H
        RET

postCode ENDP

;***************************
;
; Menu表示
;
;***************************
menu PROC NEAR

        MOV     AH,03H
        XOR     BH,BH
        INT     10H
        MOV     [cursorShape],CX
;
; Copy initial item value
;
        MOV     AL, [MODE]
        MOV     [curMode], AL

        MOV     AX, [ADR]
        MOV     [curAdrs], AX

        MOV     CX, 16
        MOV     SI, OFFSET STRS
        MOV     DI, OFFSET curStr
copyInitialStr:
        MOV     AL, [SI]
        MOV     [DI], AL
        INC     SI
        INC     DI
        LOOP    copyInitialStr
;
; Hide cursor shape
;
redispScreen:
        CALL    clearCursor
;
; Display Menu
;
        CALL    clearScreen
        MOV     BL, 07H
        XOR     DX, DX
        MOV     SI, OFFSET MenuTitleMsg
        CALL    dispMsg
        MOV     DX, 24 SHL 8
        MOV     SI, OFFSET MenuKeyMsg
        CALL    dispMsg

;
; Display Items
;
allItemDisp:
        MOV     DH, 02h
        MOV     DI, OFFSET ItemTable
itemDispLoop:
        MOV     DL, 1
        MOV     SI, [DI].ItemMsg
        TEST    SI, SI
        JZ      endOfItem

        MOV     BL, 07h
        MOV     AL, DH
        SUB     AL, 02h
        CMP     [curItemNum], AL
        JNE     itemMsgDisp
        MOV     BL, 70h
itemMsgDisp:
        CALL    dispMsg
        INC	SI
        MOV     BL, 07h
        CALL    dispMsg
        MOV     AL, ' '
        MOV     CX, 21
        SUB     CL, DL
        CALL    dispChar


        MOV     SI, OFFSET strBuf
        CALL    CS:[DI].ItemDisp
        MOV     DL, 21
        MOV     SI, OFFSET strBuf
        CALL    dispMsg

        ADD     DI, SIZE ItemInfo
        INC     DH
        JMP     itemDispLoop

endOfItem:
;
; Check keyin
;
keyInLoop:
        MOV     AH,0
        INT     16H
        CMP     AH,48h
        JE      upItem
        CMP     AH,50h
        JE      downItem
        CMP     AH,1Ch
        JE      selectItem
        JMP     keyInLoop

upItem:
        DEC     [curItemNum]
        JNS     allItemDisp
        MOV     [curItemNum], MAX_ITEM_NUM - 1
        JMP     allItemDisp
downItem:
        INC     [curItemNum]
        CMP     [curItemNum], MAX_ITEM_NUM
        JB      allItemDisp
        MOV     [curItemNum], 0
        JMP     allItemDisp

;
; Change Item value
;
selectItem:
        MOV     AL,[curItemNum]
        MOV     AH,SIZE itemInfo
        MUL     AH
        MOV     DI, OFFSET itemTable
        ADD     DI, AX
	MOV	SI, CS:[DI].ItemMsg
        MOV     DX, 02h SHL 8 OR 1
        ADD     DH,[curItemNum]
        MOV     BL, 07H
	CALL	dispMsg

        MOV     SI, OFFSET strBuf
        CALL    CS:[DI].ItemDisp
        MOV     SI, OFFSET strBuf
        MOV     DL, 21
        PUSH    DI
        CALL    CS:[DI].ItemEdit
        CALL    clearCursor
        POP     DI
        CMP     AH,-1
        JE      quitMenu
        CMP     AH,1CH
        JNE     allItemDisp

        MOV     SI, OFFSET strBuf
        CALL    CS:[DI].ItemUpdate
        JMP     allItemDisp
;
; Select Quit Mode
;
quitMenu:
        MOV     BL, 70H
        MOV     DX, 20 SHL 8 OR 5
        MOV     SI, OFFSET QuitMsg
        CALL    dispMsg
        MOV     BL, 07H
        MOV     DX, 24 SHL 8
        MOV     SI, OFFSET QuitKeyMsg
        CALL    dispMsg
quitMenuKeyin:
        MOV     AH, 0
        INT     16H
        CMP     AH, 01H
        JE      redispScreen

        AND     AL, NOT 20h
        CMP     AL, 'Y'
        JE      saveExit
        CMP     AL, 'N'
        JNE     quitMenuKeyin
;
; Reset Screen & Exit Option ROM
;
exitROM:
        MOV     AH, 0FH
        INT     10H
        AND     AX, 007FH
        INT     10H
        RET
;
; Save changed parameters and exit
;
saveExit:

;
; Save item values
;
        MOV     AL, [curMode]
        MOV     [MODE], AL

        MOV     AX, [curAdrs]
        MOV     [ADR], AX

        MOV     CX, 16
        MOV     SI, OFFSET curStr
        MOV     DI, OFFSET STRS
saveCurStr:
        MOV     AL, [SI]
        MOV     [DI], AL
        INC     SI
        INC     DI
        LOOP    saveCurStr

        JMP     exitROM

        DB      0EAh
        DW      0FFF0h
        DW      0F000h

menu ENDP

;**************************
; 1ﾗｲﾝ入力
;**************************
enter1Line PROC NEAR

	CALL    resetCursor
        MOV     DI,SI
        PUSH    SI
        PUSH    DX
        CALL    dispMsg
        POP     DX
        POP     SI
enter1LineLoop:
        XOR     BH,BH
        MOV     AH,02H
        INT     10H

        MOV     AH,0
        INT     16H

        CMP     AL,8
        JE      @@BkSp
        CMP     AH,01H
        JE      @@RET
;        CMP     AH,0FH
;        JE      @@RET
        CMP     AH,1CH
        JE      @@RET
        CMP     AX,5000H
        JE      @@RET
        CMP     AX,4700H
        JE      @@Home
        CMP     AX,4800H
        JE      @@RET
        CMP     AX,4B00H
        JE      @@Left
        CMP     AX,4D00H
        JE      @@Right
        CMP     AX,4F00H
        JE      @@End
        CMP     AX,5200H
        JE      enter1LineLoop ;Insert
        CMP     AX,5300H
        JE      @@Del

        CMP     AL,' '
        JB      enter1LineLoop

        CMP     [enterMode],@ENTER_STR
        JE      @@PutChar

        CMP     AL,'0'
        JB      enter1LineLoop
        CMP     AL,'9'
        JBE     @@PutChar

        CMP     [enterMode],@ENTER_NUM
        JE      enter1LineLoop

        AND     AL,0DFH
        CMP     AL,'A'
        JB      enter1LineLoop
        CMP     AL,'F'
        JA      enter1LineLoop

;入力文字書き込み
;-----------------------
@@PutChar:
    ;挿入ﾓｰﾄﾞかどうかﾁｪｯｸ
    ;-----------------------
        PUSH    DS
        PUSH    AX
        XOR     AX, AX
        MOV     DS, AX
        TEST    BYTE PTR DS:[417H],1 SHL 7
        POP     AX
        POP     DS
        JZ      @@OVER
      ;挿入ﾓｰﾄﾞである
      ;--------------------------
        ;文字列最終ｱﾄﾞﾚｽ取得
        ;-----------------------
        CALL    @@GetLastAdrs
        PUSH    SI
@@InsLoop:
        CMP     SI,CX
        JAE     @@CantIns      ;これ以上入らない
        MOV     AH,[SI]
        INC     SI
        TEST    AH,AH
        JNZ     @@InsLoop
        CMP     SI,CX
        JAE     @@CantIns      ;これ以上入らない

        ;一文字挿入する分、移動する
        ;--------------------------
        POP     CX
@@InsLoop2:
        MOV     AH,[SI-1]
        MOV     [SI],AH
        DEC     SI
        CMP     SI,CX
        JA      @@InsLoop2

        MOV     [SI],AL
        PUSH    DX
        PUSH    SI
        CALL    dispMsg
        POP     SI
        POP     DX
        INC     SI
        INC     DL
        JMP     enter1LineLoop

@@CantIns:
        POP     SI
        JMP     enter1LineLoop

      ;上書きﾓｰﾄﾞである
      ;--------------------------
@@OVER:
        CALL    @@GetLastAdrs
        CMP     SI,CX
        JAE     enter1LineLoop

        MOV     AH,[SI]
        MOV     [SI],AL
        INC     SI
        TEST    AH,AH
        JNZ     @@DISP_INPUT_CHAR
        MOV     [SI],AH
@@DISP_INPUT_CHAR:
        MOV     CX,1
        CALL    dispChar
        INC     DL
        JMP     enter1LineLoop
@@RET:
        RET

@@Right:
        CMP     BYTE PTR [SI],0
        JE      enter1LineLoop
        INC     DL
        INC     SI
        JMP     enter1LineLoop

@@Left:
        CMP     SI,DI
        JE      enter1LineLoop
        DEC     DL
        DEC     SI
        JMP     enter1LineLoop


@@Del:
        CMP     BYTE PTR [SI],0
        JE      enter1LineLoop
        PUSH    SI
@@DelLoop:
        MOV     AL,[SI+1]
        MOV     [SI],AL
        INC     SI
        TEST    AL,AL
        JNZ     @@DelLoop
        POP     SI
        JMP     @@DispLastSpace


@@BkSp:
        CMP     SI,DI
        JE      enter1LineLoop

        PUSH    SI
@@BkSpLoop:
        MOV     AL,[SI]
        MOV     [SI-1],AL
        INC     SI
        TEST    AL,AL
        JNZ     @@BkSpLoop
        POP     SI

        DEC     SI
        DEC     DL
@@DispLastSpace:
        PUSH    SI
        PUSH    DX
        CALL    dispMsg
        MOV     AL,' '
        MOV     CX,1
        CALL    dispChar
        POP     DX
        POP     SI
        JMP     enter1LineLoop

@@Home:
        MOV     AX,SI
        SUB     AX,DI
        SUB     DL,AL
        MOV     SI,DI
        JMP     enter1LineLoop

@@End:
        CMP     BYTE PTR [SI], 0
        JE      enter1LineLoop
        INC     DL
        INC     SI
        JMP     @@End

@@GetLastAdrs:

        MOV     CX,[enterLen]
        ADD     CX,DI
;        INC     CX
        RET

enter1Line ENDP

;***************************
;
; mode値取得
;
;***************************
modeDisp PROC NEAR

        MOV     AL, [curMode]
        ADD     AL, '0'
        XOR     AH,AH
        MOV     [SI], AX
        RET

modeDisp ENDP
;***************************
;
; mode値編集
;
;***************************
modeEdit PROC NEAR

        MOV     [enterMode], @ENTER_NUM
        MOV     [enterLen],1
        CALL    enter1Line
        RET

modeEdit ENDP

;***************************
;
; mode値更新
;
;***************************
modeUpdate PROC NEAR

        MOV     AL, [SI]
        TEST    AL, AL
        JZ      modeUpdateSkip
        SUB     AL, '0'
        MOV     [curMode], AL
modeUpdateSkip:
        RET

modeUpdate ENDP


;***************************
;
; address値取得
;
;***************************
adrsDisp PROC NEAR

        PUSH    DX
        MOV     DX, [curAdrs]
        CALL    adrsDispConvHex
        CALL    adrsDispConvHex
        CALL    adrsDispConvHex
        CALL    adrsDispConvHex
;        MOV     WORD PTR [SI], 'H'
;        INC     SI
        MOV     BYTE PTR [SI], 0
        POP     DX
        RET

adrsDispConvHex:
        MOV     AL, DH
        SHR     AL, 4
        SHL     DX, 4
        ADD     AL, '0'
        CMP     AL, '0'+10
        JB      adrsDispStore
        ADD     AL, 'A'-'0'-10
adrsDispStore:
        MOV     [SI], AL
        INC     SI
        RET

adrsDisp ENDP
;***************************
;
; address値編集
;
;***************************
adrsEdit PROC NEAR

        MOV     [enterMode], @ENTER_HEX
        MOV     [enterLen],4
        CALL    enter1Line
        RET

adrsEdit ENDP

;***************************
;
; address値更新
;
;***************************
adrsUpdate PROC NEAR

        CMP     BYTE PTR [SI], 0
        JZ      adrsUpdateSkip

        XOR     DX, DX
adrsUpdateLoop:
        MOV     AL, [SI]
        INC     SI
        TEST    AL, AL
        JZ      adrsUpdateEnd
adrsUpdateHex:
        SUB     AL, '0'
        CMP     AL, 10
        JB      adrsUpdateHexStore
        SUB     AL, 'A'-'0'-10
        CMP     AL, 16
        JB      adrsUpdateHexStore
        SUB     AL, 'a'-'A'
adrsUpdateHexStore:
        SHL     DX, 4
        OR      DL, AL
        JMP     adrsUpdateLoop
adrsUpdateEnd:

        MOV     [curAdrs], DX

adrsUpdateSkip:
        RET

adrsUpdate ENDP


;***************************
;
; string値表示
;
;***************************
strDisp PROC NEAR

        PUSH    DI
        MOV     DI, OFFSET curStr
        MOV     CX, 16
strEditLoop:
        MOV     AL, [DI]
        MOV     [SI], AL
        INC     DI
        INC     SI
        LOOP    strEditLoop

        POP     DI
        RET
strDisp ENDP
;***************************
;
; string値編集
;
;***************************
strEdit PROC NEAR

        MOV     [enterMode], @ENTER_STR
        MOV     [enterLen],16
        CALL    enter1Line

        RET

strEdit ENDP
;***************************
;
; string値更新
;
;***************************
strUpdate PROC NEAR

        PUSH    DI
        MOV     DI, OFFSET curStr
        MOV     CX, 16
strUpdateLoop:
        MOV     AL, [SI]
        MOV     [DI], AL
        INC     DI
        INC     SI
        LOOP    strUpdateLoop

        POP     DI
        RET

strUpdate ENDP

;***************************
;
; string値表示
;
;***************************
exitDisp PROC NEAR

        MOV     BYTE PTR [SI], 0
        INC     SI
        RET

exitDisp ENDP
;***************************
;
; string値編集
;
;***************************
exitEdit PROC NEAR

        MOV     AH, -1
        RET

exitEdit ENDP
;***************************
;
; exit値更新(Dummy)
;
;***************************
exitUpdate PROC NEAR

        RET

exitUpdate ENDP

;**************************
;
;  文字列表示
;
;  入力  CS:SI  文字列のアドレス
;        BL   文字の属性
;  出力  なし
;  破壊  SI
;**************************
clearScreen PROC NEAR

        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        XOR     AX,AX
        MOV     DS,AX
        MOV     DL,DS:[44AH]
        MOV     DH,DS:[484H]
        DEC     DX

        MOV     AX,0600H
        MOV     BH,07H
        MOV     CX,0
        INT     10H

        POP     DS
        POP     DX
        POP     CX
        POP     BX
        POP     AX

        RET

clearScreen ENDP

;**************************
;文字列表示
;
;       入力    CS:SI    メッセージアドレス
;               BL    アトリビュート
;               DX    表示開始位置
;       出力    DX    表示終了位置
;               SI    ﾒｯｾｰｼﾞ終了ｱﾄﾞﾚｽ
;**************************
dispMsg    PROC NEAR

        PUSH    AX
        PUSH    CX
        MOV     CX,1
msgLoop:
        MOV     AL,CS:[SI]
        TEST    AL,AL
        JZ      dispMsgEnd

        CALL    dispChar
        INC     SI
        INC     DL
        JMP     msgLoop
dispMsgEnd:
        POP     CX
        POP     AX
        RET

dispMsg   ENDP
;**************************
;文字表示
;
;       入力    AL    表示キャラクタコード
;               BL    アトリビュート
;               CX    表示回数
;               DX    表示開始位置
;       破壊    なし
;**************************
dispChar    PROC NEAR

        PUSH    DX

        PUSH    AX
        PUSH    DS
        XOR     AX, AX
        MOV     DS, AX
        MOV     DS:[450H],DX
        POP     DS
        POP     AX

        PUSH    AX
        PUSH    BX
        PUSH    CX
        XOR     BH,BH
        MOV     Ah,09H
        INT     10H
        POP     CX
        POP     BX
        POP     AX
        POP     DX
        RET

dispChar    ENDP

;**************************
;
;  文字列表示
;
;  入力  CS:SI  文字列のアドレス
;        BL   文字の属性
;  出力  なし
;  破壊  AL SI
;**************************
dispTTY PROC NEAR

dispTTYLoop:
        MOV     AL,CS:[SI]
        TEST    AL,AL
        JZ      dispTTYEnd
        PUSH    AX
        PUSH    BX
        MOV     AH,0EH
        XOR     BH,BH
        INT     10H
        POP     BX
        POP     AX
        INC     SI
        JMP     dispTTYLoop
dispTTYEnd:
        RET

dispTTY ENDP

;**************************
;  ｶｰｿﾙ表示
;**************************
resetCursor PROC NEAR

        PUSH    AX
        PUSH    BX
        PUSH    CX
        XOR     BH,BH
        MOV     AH,02H
        INT     10H
        MOV     AH,01H
        MOV     CX,[cursorShape]
        INT     10H
        POP     CX
        POP     BX
        POP     AX
        RET

resetCursor ENDP

;**************************
;  ｶｰｿﾙ消去
;**************************
clearCursor PROC NEAR

        PUSH    AX
        PUSH    CX
        MOV     AH, 01H
        MOV     CX, 2000H
        INT     10H
        POP     CX
        POP     AX
        RET

clearCursor ENDP

TitleMsg DB 'Magukara Utility Version 0.00',13,10
         DB 'Copyright 2012-2014, {sora,macchan}@sfc.wide.ad.jp',13,10,13,10
         DB 'Press any key to continue.',13,10,13,10
         DB '(ALT-Z is start up the menu)',13,10,0

MenuTitleMsg DB 'Magukara Utility',0
MenuKeyMsg   DB 18h,19h,':Select Items  Enter:Change Item',0

QuitMsg    DB 'Save Parameters ?(Y/N)',0
QuitKeyMsg DB 'Y:Exit and save changes N:Exit and discard changes  Esc:Cancel',0

ItemInfo STRUC
 ItemMsg  DW ?
 ItemDisp DW ?
 ItemEdit DW ?
 ItemUpdate DW ?
ItemInfo ENDS

ItemTable LABEL ItemInfo
          ItemInfo<ModeMsg,ModeDisp,ModeEdit,ModeUpdate>
          ItemInfo<AdrsMsg,AdrsDisp,AdrsEdit,AdrsUpdate>
          ItemInfo<StrMsg,StrDisp,StrEdit,StrUpdate>
          ItemInfo<ExitMsg,ExitDisp,ExitEdit,ExitUpdate>
MAX_ITEM_NUM EQU ($-ItemTable) / (SIZE ItemInfo)
          DW 0

ModeMsg   DB 'Packet Size',0,'                      [1:64 2:128 3:256 4:512 5:1024 6:1280 7:1518]',0
AdrsMsg   DB 'Inter Frame Gap',0,'                  [0001..9999  Default:0012]',0
StrMsg    DB "Protocol",0,'                                            ',0
ExitMsg   DB 'Exit',0,0

cursorShape DW ?
enterMode  DB 0
enterLen   DW 0
@ENTER_STR   EQU 0
@ENTER_HEX   EQU 1
@ENTER_NUM   EQU 2
curItemNum DB 0
curMode    DB ?
curAdrs    DW ?
curStr     DB 16 DUP(?)
strBuf     DB 16 DUP(?)
           DB 0
;*************************************************************************
;
;x86 PC/AT用拡張ROMプログラム本体終了
;
;**************************************************************************
CODE1 ENDS
      END ROM_JMP
