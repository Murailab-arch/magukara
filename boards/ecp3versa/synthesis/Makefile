BASE = impl1
BIT  = top_$(BASE).bit

$(BIT):
	diamondc $(BASE).tcl

load: $(BIT)
	diamondc $(BASE)_load.tcl
