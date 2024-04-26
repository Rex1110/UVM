TOPMODULE = ATCONV_tb
TESTNAME = test 
UVM_VERBOSITY = UVM_MEDIUM

TESTCOUNT=10
FSDB = 0

.PHONY: help run clean

help:
	@echo " "
	@echo "======================================================================"
	@echo "|                           Available Targets                         "
	@echo "|---------------------------------------------------------------------"
	@echo "| 1. run          | Executes random UVM verification.                 "
	@echo "| 2. clean        | Cleans directories for a clean build.             "
	@echo "|---------------------------------------------------------------------"
	@echo "|                           Useful Parameters                         "
	@echo "|---------------------------------------------------------------------"
	@echo "| 1. TESTCOUNT    | Number of testcases to run, default: $(TESTCOUNT)."
	@echo "| 2. FSDB         | If set to 1, dump waveform, default: $(FSDB).     "
	@echo "======================================================================"
	@echo " "	


run: clean
	@if [ $(FSDB) -eq 1 ]; \
	then \
		irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+define+TESTCOUNT=$(TESTCOUNT) \
		+define+FSDB \
		-nowarn NONPRT \
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
	@rm -rf ./*.dat

clean:
	rm -rf *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb 
	rm -rf ./failed_image/*.dat
