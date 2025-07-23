# AXI Lite Protocol Design Specification

## 📋 Project Overview

This document specifies the design details of the AXI Lite Protocol Verification project, which provides a complete RTL implementation and dual verification environment for the AXI4-Lite protocol in a single master, single slave configuration.

## 🏗️ System Architecture

### Top-Level Design
```
┌─────────────────┐    AXI Lite     ┌─────────────────┐
│                 │    Interface    │                 │
│   AXI Lite      │◄───────────────►│   AXI Lite      │
│   Master        │                 │   Slave         │
│                 │                 │                 │
└─────────────────┘                 └─────────────────┘
        │                                   │
        └───────────── Clock & Reset ───────┘
```

### Component Hierarchy
- **`tb_top.sv`** - Top-level testbench (dual-mode: cocotb/UVM)
- **`axi_lite_interface.sv`** - SystemVerilog interface with modports
- **`axi_lite_master.v`** - AXI Lite master with FSM implementation
- **`axi_lite_slave.v`** - AXI Lite slave with memory interface

## 🔧 Interface Specification

### AXI Lite Interface Signals

#### Write Address Channel (AW)
| Signal    | Width | Direction | Description |
|-----------|-------|-----------|-------------|
| `awaddr`  | 32    | M → S     | Write address |
| `awvalid` | 1     | M → S     | Write address valid |
| `awready` | 1     | S → M     | Write address ready |

#### Write Data Channel (W)
| Signal   | Width | Direction | Description |
|----------|-------|-----------|-------------|
| `wdata`  | 32    | M → S     | Write data |
| `wstrb`  | 4     | M → S     | Write strobe (byte enables) |
| `wvalid` | 1     | M → S     | Write data valid |
| `wready` | 1     | S → M     | Write data ready |

#### Write Response Channel (B)
| Signal   | Width | Direction | Description |
|----------|-------|-----------|-------------|
| `bresp`  | 2     | S → M     | Write response (00=OKAY) |
| `bvalid` | 1     | S → M     | Write response valid |
| `bready` | 1     | M → S     | Write response ready |

#### Read Address Channel (AR)
| Signal    | Width | Direction | Description |
|-----------|-------|-----------|-------------|
| `araddr`  | 32    | M → S     | Read address |
| `arvalid` | 1     | M → S     | Read address valid |
| `arready` | 1     | S → M     | Read address ready |

#### Read Data Channel (R)
| Signal   | Width | Direction | Description |
|----------|-------|-----------|-------------|
| `rdata`  | 32    | S → M     | Read data |
| `rresp`  | 2     | S → M     | Read response (00=OKAY) |
| `rvalid` | 1     | S → M     | Read data valid |
| `rready` | 1     | M → S     | Read data ready |

#### Common Signals
| Signal  | Width | Direction | Description |
|---------|-------|-----------|-------------|
| `clk`   | 1     | Input     | Clock signal |
| `rst_n` | 1     | Input     | Active-low reset |

## 🎯 Master Design (`axi_lite_master.v`)

### FSM States
```verilog
localparam IDLE       = 4'b0000;  // Idle state
localparam WRITE_ADDR = 4'b0001;  // Write address phase
localparam WRITE_DATA = 4'b0010;  // Write data phase
localparam WRITE_RESP = 4'b0011;  // Write response phase
localparam READ_ADDR  = 4'b0100;  // Read address phase
localparam READ_DATA  = 4'b0101;  // Read data phase
localparam DONE       = 4'b0110;  // Transaction complete
```

### State Transition Diagram
```
IDLE ──┬─► WRITE_ADDR ─► WRITE_DATA ─► WRITE_RESP ─┐
       │                                           │
       └─► READ_ADDR ──► READ_DATA ────────────────┼─► IDLE
                                                   │
                                                   ▼
                                                 DONE
```

### Key Features
- **Automatic Test Sequence**: Generates write followed by read transaction
- **Configurable Delays**: Built-in delay counters for proper timing
- **Test Data**: Uses address 0x1000 and data 0xDEADBEEF for testing
- **Proper Handshakes**: Implements all AXI Lite handshake protocols

## 🗄️ Slave Design (`axi_lite_slave.v`)

### FSM States
```verilog
localparam IDLE   = 3'b000;  // Idle state
localparam WRITE  = 3'b001;  // Write transaction
localparam READ   = 3'b010;  // Read transaction
localparam BRESP  = 3'b011;  // Write response
localparam RRESP  = 3'b100;  // Read response
```

### Memory Interface
- **Memory Size**: 256 x 32-bit words
- **Address Range**: 0x0000 to 0x03FC (word-aligned)
- **Byte Enables**: Supports partial word writes via `wstrb`
- **Response**: Always returns OKAY (2'b00) for valid addresses

### Key Features
- **Memory Model**: Internal memory array for data storage
- **Byte-Level Writes**: Supports individual byte enables
- **Immediate Response**: Single-cycle response for all transactions
- **Address Decoding**: Uses bits [9:2] for word addressing

## 🔌 Interface Design (`axi_lite_interface.sv`)

### SystemVerilog Interface
```systemverilog
interface axi_lite_interface #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
);
    // All AXI Lite signals defined here
    
    modport master (...);  // Master view
    modport slave (...);   // Slave view
endinterface
```

### Benefits
- **Clean Connections**: Eliminates signal-by-signal connections
- **Modports**: Provides directional views for master and slave
- **Parameterizable**: Configurable address and data widths
- **Type Safety**: Compile-time checking of signal usage

## 📊 Transaction Types

### Write Transaction Sequence
1. **Address Phase**: Master asserts `awvalid` with `awaddr`
2. **Address Handshake**: Slave responds with `awready`
3. **Data Phase**: Master asserts `wvalid` with `wdata` and `wstrb`
4. **Data Handshake**: Slave responds with `wready`
5. **Response Phase**: Slave asserts `bvalid` with `bresp`
6. **Response Handshake**: Master responds with `bready`

### Read Transaction Sequence
1. **Address Phase**: Master asserts `arvalid` with `araddr`
2. **Address Handshake**: Slave responds with `arready`
3. **Data Phase**: Slave asserts `rvalid` with `rdata` and `rresp`
4. **Data Handshake**: Master responds with `rready`

## ⏱️ Timing Characteristics

### Clock Requirements
- **Frequency**: No specific requirement (tested at 100MHz equivalent)
- **Duty Cycle**: 50% recommended
- **Jitter**: Standard digital clock requirements

### Reset Behavior
- **Type**: Synchronous reset, active-low
- **Duration**: Minimum 2 clock cycles
- **Recovery**: All signals return to idle state

### Handshake Timing
- **Setup Time**: 1 clock cycle before rising edge
- **Hold Time**: Maintained until handshake complete
- **Response Time**: Single cycle for slave responses

## 🎯 Design Parameters

### Configurable Parameters
```verilog
parameter ADDR_WIDTH = 32;    // Address bus width
parameter DATA_WIDTH = 32;    // Data bus width
parameter STRB_WIDTH = 4;     // Strobe width (DATA_WIDTH/8)
```

### Fixed Parameters
- **Memory Depth**: 256 words (1KB total)
- **Response Type**: Always OKAY (no error responses)
- **Burst Support**: None (AXI Lite is single-beat only)
- **Outstanding Transactions**: 1 (no pipelining)

## 🔍 Protocol Compliance

### AXI4-Lite Specification Compliance
- ✅ **Single Transaction**: No burst support (as per AXI Lite)
- ✅ **Handshake Protocol**: All channels use valid/ready handshakes
- ✅ **Response Codes**: Proper OKAY response generation
- ✅ **Signal Widths**: Standard 32-bit address and data
- ✅ **Reset Behavior**: Compliant reset handling

### Verification Coverage
- ✅ **All Channels**: AW, W, B, AR, R channels verified
- ✅ **Handshakes**: All valid/ready combinations tested
- ✅ **Data Integrity**: Write-then-read verification
- ✅ **Reset**: Proper reset behavior verified

## 📈 Performance Characteristics

### Throughput
- **Write**: 1 transaction per 4 clock cycles (minimum)
- **Read**: 1 transaction per 3 clock cycles (minimum)
- **Mixed**: Depends on transaction ordering

### Latency
- **Write Response**: 2 clock cycles after data acceptance
- **Read Response**: 1 clock cycle after address acceptance
- **Memory Access**: Zero wait states

## 🔧 Implementation Notes

### Design Decisions
1. **Simple FSM**: Easy to understand and verify
2. **Immediate Response**: No wait states for predictable timing
3. **Full Memory**: Complete address space implementation
4. **Test-Friendly**: Built-in test pattern generation

### Synthesis Considerations
- **Clock Domain**: Single clock domain design
- **Reset Strategy**: Synchronous reset for FPGA compatibility
- **Resource Usage**: Minimal logic resources required
- **Timing Closure**: Clean timing with standard constraints

## 📚 References

- **AXI4 Specification**: ARM IHI 0022E (AXI and ACE Protocol Specification)
- **AXI4-Lite**: Subset specification for simple memory-mapped interfaces
- **SystemVerilog**: IEEE 1800-2017 Standard
- **UVM**: Universal Verification Methodology 1.2

---

**This design specification serves as the authoritative reference for the AXI Lite Protocol Verification project implementation.**