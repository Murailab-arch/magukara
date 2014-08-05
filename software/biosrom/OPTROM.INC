;*****************************************
;PCIR定義
;*****************************************
PCIRS STRUC

PCIR_SIGN      DB 'PCIR'
PCIR_VENDOR_ID DW  ?
PCIR_DEVICE_ID DW  ?
PCIR_VPD       DW  ?
PCIR_LEN       DW  SIZE PCIRS
PCIR_REV       DB  00H
PCIR_CLASS_PROG DB  ?
PCIR_CLASS_SUB  DB  ?
PCIR_CLASS_BASE DB  ?
PCIR_IMAGE_LEN DW  ?
PCIR_REV_LVL   DW  ?
PCIR_CODE      DB  ?
PCIR_ID        DB  ?
PCIR_RSV       DB  2 DUP(?)

PCIRS ENDS

;*****************************************
;ROM Header Macro定義
;*****************************************
ROM_HEADER MACRO

        ORG     0
;---------------------------------------
;PCI拡張ROMヘッダ構造定義
;---------------------------------------
ROM_SIGN    DW   0AA55H               ;PCI拡張ROMヘッダ(固定)
ROM_SIZE    DB   0                    ;初期化サイズ(MAKEROM.COMが設定する)
ROM_JMP     LABEL FAR
            JMP  NEAR PTR &initCodeLabel ;拡張ROMプログラムへのジャンプ
ROM_DATA    DB   strROMData           ;デバイス固有領域(最大18バイト)
ROM_DATA_END LABEL BYTE
            ORG  18h
ROM_POINT   DW   PCIR                 ;PCIデータ構造へのポインタ(自動計算)
            .ERRNZ ROM_POINT LT ROM_DATA_END ;ROM_DATAが18バイトを超えた場合エラーとなる

;---------------------------------------
;PCIボード名/拡張ROMバージョンなど
;---------------------------------------
            DB   strROMName
;---------------------------------------
;PCIデータ構造定義
;---------------------------------------
             ALIGN 4
PCIR        LABEL PCIRS
            PCIRS<,pcirVendorID,pcirDeviceID,pcirVPD,,,\
                   pcirClassBase,pcirClassSub,pcirClassProg,,\
                   pcirRevLvl,pcirCode,pcirID>

          ENDM

;*******************************************
; ROM_HEADERマクロ用デフォルト値
;*******************************************
strROMData    CATSTR <'PCI Option ROM'>     ;デバイス固有領域(最大18バイト)
strROMName    CATSTR <'Option ROM Image',0> ;PCIボード名/拡張ROMバージョンなど
pcirVendorID  = 0000h
pcirDeviceID  = 0000h
pcirVPD       = 0000h
pcirClassProg = 00h
pcirClassSub  = 00h
pcirClassBase = 00h
pcirRevLvl    = 0000h
pcirCode      = 00h
pcirID        = 00h
initCodeLabel CATSTR <INIT_CODE>

