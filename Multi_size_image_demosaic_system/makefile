TOPMODULE = demosaic_tb
TESTNAME = test
UVM_VERBOSITY = UVM_MEDIUM


SIMULATOR ?= vcs
TESTCOUNT=5

ifdef VCD
DEFINE_VCD = +define+VCD -access +rwc
else
DEFINE_VCD =
endif


WIDTH_MAX=256
WIDTH_MIN=3
HEIGHT_MAX=128
HEIGHT_MIN=3

IMAGE=""

define VCS_CMD
	vcs -sverilog -full64 -ntb_opts uvm \
		-top $(TOPMODULE) \
		-f filelist.f \
		-cm line+cond+fsm+tgl+branch+assert \
		+define+TESTCOUNT=$(TESTCOUNT) \
		+define+WIDTH_MAX=$(WIDTH_MAX) \
		+define+WIDTH_MIN=$(WIDTH_MIN) \
		+define+HEIGHT_MAX=$(HEIGHT_MAX) \
		+define+HEIGHT_MIN=$(HEIGHT_MIN) \
		+define+IMG_SIZE=$(WIDTH_MAX)*$(HEIGHT_MAX) \
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
		+define+WIDTH_MAX=$(WIDTH_MAX) \
		+define+WIDTH_MIN=$(WIDTH_MIN) \
		+define+HEIGHT_MAX=$(HEIGHT_MAX) \
		+define+HEIGHT_MIN=$(HEIGHT_MIN) \
		+define+IMG_SIZE=$(WIDTH_MAX)*$(HEIGHT_MAX) \
		$(DEFINE_VCD)
endef

define DIRECT_TEST
	irun -sv direct_tb.sv \
	+define+IMAGE=\"$(IMAGE)\" \
	$(DEFINE_VCD) \
	-nowarn NONPRT
endef

.PHONY: help run clean

help:
	@echo " "
	@echo "================================================================================================="
	@echo "|                                        Available Targets                         				"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "| 1. run          | Executes random UVM verification.                 							"
	@echo "| 2. clean        | Cleans directories for a clean build.             							"
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "|                                        Useful Parameters                                       "
	@echo "|------------------------------------------------------------------------------------------------"
	@echo "| 1. TESTCOUNT    | Number of testcases to run, default $(TESTCOUNT). 							"
	@echo "| 2. WIDTH_MIN    | Lower bound of width,       default $(WIDTH_MIN). 							"
	@echo "| 3. WIDTH_MAX    | Upper bound of width,       default $(WIDTH_MAX). 							"
	@echo "| 4. HEIGHT_MIN   | Upper bound of height,      default $(HEIGHT_MIN).							"
	@echo "| 5. HEIGHT_MAX   | Upper bound of height,      default $(HEIGHT_MAX).							"
	@echo "| 6. IMAGE        | If you want to conduct a directed test, place the photo in the image folder 	"
	@echo "|                   and set the IMAGE parameter to the location of the photo you wish to test.	" 
	@echo "|                   If not set, random UVM verification will be executed							"
	@echo "| 7. VCD          | If set to 1, dump waveform, default $(VCD).      							"
	@echo "| 8. SIMULATOR    | Choose simulator: vcs or irun, default: $(SIMULATOR)."
	@echo "================================================================================================="
	@echo " "


run:
	@if [ $(IMAGE) != "" ]; then \
		$(DIRECT_TEST); \
	elif [ "$(SIMULATOR)" = "vcs" ] || [ "$(SIMULATOR)" = "VCS" ]; then \
		$(VCS_CMD); \
	elif [ "$(SIMULATOR)" = "irun" ] || [ "$(SIMULATOR)" = "IRUN" ]; then \
		$(IRUN_CMD); \
	else \
		echo "Unsupported simulator: $(SIMULATOR)"; \
		exit 1; \
	fi
	
	@rm -rf *.dat;

clean:
	rm -rf *.out *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb *.vcd verdiLog
	rm -rf csrc simv.daidir vdCovLog *.vdb simv .fsm.sch.verilog.xml *.h cov_work
	rm -rf ./image/img_* ./image/*.dat
	rm -rf *.dat