# AXI Lite Protocol Verification Makefile
# Uses cocotb for Python-based verification

# Simulator selection
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# RTL source files
VERILOG_SOURCES += $(PWD)/rtl/axi_lite_master.v
VERILOG_SOURCES += $(PWD)/rtl/axi_lite_slave.v
VERILOG_SOURCES += $(PWD)/rtl/axi_lite_interface.sv
VERILOG_SOURCES += $(PWD)/testbench/tb_top.sv

# Top level module
TOPLEVEL = tb_top

# Test module
MODULE = test_axi_lite

# Add cocotb directory to Python path
export PYTHONPATH := $(PWD)/cocotb:$(PYTHONPATH)

# Include cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim

# Additional targets
.PHONY: help clean-all test uvm-test cocotb-test

help:
	@echo "AXI Lite Protocol Verification"
	@echo "Available targets:"
	@echo "  make          - Run cocotb tests (default)"
	@echo "  make cocotb-test - Run Python-based cocotb tests"
	@echo "  make uvm-test - Run SystemVerilog UVM tests"
	@echo "  make clean    - Clean simulation build files"
	@echo "  make clean-all- Clean all generated files"
	@echo "  make help     - Show this help"
	@echo "  make info     - Show configuration"
	@echo ""
	@echo "UVM Test Examples:"
	@echo "  make uvm-test UVM_TESTNAME=axi_lite_sanity_test"
	@echo "  make uvm-test UVM_TESTNAME=axi_lite_basic_test"
	@echo "  make uvm-test UVM_TESTNAME=axi_lite_random_test"
	@echo "  make uvm-test UVM_TESTNAME=axi_lite_regression_test"

# Default target runs cocotb tests
test: cocotb-test

# Cocotb tests (Python-based)
cocotb-test: all

# UVM tests (SystemVerilog-based)
UVM_TESTNAME ?= axi_lite_basic_test
UVM_VERBOSITY ?= UVM_MEDIUM

uvm-test:
	@echo "Running UVM test: $(UVM_TESTNAME)"
	@echo "Verbosity: $(UVM_VERBOSITY)"
ifeq ($(SIM),icarus)
	@echo "Note: UVM tests require a commercial simulator (ModelSim, VCS, etc.)"
	@echo "Icarus Verilog does not support UVM. Please use: make uvm-test SIM=modelsim"
else
	$(MAKE) -f Makefile.uvm UVM_TESTNAME=$(UVM_TESTNAME) UVM_VERBOSITY=$(UVM_VERBOSITY) SIM=$(SIM)
endif

clean-all: clean
	@echo "Cleaning all generated files..."
	@rm -rf __pycache__ cocotb/__pycache__
	@rm -f *.log *.vcd *.fst *.ghw
	@rm -rf work/ transcript vsim.wlf
	@echo "Clean complete."

# Print configuration
info:
	@echo "Configuration:"
	@echo "  Simulator: $(SIM)"
	@echo "  Top Level: $(TOPLEVEL)"
	@echo "  Test Module: $(MODULE)"
	@echo "  RTL Sources: $(VERILOG_SOURCES)"
	@echo "  UVM Test: $(UVM_TESTNAME)"