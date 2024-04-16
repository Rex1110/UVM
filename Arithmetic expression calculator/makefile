TOPMODULE = AEC_tb
TESTNAME = test
UVM_VERBOSITY = UVM_MEDIUM

TESTCOUNT=20
TREE_NUM_MIN=5
TREE_NUM_MAX=10
TREE_DEPTH_MIN=1
TREE_DEPTH_MAX=7
FSDB=0


.PHONY: help run clean

help:
	@echo " "
	@echo "==================================================================="
	@echo "|                        Available Targets                        |"
	@echo "|-----------------------------------------------------------------|"
	@echo "| 1.run            | Executes random UVM verification             |"
	@echo "| 2.clean          | Cleans directories for a clean build         |"
	@echo "|-----------------------------------------------------------------|"
	@echo "|                        Useful Parameters                        |"
	@echo "|-----------------------------------------------------------------|"
	@echo "| 1.TESTCOUNT      | Number of testcases to run, default 20.      |"
	@echo "| 2.TREE_NUM_MIN   | Lower bound of tree number, default 5.       |"
	@echo "| 3.TREE_NUM_MAX   | Upper bound of tree number, default 10.      |"
	@echo "| 4.TREE_DEPTH_MIN | Lower bound of tree depth , default 1.       |"
	@echo "| 5.TREE_DEPTH_MAX | Upper bound of tree depth , default 7.       |"
	@echo "| 6.FSDB           | If set to 1, dump waveform, default 0        |"
	@echo "==================================================================="
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
		+define+TREE_NUM_MIN=$(TREE_NUM_MIN) \
		+define+TREE_NUM_MAX=$(TREE_NUM_MAX) \
		+define+TREE_DEPTH_MIN=$(TREE_DEPTH_MIN) \
		+define+TREE_DEPTH_MAX=$(TREE_DEPTH_MAX) \
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
		+define+TREE_NUM_MIN=$(TREE_NUM_MIN) \
		+define+TREE_NUM_MAX=$(TREE_NUM_MAX) \
		+define+TREE_DEPTH_MIN=$(TREE_DEPTH_MIN) \
		+define+TREE_DEPTH_MAX=$(TREE_DEPTH_MAX) \
		-nowarn NONPRT; \
	fi
	@rm -rf ./*.dat;
	

clean:
	rm -rf *.log *.key *.fsdb *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog verdiLog INCA_libs 
	rm -rf ./fail_cases/*
