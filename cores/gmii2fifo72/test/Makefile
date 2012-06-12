SOURCES=tb_gmii2fifo72.v $(wildcard ../rtl/*.v)

all: isim
#all: isim

gtk: all
	gtkwave test.vcd

isim: tb_gmii2fifo72
	./tb_gmii2fifo72

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_gmii2fifo72 verilog.log test.vcd

tb_gmii2fifo72: $(SOURCES)
	iverilog -o tb_gmii2fifo72 $(SOURCES)

.PHONY: clean isim cversim gtk
