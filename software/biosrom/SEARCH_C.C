/*

 PCI�g��ROM�ݒ�p�����[�^�@�擾�T���v���v���O���� for DOS
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

	/* �g��ROM�i�[�̈� �擪�A�h���X */
	SegAdr=0xc000;	/* �Z�O�����g */

	BoardNameOff=0x1a;	/* PCI�{�[�h��/�g��ROM�o�[�W����������i�[�I�t�Z�b�g */
	BoardParaOff=0x64;	/* �ݒ�p�����[�^�i�[�I�t�Z�b�g */

	l=strlen(&PCIExpRomString[0]);

	while(1){

		/* �g��ROM�w�b�_���� */
		ExpRomWord=MK_FP(SegAdr,0);	/* �I�t�Z�b�g 0 */
		if (*ExpRomWord == 0xaa55) {	/* 55h AAh �g��ROM�m�F */

			/* PCI�f�[�^�\���V�O�l�`���`�F�b�N */
			ExpRomWord=MK_FP(SegAdr,0x18);	/* PCI�f�[�^�\���ւ̃|�C���^�i�[�A�h���X */
			PCIDataOff=*ExpRomWord;
			ExpRomByte=MK_FP(SegAdr,PCIDataOff);	/* PCI�f�[�^�\���擪�A�h���X */
			for(i=0;i<4;i++){	/* "PCIR"������`�F�b�N */
				if (*ExpRomByte != PCIData[i]) break;
				ExpRomByte++;
			}
			if (i==4) {	/* PCI�g��ROM�m�F */

				/* �x���_ID/�f�o�C�XID �`�F�b�N */
				ExpRomWord=MK_FP(SegAdr,PCIDataOff+4);	/* �x���_ID�i�[�A�h���X */
				VndID=*ExpRomWord;
				ExpRomWord++;	/* �f�o�C�XID�i�[�A�h���X */
				DevID=*ExpRomWord;
				if ((VndID==0x6809) & (DevID==0x8000)) {	/* �x���_ID&�f�o�C�XID��v */

					/* PCI�{�[�h��/�g��ROM�o�[�W�����Ȃ� ������`�F�b�N */
					ExpRomByte=MK_FP(SegAdr,BoardNameOff);	/* �V�O�l�`��������I�t�Z�b�g */
					for(i=0;i<l;i++){	/* �g��ROM�ɖ��ߍ���ł��镶����`�F�b�N */
						if (*ExpRomByte != PCIExpRomString[i]) break;
						ExpRomByte++;
					}
					if (i==l) break;

				}

			}

		}

		/* 512�o�C�g�P�ʂŌ��� ���̃A�h���X */
		SegAdr=SegAdr+512/16;	/* �Z�O�����g��/16 */
		if (SegAdr < 0xc000) {	/* �A�h���X1M�o�C�g�𒴂��� */
			printf("Not found option ROM\n");
			return(-1);
		}
	}

	/* PCI�g��ROM���� */
	printf("Option ROM Found\n  ROM Address = %04X0h\n",SegAdr);
	printf("  Parameters\n");

	/* ���[�h */
	ExpRomByte=MK_FP(SegAdr,BoardParaOff);	/* �ݒ�p�����[�^�i�[�I�t�Z�b�g */
	mode=*ExpRomByte;
	printf("    Mode    = %d\n",mode);
	ExpRomByte++;

	/* �A�h���X */
	address=*ExpRomByte;	/* ���ʃA�h���X */
	ExpRomByte++;
	address=address+((*ExpRomByte)<<8);	/* ��ʃA�h���X */
	printf("    Address = %04Xh\n",address);
	ExpRomByte++;

	/* ������ */
	printf("    Strings = '");
	for(i=0;i<16;i++){
		printf("%c",*ExpRomByte);
		ExpRomByte++;
	}
	printf("'\n");
}