TOPMODULE=SRAM_tb
TESTNAME=test
UVM_VERBOSITY=UVM_MEDIUM

TESTCOUNT=10

.PHONY: run clean help

ifdef AWLEN
DEFINE_AWLEN=+define+AWLEN=$(AWLEN)
else
DEFINE_AWLEN=
endif

ifdef AWSIZE
DEFINE_AWSIZE=+define+AWSIZE=$(AWSIZE)
else
DEFINE_AWSIZE=
endif

ifdef ARSIZE
DEFINE_ARSIZE=+define+ARSIZE=$(ARSIZE)
else
DEFINE_ARSIZE=
endif

ifdef FSDB
DEFINE_FSDB=+define+FSDB
ACCESS_FSDB=-access +rwc
else
DEFINE_FSDB=
ACCESS_FSDB=
endif

help:
	@echo " "
	@echo "================================================================================================="
	@echo "|                                        Available Targets                                      |"
	@echo "|------------------------------------------------------------------------------------------------|"
	@echo "| 1. run          | Executes random UVM verification.                                           |"
	@echo "| 2. clean        | Cleans directories for a clean build.                                       |"
	@echo "|------------------------------------------------------------------------------------------------|"
	@echo "|                                        Useful Parameters                                      |"
	@echo "|------------------------------------------------------------------------------------------------|"
	@echo "| 1. TESTCOUNT    | Number of testcases to run, default $(TESTCOUNT).                           |"
	@echo "| 2. AWLEN        | Write burst length, default 0 ~ 15.                                         |"
	@echo "| 3. AWSIZE       | Write burst size, default 0 ~ 2.                                            |"
	@echo "| 4. ARSIZE       | Read  burst size, default 0 ~ 2.                                            |"
	@echo "| 5. FSDB         | If defined, dump waveform, default None.                                    |"
	@echo "|------------------------------------------------------------------------------------------------|"
	@echo "|                                         Important Rules                                       |"
	@echo "|------------------------------------------------------------------------------------------------|"
	@echo "| 1. 0 <= AWLEN  <= 15.                                                                         |"
	@echo "| 2. 0 <= AWSIZE <= 2.                                                                          |"
	@echo "| 3. 0 <= ARSIZE <= 2.                                                                          |"
	@echo "| 4. ((AWLEN + 1) * (2 ** AWSIZE)) % (2 ** ARSIZE) == 0.                                        |"
	@echo "| 5. ((AWLEN + 1) * (2 ** AWSIZE)) / (2 ** ARSIZE) <= 16.                                       |"
	@echo "================================================================================================="
	@echo " "

run:
	@irun -uvm \
	-f filelist.f \
	-top $(TOPMODULE) \
	+UVM_TESTNAME=$(TESTNAME) \
	+UVM_VERBOSITY=$(UVM_VERBOSITY) \
	+define+TESTCOUNT=$(TESTCOUNT) \
	$(DEFINE_AWLEN) \
	$(DEFINE_AWSIZE) \
	$(DEFINE_ARSIZE) \
	$(DEFINE_FSDB) \
	$(ACCESS_FSDB);

clean:
	rm -rf *.log *.key *.rc *.conf *.history BSSLib.lib++ nWaveLog vfastLog INCA_libs *.fsdb
