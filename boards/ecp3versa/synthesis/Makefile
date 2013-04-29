BIT = $(BASE)_$(BASE).bit

$(BIT):
	diamondc cmd/build.tcl

load: $(BIT)
	diamondc cmd/load.tcl

clean:
	rm -f .run_manager.ini .setting.ini impl1/.build_status
	ls impl1| grep -v -e 'impl1.xcf' -e 'pcs_pipe_8b_x1.txt' | (cd impl1;xargs rm -r)

.PHONY: load clean
