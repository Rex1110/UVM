TOPMODULE = ATCONV_tb
TESTNAME = test 
UVM_VERBOSITY = UVM_MEDIUM

SIMULATOR ?= vcs
TESTCOUNT ?= 20

ifdef VCD
DEFINE_VCD = +define+VCD -access +rwc
else
DEFINE_VCD =
endif

define VCS_CMD
	vcs -sverilog -full64 -ntb_opts uvm \
		-top $(TOPMODULE) \
		-f filelist.f \
		-cm line+cond+fsm+tgl+branch+assert \
		+define+TESTCOUNT=$(TESTCOUNT) \
		$(DEFINE_VCD) \
		-o simv && ./simv -cm line+cond+fsm+tgl+branch+assert \
		+UVM_TESTNAME=$(TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TIMEOUT=10000000000 
endef

define IRUN_CMD
	irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		-coverage all \
		-covoverwrite \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		-nowarn NONPRT \
		+define+TESTCOUNT=$(TESTCOUNT) \
		$(DEFINE_VCD)
endef


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
	@echo "| 2. VCD          | If set to 1, dump waveform, default: $(VCD).     "
	@echo "| 3. SIMULATOR    | Choose simulator: vcs or irun, default: $(SIMULATOR)."
	@echo "======================================================================"
	@echo " "	


run: clean
	@if [ "$(SIMULATOR)" = "vcs" ] || [ "$(SIMULATOR)" = "VCS" ]; then \
		$(VCS_CMD); \
	elif [ "$(SIMULATOR)" = "irun" ] || [ "$(SIMULATOR)" = "IRUN" ]; then \
		$(IRUN_CMD); \
	else \
		echo "Unsupported simulator: $(SIMULATOR)"; \
		exit 1; \
	fi
	@rm -rf ./*.dat

clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.vcd verdiLog
	rm -rf csrc simv.daidir vdCovLog *.vdb simv .fsm.sch.verilog.xml *.h cov_work
	rm -rf ./failed_image/*.dat
