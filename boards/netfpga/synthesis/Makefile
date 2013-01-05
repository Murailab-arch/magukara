BOARD_DIR=../rtl
CORES_DIR=../../../cores

include ../sources.mak
SRC=$(BOARD_SRC) $(CORES_SRC)

all: build/top.bit

build/top.ucf: common.ucf xst.ucf
	cat common.ucf xst.ucf > build/top.ucf

build/top.prj: $(SRC)
	rm -f build/top.prj
	for i in `echo $^`; do \
	    echo "verilog work ../$$i" >> build/top.prj; \
	done

build/asfifo9_4.ngc: $(CORES_DIR)/coregen/asfifo9_4.xco
	cd build && coregen -b ../../../../cores/coregen/asfifo9_4.xco

build/top.ngc: build/top.prj
	cd build && xst -ifn ../top.xst

build/top.ngd: build/top.ngc build/asfifo9_4.ngc build/top.ucf
	cd build && ngdbuild -uc top.ucf top.ngc

include common.mak

