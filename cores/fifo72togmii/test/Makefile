SOURCES=tb_fifo72togmii.v $(wildcard ../rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_fifo72togmii
	./tb_fifo72togmii

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_fifo72togmii verilog.log test.vcd

tb_fifo72togmii: $(SOURCES)
	iverilog -o tb_fifo72togmii $(SOURCES)

.PHONY: clean isim cversim gtk
