#!/bin/bash

# AXI Lite Protocol - Simulation Script
# This script runs the simulation using cocotb

set -e  # Exit on any error

# Configuration
RUNTIME=${1:-"1000ns"}
SIMULATOR=${2:-"icarus"}

echo "=== AXI Lite Protocol Simulation ==="
echo "Runtime: $RUNTIME"
echo "Simulator: $SIMULATOR"
echo

# Check if cocotb is installed
if ! python -c "import cocotb" 2>/dev/null; then
    echo "Error: cocotb is not installed"
    echo "Install with: pip install cocotb"
    exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.."

echo "Running cocotb simulation..."
echo "This will execute all tests in cocotb/test_axi_lite.py"
echo

# Run the simulation using make
if make SIM=$SIMULATOR; then
    echo
    echo "=== Simulation Results ==="
    echo "✓ All tests completed successfully!"
    echo "Check the output above for detailed test results."
else
    echo
    echo "=== Simulation Failed ==="
    echo "✗ Some tests failed. Check the output above for details."
    exit 1
fi

echo
echo "Simulation complete!"