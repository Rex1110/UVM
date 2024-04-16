TOPMODULE=rails_tb
TESTNAME=test
UVM_VERBOSITY=UVM_MEDIUM

TESTCOUNT=20
FSDB=0

.PHONY: help run run_cpp clean

help:
	@echo " "
	@echo "======================================================================"
	@echo "|                           Available Targets                         "
	@echo "|---------------------------------------------------------------------"
	@echo "| 1. run          | Executes random UVM verification.                 "
	@echo "| 2. cpp_run      | Compiles 'golden.cpp' into an executable.         "
	@echo "| 3. clean        | Cleans directories for a clean build.             "
	@echo "|---------------------------------------------------------------------"
	@echo "|                           Useful Parameters                         "
	@echo "|---------------------------------------------------------------------"
	@echo "| 1. TESTCOUNT    | Number of testcases to run, default: $(TESTCOUNT)."
	@echo "| 2. FSDB         | If set to 1, dump waveform, default: $(FSDB).     "
	@echo "======================================================================"
	@echo " "

run: clean run_cpp
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
	@rm -rf ./*.txt

run_cpp:
	g++ golden.cpp -o a.out

clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb
