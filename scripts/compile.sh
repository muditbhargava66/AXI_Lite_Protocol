#!/bin/bash

# AXI Lite Protocol - Compilation Script
# This script compiles the RTL design for different simulators

set -e  # Exit on any error

# Set directories
DESIGN_DIR="../rtl"
TESTBENCH_DIR="../testbench"

# Default simulator
SIMULATOR=${1:-"icarus"}

echo "=== AXI Lite Protocol Compilation ==="
echo "Simulator: $SIMULATOR"
echo "Design directory: $DESIGN_DIR"
echo "Testbench directory: $TESTBENCH_DIR"
echo

case $SIMULATOR in
    "icarus")
        echo "Compiling with Icarus Verilog..."
        iverilog -g2012 -o axi_lite_sim \
            "$DESIGN_DIR/axi_lite_master.v" \
            "$DESIGN_DIR/axi_lite_slave.v" \
            "$DESIGN_DIR/axi_lite_interface.sv" \
            "$TESTBENCH_DIR/tb_top.sv"
        echo "✓ Compilation complete. Run with: vvp axi_lite_sim"
        ;;
    
    "modelsim"|"questa")
        echo "Compiling with ModelSim/QuestaSim..."
        vlog -sv "$DESIGN_DIR/axi_lite_master.v"
        vlog -sv "$DESIGN_DIR/axi_lite_slave.v"
        vlog -sv "$DESIGN_DIR/axi_lite_interface.sv"
        vlog -sv "$TESTBENCH_DIR/tb_top.sv"
        echo "✓ Compilation complete."
        ;;
    
    "vcs")
        echo "Compiling with VCS..."
        vcs -sverilog -debug_access+all \
            "$DESIGN_DIR/axi_lite_master.v" \
            "$DESIGN_DIR/axi_lite_slave.v" \
            "$DESIGN_DIR/axi_lite_interface.sv" \
            "$TESTBENCH_DIR/tb_top.sv"
        echo "✓ Compilation complete."
        ;;
    
    *)
        echo "Error: Unsupported simulator '$SIMULATOR'"
        echo "Supported simulators: icarus, modelsim, questa, vcs"
        exit 1
        ;;
esac

echo "=== Compilation Summary ==="
echo "✓ AXI Lite Master compiled"
echo "✓ AXI Lite Slave compiled"
echo "✓ AXI Lite Interface compiled"
echo "✓ Testbench compiled"
echo
echo "Ready for simulation!"