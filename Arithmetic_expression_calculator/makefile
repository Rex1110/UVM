TOPMODULE = AEC_tb
TESTNAME = test
UVM_VERBOSITY = UVM_MEDIUM

SIMULATOR 		?= vcs
TESTCOUNT 		?= 20
TREE_NUM_MIN 	?= 1
TREE_NUM_MAX 	?= 6
TREE_DEPTH_MIN 	?= 1
TREE_DEPTH_MAX 	?= 6

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
		+define+TREE_NUM_MIN=$(TREE_NUM_MIN) \
		+define+TREE_NUM_MAX=$(TREE_NUM_MAX) \
		+define+TREE_DEPTH_MIN=$(TREE_DEPTH_MIN) \
		+define+TREE_DEPTH_MAX=$(TREE_DEPTH_MAX) \
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
		+define+TREE_NUM_MIN=$(TREE_NUM_MIN) \
		+define+TREE_NUM_MAX=$(TREE_NUM_MAX) \
		+define+TREE_DEPTH_MIN=$(TREE_DEPTH_MIN) \
		+define+TREE_DEPTH_MAX=$(TREE_DEPTH_MAX) \
		$(DEFINE_VCD)
endef


.PHONY: help run clean

help:
	@echo " "
	@echo "=================================================================="
	@echo "|                        Available Targets                        "
	@echo "|-----------------------------------------------------------------"
	@echo "| 1.run            | Executes random UVM verification.            "
	@echo "| 2.clean          | Cleans directories for a clean build.        "
	@echo "|-----------------------------------------------------------------"
	@echo "|                        Useful Parameters                        "
	@echo "|-----------------------------------------------------------------"
	@echo "| 1.TESTCOUNT      | Number of testcases to run, default $(TESTCOUNT)."
	@echo "| 2.TREE_NUM_MIN   | Lower bound of tree number, default $(TREE_NUM_MIN)."
	@echo "| 3.TREE_NUM_MAX   | Upper bound of tree number, default $(TREE_NUM_MAX)."
	@echo "| 4.TREE_DEPTH_MIN | Lower bound of tree depth , default $(TREE_DEPTH_MIN)."
	@echo "| 5.TREE_DEPTH_MAX | Upper bound of tree depth , default $(TREE_DEPTH_MAX)."
	@echo "| 6.VCD            | If set to 1, dump waveform, default: $(VCD).     "
	@echo "| 7.SIMULATOR      | Choose simulator: vcs or irun, default: $(SIMULATOR)."
	@echo "=================================================================="
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
	@rm -rf ./*.dat;


clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb *.vcd verdiLog
	rm -rf csrc simv.daidir vdCovLog *.vdb simv .fsm.sch.verilog.xml *.h cov_work
	rm -rf ./fail_cases/*
