ROM_BIN = ./BIOSROM.ROM
MEM16_FILE = ./biosrom.d16
MEM32_FILE = ./biosrom.d32

all: $(MEM32_FILE) $(MEM16_FILE)

$(MEM32_FILE): $(ROM_BIN)
	hexdump -v -e '"\n" 4/1 "%02X"' < $(ROM_BIN) > $(MEM32_FILE)
#	hexdump -v -e '"" 1/4 "%08X\n"' < $(ROM_BIN) > $(MEM32_FILE)

$(MEM16_FILE): $(ROM_BIN)
	hexdump -v -e '"" 1/2 "%04X\n"' < $(ROM_BIN) > $(MEM16_FILE)

clean:
	rm -f $(MEM32_FILE) $(MEM16_FILE)
