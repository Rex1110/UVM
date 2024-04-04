TOPMODULE=rails_tb
TESTNAME=test
UVM_VERBOSITY=UVM_MEDIUM

TESTCOUNT=20
FSDB=0

run: clean cpp_run uvm_run

.PHONY: uvm_run cpp_run clean

cpp_run:
	g++ golden.cpp -o a.out

uvm_run: 
	@if [ $(FSDB) -eq 1 ]; \
	then \
		irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+define+TESTCOUNT=$(TESTCOUNT) \
		-nowarn NONPRT \
		+define+FSDB \
		-access +rwc; \
	else \
		irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+define+TESTCOUNT=$(TESTCOUNT) \
		-nowarn NONPRT; \
	fi

clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.txt *.fsdb
