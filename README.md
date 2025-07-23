<div align="center">

# AXI Lite Protocol Verification

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/Tests-Passing-green.svg)]()
[![Simulator](https://img.shields.io/badge/Simulator-Icarus%20Verilog-blue.svg)]()

**This project implements a complete design and verification environment for the AXI Lite protocol with a single master and single slave configuration. The verification is built using SystemVerilog for RTL and Python-based cocotb for comprehensive testing.**

</div>

## 🏗️ Project Structure

```
AXI_Lite_Protocol/
├── README.md                    # This file
├── Makefile                     # Build and test automation (cocotb)
├── Makefile.uvm                 # UVM-specific build system
├── .gitignore                   # Git ignore rules
├── LICENSE                      # MIT License
├── VERIFICATION_SUMMARY.md      # Detailed verification results
├── rtl/                         # RTL source files
│   ├── axi_lite_master.v        # AXI Lite master module
│   ├── axi_lite_slave.v         # AXI Lite slave module
│   └── axi_lite_interface.sv    # SystemVerilog interface
├── testbench/                   # SystemVerilog testbench files
│   ├── tb_top.sv               # Top-level testbench (dual-mode)
│   ├── axi_lite_env.sv         # UVM environment
│   ├── axi_lite_agent.sv       # UVM agent
│   ├── axi_lite_sequencer.sv   # UVM sequencer & transactions
│   ├── axi_lite_driver.sv      # UVM driver
│   ├── axi_lite_monitor.sv     # UVM monitor
│   ├── axi_lite_scoreboard.sv  # UVM scoreboard
│   ├── axi_lite_seq_lib.sv     # UVM sequence library
│   ├── axi_lite_virtual_seq.sv # UVM virtual sequences
│   └── axi_lite_test.sv        # UVM test classes
├── cocotb/                      # Python test files
│   └── test_axi_lite.py        # Comprehensive cocotb tests
├── docs/                        # Documentation
│   ├── design_spec.md          # Design specification
│   ├── verification_plan.md    # Verification plan
│   └── coverage_report.md      # Coverage analysis
├── scripts/                     # Utility scripts
│   ├── compile.sh              # Compilation script
│   ├── simulate.sh             # Simulation script
│   └── coverage.py             # Coverage analysis
├── constraints/                 # Verification constraints
│   ├── axi_lite_constraints.sv # Random constraints
│   └── axi_lite_ral_model.sv   # Register abstraction layer
└── synth/                      # Synthesis files
    └── synth.json              # Yosys synthesis script
```

## 🚀 Quick Start

### Prerequisites

Make sure you have the following installed:
- **Python 3.7+**
- **cocotb** (`pip install cocotb`)
- **Icarus Verilog** (or another supported simulator)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/AXI_Lite_Protocol.git
   cd AXI_Lite_Protocol
   ```

2. Run the verification:
   ```bash
   make
   ```

That's it! The tests will run automatically and show the results.

## 🧪 Testing

The project provides **two complete verification approaches**:

### 🐍 Python-based Testing (cocotb) - Default
Modern Python-based verification using cocotb framework:

#### Test 1: Basic AXI Lite Protocol Test
- ✅ Write transaction (address: 0x1000, data: 0xDEADBEEF)
- ✅ Read transaction from the same address
- ✅ Data integrity verification
- ✅ Response code validation (OKAY = 0)

#### Test 2: Protocol Compliance Test
- ✅ Signal initialization after reset
- ✅ Write address handshake (awvalid & awready)
- ✅ Write data handshake (wvalid & wready)
- ✅ Write response handshake (bvalid & bready)
- ✅ Read address handshake (arvalid & arready)
- ✅ Read data handshake (rvalid & rready)

### 🔧 SystemVerilog UVM Testing
Professional UVM-based verification environment:

#### Available UVM Tests
- **Sanity Test** - Quick functionality check
- **Basic Test** - Comprehensive basic operations
- **Random Test** - Randomized transaction testing
- **Regression Test** - Full verification suite

#### UVM Components
- **Environment** - Complete verification environment
- **Agent** - Driver, monitor, sequencer coordination
- **Sequences** - Various test scenarios (basic, random, stress, address walking)
- **Scoreboard** - Transaction checking and memory modeling

### Running Tests

```bash
# Python-based tests (default, works with Icarus Verilog)
make                    # Run cocotb tests
make cocotb-test       # Explicit cocotb test run

# SystemVerilog UVM tests (requires commercial simulator)
make uvm-test                                    # Basic UVM test
make uvm-test UVM_TESTNAME=axi_lite_sanity_test  # Sanity test
make uvm-test UVM_TESTNAME=axi_lite_random_test  # Random test
make uvm-test SIM=modelsim                       # Specify simulator

# Utility commands
make clean-all         # Clean all generated files
make help             # Show all available options
make info             # Show configuration
```

## 📊 Verification Results

```
** TESTS=2 PASS=2 FAIL=0 SKIP=0 **
✓ test_axi_lite_basic - PASS
✓ test_axi_lite_protocol_compliance - PASS
```

## 🔧 Key Features

### RTL Implementation
- **AXI Lite Master**: Complete FSM with automatic test sequence generation
- **AXI Lite Slave**: Memory-mapped slave with proper handshake handling
- **Interface**: SystemVerilog interface with modports for clean connections

### Verification Environment
- **cocotb-based**: Python test framework for easy test development
- **Comprehensive Coverage**: All AXI Lite handshakes and protocols verified
- **Protocol Compliance**: Strict adherence to AXI specification
- **Automated Testing**: One-command test execution

## 🛠️ Development

### Adding New Tests

1. Edit `cocotb/test_axi_lite.py`
2. Add your test function with `@cocotb.test()` decorator
3. Run `make` to execute all tests

### Modifying RTL

1. Edit files in `rtl/` directory
2. Run `make clean && make` to test changes

### Supported Simulators

- **Icarus Verilog** (default)
- **ModelSim/QuestaSim** (`make SIM=modelsim`)
- **VCS** (`make SIM=vcs`)
- **Xcelium** (`make SIM=xcelium`)

## 📈 Coverage Achieved

- ✅ Write transactions
- ✅ Read transactions
- ✅ Data integrity verification
- ✅ Response code verification
- ✅ Handshake protocol compliance
- ✅ Reset behavior
- ✅ State machine transitions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Future Enhancements

- [ ] Add burst transaction support
- [ ] Implement functional coverage metrics
- [ ] Add formal verification
- [ ] Support for multiple masters/slaves
- [ ] Performance analysis tools
- [ ] GUI-based waveform analysis

---

<div align="center">

**Made with ❤️ for the hardware verification community**

</div>