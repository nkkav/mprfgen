# Filename : ghdl.mk
# Author   : Nikolaos Kavvadias 2010-2020
# Copyright: (C) 2010-2020 Nikolaos Kavvadias 

GHDL=ghdl
#MPRF=test1
GHDLFLAGS=--ieee=synopsys -fexplicit --workdir=work
GHDLRUNFLAGS=--vcd=$(MPRF).vcd --stop-time=800ns

# Default target : elaborate
all : elab

# Elaborate target.  Almost useless
elab : force
	$(GHDL) -c $(GHDLFLAGS) -e regfile_tb

# Run target
run: force
	$(GHDL) --elab-run $(GHDLFLAGS) regfile_tb $(GHDLRUNFLAGS)

# Targets to analyze libraries
init: force
	mkdir work
	$(GHDL) -a $(GHDLFLAGS) ../test/util_functions_pkg.vhd
	$(GHDL) -a $(GHDLFLAGS) ../test/regfile_core.vhd
	$(GHDL) -a $(GHDLFLAGS) ../test/$(MPRF).vhd
	$(GHDL) -a $(GHDLFLAGS) $(MPRF)_regfile_tb.vhd

force:

clean :
	rm -rf *.o work
