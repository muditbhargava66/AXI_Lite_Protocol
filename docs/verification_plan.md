# AXI Lite Protocol Verification Plan

## 🎯 Verification Objectives

The primary objectives of the AXI Lite Protocol Verification project are:

1. **Protocol Compliance**: Verify full compliance with AXI4-Lite specification
2. **Functional Correctness**: Ensure all transactions work as specified
3. **Data Integrity**: Validate that written data can be read back correctly
4. **Handshake Verification**: Confirm all valid/ready handshakes work properly
5. **Reset Behavior**: Verify proper reset and initialization sequences
6. **Coverage Goals**: Achieve 100% functional coverage of all protocol features

## 🔬 Verification Methodology

### Dual Verification Approach

This project employs a **dual verification strategy** to maximize coverage and accessibility:

#### 1. Python-based Verification (cocotb)
- **Framework**: cocotb (Python-based verification)
- **Target Users**: Students, researchers, open-source developers
- **Simulator Support**: Icarus Verilog (free), ModelSim, VCS, Xcelium
- **Advantages**: Easy to learn, fast development, accessible

#### 2. SystemVerilog UVM Verification
- **Framework**: Universal Verification Methodology (UVM)
- **Target Users**: Professional verification engineers
- **Simulator Support**: ModelSim, VCS, Xcelium (commercial simulators)
- **Advantages**: Industry standard, comprehensive, scalable

## 🐍 Python Verification Environment (cocotb)

### Test Structure
```
cocotb/
└── test_axi_lite.py
    ├── test_axi_lite_basic()
    └── test_axi_lite_protocol_compliance()
```

### Test Scenarios

#### Test 1: Basic AXI Lite Protocol Test
**Objective**: Verify basic write-then-read functionality

**Test Sequence**:
1. Wait for reset deassertion
2. Monitor for write address handshake (`awvalid` & `awready`)
3. Capture write address (expected: 0x1000)
4. Monitor for write data handshake (`wvalid` & `wready`)
5. Capture write data (expected: 0xDEADBEEF)
6. Monitor for write response handshake (`bvalid` & `bready`)
7. Verify write response is OKAY (0x0)
8. Monitor for read address handshake (`arvalid` & `arready`)
9. Capture read address (should match write address)
10. Monitor for read data handshake (`rvalid` & `rready`)
11. Verify read data matches written data
12. Verify read response is OKAY (0x0)

**Success Criteria**:
- All handshakes occur within timeout
- Read data matches written data
- All responses are OKAY

#### Test 2: Protocol Compliance Test
**Objective**: Verify AXI Lite protocol compliance

**Test Sequence**:
1. **Signal Initialization**: Verify all signals start in correct state
2. **Write Address Handshake**: Verify `awvalid` & `awready` timing
3. **Write Data Handshake**: Verify `wvalid` & `wready` timing
4. **Write Response Handshake**: Verify `bvalid` & `bready` timing
5. **Read Address Handshake**: Verify `arvalid` & `arready` timing
6. **Read Data Handshake**: Verify `rvalid` & `rready` timing

**Success Criteria**:
- All handshakes follow AXI protocol rules
- No protocol violations detected
- Proper signal initialization

### Coverage Points (cocotb)
- ✅ Write address channel handshake
- ✅ Write data channel handshake
- ✅ Write response channel handshake
- ✅ Read address channel handshake
- ✅ Read data channel handshake
- ✅ Data integrity (write-then-read)
- ✅ Response code verification
- ✅ Reset behavior
- ✅ Signal initialization

## 🔧 SystemVerilog UVM Verification Environment

### UVM Component Hierarchy
```
axi_lite_env
├── axi_lite_agent
│   ├── axi_lite_sequencer
│   ├── axi_lite_driver
│   └── axi_lite_monitor
└── axi_lite_scoreboard
```

### UVM Components

#### Environment (`axi_lite_env.sv`)
- **Purpose**: Top-level verification environment
- **Components**: Agent, scoreboard, configuration
- **Responsibilities**: Component creation and connection

#### Agent (`axi_lite_agent.sv`)
- **Purpose**: Encapsulates driver, monitor, sequencer
- **Mode**: Active (with driver) or passive (monitor only)
- **Configuration**: Configurable via `axi_lite_config`

#### Sequencer (`axi_lite_sequencer.sv`)
- **Purpose**: Manages sequence items and transaction flow
- **Transaction Item**: `axi_lite_transaction` with constraints
- **Features**: Address constraints, strobe patterns, randomization

#### Driver (`axi_lite_driver.sv`)
- **Purpose**: Drives transactions on AXI Lite interface
- **Methods**: `drive_write()`, `drive_read()`
- **Features**: Proper handshake handling, timeout protection

#### Monitor (`axi_lite_monitor.sv`)
- **Purpose**: Observes interface and reports transactions
- **Outputs**: Analysis port for scoreboard connection
- **Features**: Separate write/read monitoring threads

#### Scoreboard (`axi_lite_scoreboard.sv`)
- **Purpose**: Checks transaction correctness
- **Features**: Memory model, data integrity checking, statistics
- **Verification**: Write/read correlation, response validation

### UVM Test Classes

#### Base Test (`axi_lite_base_test`)
- **Purpose**: Common test infrastructure
- **Features**: Environment setup, configuration, basic run phase

#### Sanity Test (`axi_lite_sanity_test`)
- **Purpose**: Quick functionality check
- **Transactions**: 5 write-read pairs
- **Duration**: ~100ns

#### Basic Test (`axi_lite_basic_test`)
- **Purpose**: Comprehensive basic functionality
- **Transactions**: 10 write-read pairs
- **Coverage**: All basic protocol features

#### Random Test (`axi_lite_random_test`)
- **Purpose**: Randomized transaction testing
- **Transactions**: 50 random transactions
- **Coverage**: Corner cases, random patterns

#### Regression Test (`axi_lite_regression_test`)
- **Purpose**: Complete verification suite
- **Sequences**: Basic + Random + Address walking
- **Coverage**: Maximum coverage achievement

### UVM Sequence Library

#### Basic Sequence (`axi_lite_basic_sequence`)
- **Pattern**: Write-then-read to same address
- **Addresses**: Sequential (0x1000, 0x1004, 0x1008, ...)
- **Data**: Incremental pattern (0xDEAD0000, 0xDEAD0001, ...)

#### Random Sequence (`axi_lite_random_sequence`)
- **Pattern**: Fully randomized transactions
- **Constraints**: Valid address ranges, proper alignment
- **Coverage**: Random address/data combinations

#### Stress Sequence (`axi_lite_stress_sequence`)
- **Pattern**: Back-to-back transactions
- **Purpose**: Test maximum throughput
- **Features**: No delays between transactions

#### Address Walking Sequence (`axi_lite_addr_walk_sequence`)
- **Pattern**: Walking 1s address pattern
- **Purpose**: Address decoder verification
- **Coverage**: All address bits

### Virtual Sequences

#### Sanity Virtual Sequence
- **Components**: Basic sequence (5 transactions)
- **Purpose**: Quick smoke test

#### Regression Virtual Sequence
- **Components**: Basic + Random + Address walking
- **Purpose**: Comprehensive verification
- **Duration**: ~1000ns

## 📊 Coverage Methodology

### Functional Coverage Points

#### Channel Coverage
- **Write Address Channel**: Address ranges, valid/ready timing
- **Write Data Channel**: Data patterns, strobe combinations
- **Write Response Channel**: Response codes, timing
- **Read Address Channel**: Address ranges, valid/ready timing
- **Read Data Channel**: Data patterns, response codes

#### Transaction Coverage
- **Write Transactions**: Address/data combinations
- **Read Transactions**: Address coverage, data verification
- **Mixed Transactions**: Write-read sequences

#### Protocol Coverage
- **Handshakes**: All valid/ready combinations
- **Reset**: Reset assertion/deassertion timing
- **Idle States**: Proper idle behavior

### Coverage Goals
- **Functional Coverage**: 100%
- **Code Coverage**: 100% (statement, branch, expression)
- **Assertion Coverage**: 100%

## 🧪 Test Execution Strategy

### Simulation Flow
1. **Compilation**: RTL + Testbench compilation
2. **Elaboration**: Design hierarchy setup
3. **Simulation**: Test execution with coverage collection
4. **Analysis**: Coverage and results analysis

### Test Execution Commands

#### cocotb Tests
```bash
# Run all cocotb tests
make cocotb-test

# Clean and run
make clean-all && make cocotb-test
```

#### UVM Tests
```bash
# Run specific UVM test
make uvm-test UVM_TESTNAME=axi_lite_basic_test

# Run with different simulator
make uvm-test SIM=modelsim UVM_TESTNAME=axi_lite_regression_test

# Run with verbosity
make uvm-test UVM_VERBOSITY=UVM_HIGH
```

### Regression Suite
```bash
# Complete regression (both approaches)
make clean-all
make cocotb-test          # Python tests
make uvm-test SIM=modelsim UVM_TESTNAME=axi_lite_regression_test  # UVM tests
```

## 📈 Success Criteria

### Test Pass Criteria
- **cocotb Tests**: All assertions pass, no timeouts
- **UVM Tests**: All sequences complete, scoreboard passes
- **Coverage**: 100% functional coverage achieved
- **Protocol**: No AXI protocol violations

### Expected Results
```
** cocotb Results **
TESTS=2 PASS=2 FAIL=0 SKIP=0
✓ test_axi_lite_basic - PASS
✓ test_axi_lite_protocol_compliance - PASS

** UVM Results **
✓ axi_lite_sanity_test - PASS
✓ axi_lite_basic_test - PASS  
✓ axi_lite_random_test - PASS
✓ axi_lite_regression_test - PASS
```

## 🔍 Debug and Analysis

### Debugging Tools
- **Waveform Analysis**: VCD/FST files for signal tracing
- **Log Analysis**: Detailed transaction logging
- **Coverage Reports**: HTML coverage reports
- **Assertion Reports**: Protocol violation detection

### Common Debug Scenarios
1. **Handshake Timeouts**: Check valid/ready signal timing
2. **Data Mismatches**: Verify memory model and data paths
3. **Protocol Violations**: Check AXI specification compliance
4. **Coverage Gaps**: Identify untested scenarios

## 📋 Verification Checklist

### Pre-Verification
- [ ] RTL design complete and reviewed
- [ ] Testbench environment setup
- [ ] Simulator licenses and tools available
- [ ] Test plan reviewed and approved

### During Verification
- [ ] All tests passing consistently
- [ ] Coverage goals being met
- [ ] No protocol violations detected
- [ ] Performance requirements satisfied

### Post-Verification
- [ ] 100% functional coverage achieved
- [ ] All test scenarios executed successfully
- [ ] Coverage reports generated and reviewed
- [ ] Verification sign-off obtained

## 🎯 Verification Schedule

### Phase 1: Basic Verification (Complete)
- ✅ cocotb test development
- ✅ Basic functionality verification
- ✅ Protocol compliance testing

### Phase 2: Advanced Verification (Complete)
- ✅ UVM environment development
- ✅ Comprehensive test suite
- ✅ Coverage analysis

### Phase 3: Regression and Sign-off (Complete)
- ✅ Full regression testing
- ✅ Coverage closure
- ✅ Final verification report

## 📚 References

- **AXI4 Specification**: ARM IHI 0022E
- **UVM User Guide**: Accellera UVM 1.2
- **cocotb Documentation**: https://docs.cocotb.org/
- **SystemVerilog LRM**: IEEE 1800-2017

---

**This verification plan ensures comprehensive validation of the AXI Lite Protocol implementation through dual verification methodologies.**