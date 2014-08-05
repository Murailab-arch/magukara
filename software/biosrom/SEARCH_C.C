/*

 PCI拡張ROM設定パラメータ　取得サンプルプログラム for DOS
    search_c.c

*/

#include <stdio.h>
#include <string.h>
#include <dos.h>

main()
{
	int i,l;
	unsigned int SegAdr,VndID,DevID;
	short int far *ExpRomWord;
	char far *ExpRomByte;
	char PCIData[]="PCIR";
	int PCIDataOff,BoardNameOff,BoardParaOff;
	char mode;
	unsigned int address;
	char PCIExpRomString[]="Option ROM Sample Program Image ( for PC/AT ROM )";


	printf("PCI Option BIOS ROM Search C Program Ver1.0 by SUGAWARA\n");

	/* 拡張ROM格納領域 先頭アドレス */
	SegAdr=0xc000;	/* セグメント */

	BoardNameOff=0x1a;	/* PCIボード名/拡張ROMバージョン文字列格納オフセット */
	BoardParaOff=0x64;	/* 設定パラメータ格納オフセット */

	l=strlen(&PCIExpRomString[0]);

	while(1){

		/* 拡張ROMヘッダ検索 */
		ExpRomWord=MK_FP(SegAdr,0);	/* オフセット 0 */
		if (*ExpRomWord == 0xaa55) {	/* 55h AAh 拡張ROM確認 */

			/* PCIデータ構造シグネチャチェック */
			ExpRomWord=MK_FP(SegAdr,0x18);	/* PCIデータ構造へのポインタ格納アドレス */
			PCIDataOff=*ExpRomWord;
			ExpRomByte=MK_FP(SegAdr,PCIDataOff);	/* PCIデータ構造先頭アドレス */
			for(i=0;i<4;i++){	/* "PCIR"文字列チェック */
				if (*ExpRomByte != PCIData[i]) break;
				ExpRomByte++;
			}
			if (i==4) {	/* PCI拡張ROM確認 */

				/* ベンダID/デバイスID チェック */
				ExpRomWord=MK_FP(SegAdr,PCIDataOff+4);	/* ベンダID格納アドレス */
				VndID=*ExpRomWord;
				ExpRomWord++;	/* デバイスID格納アドレス */
				DevID=*ExpRomWord;
				if ((VndID==0x6809) & (DevID==0x8000)) {	/* ベンダID&デバイスID一致 */

					/* PCIボード名/拡張ROMバージョンなど 文字列チェック */
					ExpRomByte=MK_FP(SegAdr,BoardNameOff);	/* シグネチャ文字列オフセット */
					for(i=0;i<l;i++){	/* 拡張ROMに埋め込んでいる文字列チェック */
						if (*ExpRomByte != PCIExpRomString[i]) break;
						ExpRomByte++;
					}
					if (i==l) break;

				}

			}

		}

		/* 512バイト単位で検索 次のアドレス */
		SegAdr=SegAdr+512/16;	/* セグメントは/16 */
		if (SegAdr < 0xc000) {	/* アドレス1Mバイトを超えた */
			printf("Not found option ROM\n");
			return(-1);
		}
	}

	/* PCI拡張ROM発見 */
	printf("Option ROM Found\n  ROM Address = %04X0h\n",SegAdr);
	printf("  Parameters\n");

	/* モード */
	ExpRomByte=MK_FP(SegAdr,BoardParaOff);	/* 設定パラメータ格納オフセット */
	mode=*ExpRomByte;
	printf("    Mode    = %d\n",mode);
	ExpRomByte++;

	/* アドレス */
	address=*ExpRomByte;	/* 下位アドレス */
	ExpRomByte++;
	address=address+((*ExpRomByte)<<8);	/* 上位アドレス */
	printf("    Address = %04Xh\n",address);
	ExpRomByte++;

	/* 文字列 */
	printf("    Strings = '");
	for(i=0;i<16;i++){
		printf("%c",*ExpRomByte);
		ExpRomByte++;
	}
	printf("'\n");
}
