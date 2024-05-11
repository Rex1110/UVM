TOPMODULE = demosaic_tb
TESTNAME = test
UVM_VERBOSITY = UVM_MEDIUM

TESTCOUNT=2
FSDB=0

WIDTH_MAX=512
WIDTH_MIN=3
HEIGHT_MAX=256
HEIGHT_MIN=3

IMAGE=""

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
	@echo "| 7. FSDB         | If set to 1, dump waveform, default $(FSDB).      							"
	@echo "================================================================================================="
	@echo " "


run:
	@if [ $(IMAGE) != "" ]; \
	then \
		python3 golden.py bayer2dat $(IMAGE); \
		if [ "$(FSDB)" -eq 1 ]; \
		then \
			irun -sv direct_tb.sv \
			+define+FSDB \
			+define+IMAGE=\"$(IMAGE)\" \
			-access +rwc \
			-nowarn NONPRT; \
		else \
			irun -sv direct_tb.sv \
			+define+IMAGE=\"$(IMAGE)\" \
			-nowarn NONPRT; \
		fi \
	else \
		irun -uvm \
		-f filelist.f \
		-top $(TOPMODULE) \
		+UVM_TESTNAME=$(TESTNAME) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+define+TESTCOUNT=$(TESTCOUNT) \
		+define+WIDTH_MAX=$(WIDTH_MAX) \
		+define+WIDTH_MIN=$(WIDTH_MIN) \
		+define+HEIGHT_MAX=$(HEIGHT_MAX) \
		+define+HEIGHT_MIN=$(HEIGHT_MIN) \
		-nowarn NONPRT; \
	fi
	
	@rm -rf *.dat;

clean:
	rm -rf *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb
	rm -rf ./image/img_* ./image/*.dat