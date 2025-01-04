TOPMODULE=SRAM_tb
TESTNAME=test
UVM_VERBOSITY=UVM_MEDIUM

SIMULATOR ?= vcs
TESTCOUNT ?= 20


define DEFINE_MACRO
ifdef $1
DEFINE_$1=+define+$1=$($1)
else
DEFINE_$1=
endif
endef

ifdef VCD
DEFINE_VCD = +define+VCD -access +rwc
else
DEFINE_VCD =
endif

define VCS_CMD
	vcs -sverilog -full64 -ntb_opts uvm \
		-top $(TOPMODULE) \
		-f filelist.f \
		-cm line+cond+tgl+branch+assert \
		+define+TESTCOUNT=$(TESTCOUNT) \
		$(DEFINE_VCD) \
		-o simv && ./simv -cm line+cond+fsm+tgl+branch+assert \
		+UVM_TESTNAME=$(TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY) +define+TESTCOUNT=$(TESTCOUNT) +UVM_TIMEOUT=10000000000 
endef

define IRUN_CMD
	irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+define+TESTCOUNT=$(TESTCOUNT) \
		$(DEFINE_VCD)
endef


.PHONY: run clean help

help:
	@echo " "
	@echo "================================================================================================="
	@echo "|                                        Available Targets                                      	"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "| 1. run          | Executes random UVM verification.                                           	"
	@echo "| 2. clean        | Cleans directories for a clean build.                                       	"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "|                                        Useful Parameters                                      	"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "| 1. TESTCOUNT    | Number of testcases to run, default $(TESTCOUNT).							"
	@echo "| 2. VCD          | If set to 1, dump waveform, default: $(VCD).     							"
	@echo "| 3. SIMULATOR    | Choose simulator: vcs or irun, default: $(SIMULATOR).						"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "|                                         Important Rules                                       	"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "| 1. 0 <= AWLEN  <= 15.                                                                          "
	@echo "| 2. 0 <= AWSIZE <= 2.                                                                           "
	@echo "| 3. 0 <= ARLEN  <= 15.                                                                          "
	@echo "| 4. 0 <= ARSIZE <= 2.                                                                           "
	@echo "================================================================================================="
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

clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb *.vcd verdiLog *.el
	rm -rf csrc simv.daidir vdCovLog *.vdb simv .fsm.sch.verilog.xml *.h cov_work