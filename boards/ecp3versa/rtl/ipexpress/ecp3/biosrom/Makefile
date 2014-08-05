ROM_BIN = ../../../../../../software/biosrom/BIOSROM.ROM
MEM_FILE = biosrom.mem

biosrom.mem: $(ROM_BIN)
	hexdump -v -e '"" 1/2 "%04X\n"' < $(ROM_BIN) > biosrom.mem
