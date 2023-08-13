################################################################################
# Default argument values.
################################################################################
IMG         ?= sim
SIM         ?= questa
BUILD_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
################################################################################
# General paths and directories.
################################################################################
MM_BUILD_DIR = build
MM_ABSPATH_IMG_BUILD_DIR = $(BUILD_ROOT)/$(MM_BUILD_DIR)/$(IMG)_$(SIM)

WS_ROOT = $(BUILD_ROOT)/../../..
export FE_PATH = $(WS_ROOT)/fe/hdl
VERIF_ROOT = $(BUILD_ROOT)/../..
export TB_PATH = $(WS_ROOT)/verif/src

MM_COVS_DIR = covs
MM_LOGS_DIR = logs
MM_LIBS_DIR = libs
MM_SIMS_DIR = sims
COV_REPORT_DIR = $(MM_ABSPATH_IMG_BUILD_DIR)/coverage_report
# Default libraries.
MM_LIB_DUT_NAME = dut_lib
MM_LIB_TB_NAME = tb_lib
MM_LIB_DUT_DIR = $(MM_LIBS_DIR)/$(MM_LIB_DUT_NAME)
MM_LIB_TB_DIR = $(MM_LIBS_DIR)/$(MM_LIB_TB_NAME)
MM_TEST_BASE = $(NAME)_$(SEED)
MM_SIM_DIR = $(MM_SIMS_DIR)/$(MM_TEST_BASE)
################################################################################
# Simulation parameters setting.
################################################################################
TOP_MODULES := tb_top dut_top
TIMESCALE ?= 1ns/1ps
UVM_TEST      = 
NAME          = 
VERB          = UVM_LOW
SEED          = 1
SIM           = 
GUI           = 0
COV           = 0
DEBUG         = 0

VHDL_TOOL     ?= 
SVLOG_TOOL    ?= 
ELAB_TOOL     ?= 
RUN_TOOL      ?= 

TB_SVLOG_OPTS ?=
ELAB_OPTS     ?=
RUN_OPTS      ?=

MAX_UVM_ERRORS = 1000
MODE = false

# bsub parameters setting.
GRID_NAME = modumake
GRID_MEM = 4000
GRID_QUEUES = i_soc_rh7
MM_EXEC_CMD = bsub -J $(GRID_NAME) -R "rusage[mem=$(GRID_MEM)]" -q $(GRID_QUEUES)


# Default elaborated image name.
MM_ELAB_IMAGE_NAME = simv
# Default base name for simulation runtime files, like logs and waves.
MM_SIMFILE_BASE_NAME = sim
# vcs coverage scope file
COVERAGE_SCOPE_FILE = $(MM_ABSPATH_IMG_BUILD_DIR)/cov_scopes.txt
# Path to the TCL script file.
MM_SIM_DIR_TCL_FILE = $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR)/$(MM_SIMFILE_BASE_NAME).tcl
# Simulator bit modes. If 0 is defined, 64 bit mode is used.
MM_ENABLE_32BIT_MODE_QUESTA = 1
MM_ENABLE_32BIT_MODE_VCS = 0
# Default code coverage collection types for Questa.
# - s: statement (or line)
# - b: branch
# - c: condition
# - e: expression
# - t: toggle
# - f: fsm
MM_CODE_COVERAGE_OPTS_QUESTA = sbcetf
# Default coverage collection types for VCS/Verdi. Define by separating the following types with "+" sign
# - line: statement (or line)
# - branch: branch
# - cond: condition
# - tgl: toggle
# - fsm: fsm
# - assert: assert
MM_CODE_COVERAGE_OPTS_VCS = line+branch+cond+tgl+fsm+assert
# Defines for how many lines "UVM_ERROR" and "UVM_FATAL" numbers are searched at the end of simulation logs.
MM_TAIL_SEARCH_LINES = 500

# FPGA_MODE = FALSE
# ifeq ($(FPGA_OPT), 1)
# 	FPGA_MODE = TRUE
# endif

# Set tools for compilation elaboration simulation.
ifeq ($(SIM), questa)
  VHDL_TOOL = vcom
  SVLOG_TOOL = vlog
  ELAB_TOOL = vopt
  RUN_TOOL = vsim 
else
  VHDL_TOOL = vhdlan
  SVLOG_TOOL = vlogan
  ELAB_TOOL = vcs
  RUN_TOOL = ../../$(MM_ELAB_IMAGE_NAME)
endif

# Set sv compile options.
ifeq ($(SIM), questa)
  ifeq ($(MM_ENABLE_32BIT_MODE_QUESTA), 1)
    MM_TOOL_BITMODE = -32
  else
    MM_TOOL_BITMODE = -64
  endif
  TB_SVLOG_OPTS += $(MM_TOOL_BITMODE)
  TB_SVLOG_OPTS += -work $(MM_LIB_TB_DIR)
  TB_SVLOG_OPTS += -L $(QUESTA_HOME)/uvm-1.2
  TB_SVLOG_OPTS += -nologo -incr -lint -hazards -assertdebug -linedebug -fsmdebug
  TB_SVLOG_OPTS += +define+NUM_PARA_RE=$(NUM_PARA_RE)
  TB_SVLOG_OPTS += +define+UVM_REG_DATA_WIDTH=64
  TB_SVLOG_OPTS += +define+UVM_REG_ADDR_WIDTH=64
else
  ifneq ($(MM_ENABLE_32BIT_MODE_VCS), 1)
    MM_TOOL_BITMODE = -full64
  endif
  TB_SVLOG_OPTS += $(MM_TOOL_BITMODE)
  TB_SVLOG_OPTS += -work $(MM_LIB_TB_NAME)
  TB_SVLOG_OPTS += -sverilog -nc +warn=all +lint=all,noVCDE,noNS,noSVA-UA
  TB_SVLOG_OPTS += -ntb_opts uvm-1.2
  TB_SVLOG_OPTS += +define+NUM_PARA_RE=$(NUM_PARA_RE)
  TB_SVLOG_OPTS += +define+UVM_REG_DATA_WIDTH=32
  TB_SVLOG_OPTS += +define+UVM_REG_ADDR_WIDTH=32
endif

# Set sv elab options.
ifeq ($(SIM), questa)
  ELAB_OPTS += -work $(MM_LIB_TB_DIR)
  ELAB_OPTS += -L $(MM_LIB_DUT_DIR)
  ELAB_OPTS += -L $(QUESTA_HOME)/uvm-1.2
  ELAB_OPTS += -incr -hazards +checkALL +acc -error 3473 -timescale=$(TIMESCALE)
  ifeq ($(DEBUG), 1)
    ELAB_OPTS += -assertdebug -linedebug -fsmdebug
  endif
  ELAB_OPTS += -Gnum_parallel_re=$(NUM_PARA_RE)
  ELAB_OPTS += -Gfpga_opt_g=$(FPGA_OPT)
else
  ELAB_OPTS += $(MM_TOOL_BITMODE)
  ELAB_OPTS += -sverilog -licqueue -lca -Mdir=$(MM_LIB_TB_DIR)/mdir -Xgc=+ -fastcomp=il
  ELAB_OPTS += +warn=all +lint=all,noVCDE,noNS,noSVA-UA
  ELAB_OPTS += -check -ntb_opts check
  ifeq ($(DEBUG), 1)
    ELAB_OPTS += -debug_access+all +UVM_TR_RECORD
  else
    ELAB_OPTS += -debug_access+r+fn
  endif
  ELAB_OPTS += -ntb_opts uvm-1.2 
  ELAB_OPTS += -gv num_parallel_re=$(NUM_PARA_RE) 
  ELAB_OPTS += -gv fpga_opt_g=$(FPGA_OPT)
  ELAB_OPTS += -timescale=$(TIMESCALE)
#   ELAB_OPTS += lib_dut.dut_lib
endif

# Set sv run options.
ifeq ($(SIM), questa)
  RUN_OPTS += -lib $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIB_TB_DIR) $(MM_ELAB_IMAGE_NAME)
  RUN_OPTS += $(MM_TOOL_BITMODE) -sv_seed $(SEED) -suppress 12003 -error 3473
  RUN_OPTS += -L $(QUESTA_HOME)/uvm-1.2
#   RUN_OPTS += -L dut_lib
  ifeq ($(GUI), 1)
    RUN_OPTS += -i
  else
    RUN_OPTS += -batch
  endif
  ifeq ($(DEBUG), 1)
    RUN_OPTS += -wlf ./$(MM_SIMFILE_BASE_NAME).wlf
	RUN_OPTS += -assertdebug -fsmdebug
  endif
  RUN_OPTS += -solvefaildebug -printsimstats
  RUN_OPTS += +UVM_MAX_QUIT_COUNT=$(MAX_UVM_ERRORS)
  RUN_OPTS += -do "do $(MM_SIMFILE_BASE_NAME).tcl"
#   RUN_OPTS += +UVM_TIMEOUT=5_000_000_000_000,YES
else
  RUN_OPTS += -licqueue
  RUN_OPTS += -reportstats
  RUN_OPTS += +ntb_random_seed=$(SEED)
  ifeq ($(DEBUG), 1)
    RUN_OPTS += +vpdfile+$(MM_SIMFILE_BASE_NAME).vpd
  endif
  RUN_OPTS += +vcs+flush -licwait 600
  RUN_OPTS += -ucli -do $(MM_SIMFILE_BASE_NAME).tcl
endif

RUN_OPTS += -l ./$(MM_SIMFILE_BASE_NAME).log
RUN_OPTS += +UVM_TESTNAME=$(UVM_TEST) +UVM_VERBOSITY=$(VERB)

ifdef TV_PATH
	RUN_OPTS += +tv_path=$(TV_PATH)
endif
ifdef CHUNK_SIZE
	RUN_OPTS += +chunk_size=$(CHUNK_SIZE)
endif
ifdef NUM_PARA_RE
	RUN_OPTS += +num_parallel_re=$(NUM_PARA_RE)
endif
ifdef FPGA_OPT
	RUN_OPTS += +fpga_opt=$(FPGA_OPT)
endif

# Coverage scopes and settings.
ifeq ($(COV), 1)
	ifeq ($(SIM), questa)
		ELAB_OPTS += +cover=$(MM_CODE_COVERAGE_OPTS_QUESTA)+/dut_top/inst_top.
		ELAB_OPTS += -toggleportsonly
		RUN_OPTS += -coverage
	else
		ELAB_OPTS += -cm_dir $(MM_COVS_DIR)/covdb 
		ELAB_OPTS += -cm $(MM_CODE_COVERAGE_OPTS_VCS)
		ELAB_OPTS += -cm_hier $(COVERAGE_SCOPE_FILE)
		RUN_OPTS += -cm $(MM_CODE_COVERAGE_OPTS_VCS)
    	RUN_OPTS += -cm_name $(MM_TEST_BASE)
	endif
endif

ifeq ($(VERDI), 1)
    TB_SVLOG_OPTS += -kdb -debug_access+all+reverse
    ELAB_OPTS += -kdb -debug_access+all+reverse
endif


################################################################################
# vcs uvm compile specific settings.
################################################################################
UVM_COMP_OPTS += -sverilog
UVM_COMP_OPTS += +define+UVM_VERDI_NO_PORT_RECORDING
UVM_COMP_OPTS += +define+UVM_REG_DATA_WIDTH=32
UVM_COMP_OPTS += +define+UVM_REG_ADDR_WIDTH=32
UVM_COMP_OPTS += -full64
UVM_COMP_OPTS  = -ntb_opts uvm-1.2

# Set uvm lib compile options
INCDIR+=+incdir+$(TB_PATH)/env
INCDIR+=+incdir+$(TB_PATH)/common
INCDIR+=+incdir+$(TB_PATH)/sequence
INCDIR+=+incdir+$(TB_PATH)/tc
INCDIR+=+incdir+$(TB_PATH)/top

#specifies system verilog compile variant 
SVLOG_OPTS = $(TB_SVLOG_OPTS)
SVLOG_OPTS += $(INCDIR)
SVLOG_OPTS += -timescale=$(TIMESCALE)

# *********************************************************************************************
# Psinr project specific targets.
# *********************************************************************************************
.PHONY: init
.PHONY: pre_comp_dut
.PHONY: comp_dut
.PHONY: proj_comp_tb
.PHONY: comp
.PHONY: elab
.PHONY: run
.PHONY: init_sim
.PHONY: pre_sim
.PHONY: run_sim
.PHONY: post_sim
.PHONY: cov_rpt

comp: comp_dut comp_tb elab

init:
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_COVS_DIR)
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LOGS_DIR)
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIMS_DIR)
ifeq ($(SIM), questa)
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIBS_DIR)
	vlib $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIB_DUT_DIR)
	vlib $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIB_TB_DIR)
else
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIB_DUT_DIR)
	mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LIB_TB_DIR)
endif
ifeq ($(COV), 1)
  ifeq ($(SIM), vcs)
	@echo "+tree dut_top.inst_top" >> $(COVERAGE_SCOPE_FILE)
  endif
endif


pre_comp_dut: init
ifeq ($(SIM), questa)
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && vmap -c && vmap $(MM_LIB_DUT_NAME) $(MM_LIB_DUT_DIR)
else
	@echo "WORK > $(MM_LIB_DUT_NAME)" >> $(MM_ABSPATH_IMG_BUILD_DIR)/synopsys_sim.setup
	@echo "$(MM_LIB_DUT_NAME): $(MM_LIB_DUT_DIR)" >> $(MM_ABSPATH_IMG_BUILD_DIR)/synopsys_sim.setup
	@echo "$(MM_LIB_TB_NAME): $(MM_LIB_TB_DIR)" >> $(MM_ABSPATH_IMG_BUILD_DIR)/synopsys_sim.setup
endif


comp_dut: pre_comp_dut
ifeq ($(SIM), questa)
	@echo 'compiling DUT with QUESTA'
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(VHDL_TOOL) -work $(MM_LIB_DUT_NAME)  $(MM_TOOL_BITMODE) -nologo -f $(FE_PATH)/filelist.f -l $(MM_LOGS_DIR)/psinr_dut_top.log
else
	@echo 'compiling DUT with vcs'
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(VHDL_TOOL) $(MM_TOOL_BITMODE) -no_opt -vhdl08 -work $(MM_LIB_DUT_NAME) -f $(FE_PATH)/filelist.f -l $(MM_LOGS_DIR)/psinr_dut_top.log
endif

comp_uvm_lib:
ifeq ($(SIM), vcs)
	@echo "Compiling UVM lib ..."
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(SVLOG_TOOL) $(UVM_COMP_OPTS) -l $(MM_LOGS_DIR)/comp_uvm_lib.log
	@echo " compile uvm lib done"
endif

comp_tb: comp_dut comp_uvm_lib
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(SVLOG_TOOL) $(SVLOG_OPTS) -f $(TB_PATH)/filelist.f -l $(MM_LOGS_DIR)/psinr_tb.log 

elab:
ifeq ($(SIM), questa)
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(MM_EXEC_CMD) $(ELAB_TOOL) $(ELAB_OPTS) $(TOP_MODULES) -o $(MM_ELAB_IMAGE_NAME) -l $(MM_LOGS_DIR)/psinr_elab.log
	@if grep -q 'Error:' $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_LOGS_DIR)/psinr_elab.log; then \
		echo "Elab error, check $(MM_LOGS_DIR)/psinr_elab.log"; \
		exit 1; \
	fi
else
	cd $(MM_ABSPATH_IMG_BUILD_DIR) && $(MM_EXEC_CMD) $(ELAB_TOOL) $(ELAB_OPTS) $(TOP_MODULES) -o $(MM_ELAB_IMAGE_NAME) -l $(MM_LOGS_DIR)/psinr_elab.log
endif

init_sim:
ifeq ($(UVM_TEST),)
	$(error ERROR: UVM_TEST is not set)
endif
	@if [ ! -d "$(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR)" ]; then \
		mkdir -p $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR); \
	fi
	cd $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR) ; mkdir -p matchpoints_logs

pre_sim:
ifeq ($(SIM), questa)
	@echo "coverage save -onexit -testname $(MM_TEST_BASE) $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_COVS_DIR)/$(MM_TEST_BASE).ucdb" >> $(MM_SIM_DIR_TCL_FILE)
	@echo "set NumericStdNoWarnings 1" >> $(MM_SIM_DIR_TCL_FILE)
  ifeq ($(DEBUG), 1)
	@echo "add log -r /*" >> $(MM_SIM_DIR_TCL_FILE)
  endif
  ifeq ($(GUI), 0)
	@echo "run -all; quit -f" >> $(MM_SIM_DIR_TCL_FILE)
  endif
else
  ifeq ($(DEBUG), 1)
	@echo "dump -type vpd -file $(MM_SIMFILE_BASE_NAME).vpd" >> $(MM_SIM_DIR_TCL_FILE)
	@echo "dump -add / -depth 0 -fid vpd0" >> $(MM_SIM_DIR_TCL_FILE)
  else
	@echo "dump -add / -depth 0" >> $(MM_SIM_DIR_TCL_FILE)
  endif
  ifeq ($(GUI), 0)
	@echo "run" >> $(MM_SIM_DIR_TCL_FILE)
  endif
endif

run_sim:
	cd $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR) && $(MM_EXEC_CMD) $(RUN_TOOL) $(RUN_OPTS)

post_sim: 
	$(eval SIM_LOG := $(shell echo "$(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR)/$(MM_SIMFILE_BASE_NAME).log"))
	$(eval TAIL_CMD := $(shell echo "tail -n $(MM_TAIL_SEARCH_LINES) $(SIM_LOG)"))
	$(eval UVM_FATAL_CNT := $(shell $(TAIL_CMD) | grep "UVM_FATAL :" | sed 's/.*UVM_FATAL ://' | awk '{print $$1}'))
	$(eval UVM_ERROR_CNT := $(shell $(TAIL_CMD) | grep "UVM_ERROR :" | sed 's/.*UVM_ERROR ://' | awk '{print $$1}'))
	@if [[ "$(UVM_FATAL_CNT)" == "0" && "$(UVM_ERROR_CNT)" == "0" && "$(DEBUG)" == "2" ]]; then rm -f $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR)/*.vpd $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_SIM_DIR)/*.wlf; fi
	@echo "----------------------------------------------------------------------------------------------"
	@echo "Simulation log: $(SIM_LOG)"
	@echo "----------------------------------------------------------------------------------------------"

run: init_sim pre_sim run_sim post_sim cov_rpt

cov_rpt: 
ifeq ($(COV), 1)
  ifeq ($(SIM), questa)
	$(MM_EXEC_CMD) vcover merge $(MM_TOOL_BITMODE) $(MM_ABSPATH_IMG_BUILD_DIR)/mergefile.ucdb $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_COVS_DIR)/*.ucdb
	$(MM_EXEC_CMD) vcover report $(MM_TOOL_BITMODE) -html -details -annotate -showexcluded -output $(COV_REPORT_DIR) $(MM_ABSPATH_IMG_BUILD_DIR)/mergefile.ucdb
  else 
	$(MM_EXEC_CMD) urg $(MM_TOOL_BITMODE) +urg+lic+wait -show fullhier -show hvpfullhier -format both \
		-log $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_COVS_DIR)/covs.log \
		-dir $(MM_ABSPATH_IMG_BUILD_DIR)/$(MM_COVS_DIR)/covdb.vdb \
		-report $(COV_REPORT_DIR) 
  endif
endif 


.PHONY: clean
clean:
	@echo "Removing simulation log directory."
	@rm -r ./build
