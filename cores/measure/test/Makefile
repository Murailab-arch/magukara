SOURCES=tb_measure.v \
	$(wildcard ../rtl/measure.v) \
	$(wildcard ../rtl/measure_core.v) \
	$(wildcard ../../../cores/asfifo/rtl/*.v) \
	$(wildcard ../../../cores/gmii2fifo9/rtl/*.v) \
	$(wildcard ../../../cores/crc/rtl/*.v)

#all: cversim
all: isim

gtk: all
	gtkwave test.vcd

isim: tb_measure
	./tb_measure

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_measure verilog.log test.vcd

tb_measure: $(SOURCES)
	iverilog -o tb_measure $(SOURCES)

.PHONY: clean isim cversim gtk
