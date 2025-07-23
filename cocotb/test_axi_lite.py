import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

@cocotb.test()
async def test_axi_lite_basic(dut):
    """Basic test for AXI Lite protocol"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Wait a few cycles for reset to propagate
    for _ in range(5):
        await RisingEdge(dut.clk)
    
    # Test write transaction
    dut._log.info("Starting write transaction")
    
    # Wait for master to assert awvalid
    timeout = 0
    while not dut.axi_lite_if.awvalid.value and timeout < 100:
        await RisingEdge(dut.clk)
        timeout += 1
    
    if timeout >= 100:
        dut._log.error("Timeout waiting for awvalid")
        assert False, "Master did not assert awvalid"
    
    # Check write address
    write_addr = dut.axi_lite_if.awaddr.value
    dut._log.info(f"Write address: 0x{int(write_addr):08x}")
    
    # Wait for write data phase
    timeout = 0
    while not dut.axi_lite_if.wvalid.value and timeout < 100:
        await RisingEdge(dut.clk)
        timeout += 1
        
    if timeout >= 100:
        dut._log.error("Timeout waiting for wvalid")
        assert False, "Master did not assert wvalid"
    
    # Check write data
    write_data = dut.axi_lite_if.wdata.value
    dut._log.info(f"Write data: 0x{int(write_data):08x}")
    
    # Wait for write response
    timeout = 0
    while not dut.axi_lite_if.bvalid.value and timeout < 100:
        await RisingEdge(dut.clk)
        timeout += 1
        
    if timeout >= 100:
        dut._log.error("Timeout waiting for bvalid")
        assert False, "Slave did not assert bvalid"
    
    # Check write response
    write_resp = dut.axi_lite_if.bresp.value
    dut._log.info(f"Write response: {int(write_resp)}")
    assert int(write_resp) == 0, f"Expected OKAY response (0), got {int(write_resp)}"
    
    # Monitor for read transaction after write completes
    dut._log.info("Monitoring for read transaction")
    
    read_found = False
    for i in range(50):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.arvalid.value:
            dut._log.info(f"Found read transaction at cycle {i}")
            read_found = True
            break
    
    if not read_found:
        dut._log.error("Read transaction not found")
        assert False, "Master did not start read transaction"
    
    # Check read address
    read_addr = dut.axi_lite_if.araddr.value
    dut._log.info(f"Read address: 0x{int(read_addr):08x}")
    
    # Wait for read data
    timeout = 0
    while not dut.axi_lite_if.rvalid.value and timeout < 100:
        await RisingEdge(dut.clk)
        timeout += 1
        
    if timeout >= 100:
        dut._log.error("Timeout waiting for rvalid")
        assert False, "Slave did not assert rvalid"
    
    # Check read data
    read_data = dut.axi_lite_if.rdata.value
    read_resp = dut.axi_lite_if.rresp.value
    dut._log.info(f"Read data: 0x{int(read_data):08x}, response: {int(read_resp)}")
    
    # Verify read response is OKAY
    assert int(read_resp) == 0, f"Expected OKAY response (0), got {int(read_resp)}"
    
    # Verify read data matches written data
    if int(read_addr) == int(write_addr):
        assert int(read_data) == int(write_data), f"Read data mismatch: expected 0x{int(write_data):08x}, got 0x{int(read_data):08x}"
        dut._log.info("✓ Read data matches written data")
    else:
        dut._log.warning(f"Read address (0x{int(read_addr):08x}) != write address (0x{int(write_addr):08x})")
    
    # Wait for transaction to complete
    for _ in range(10):
        await RisingEdge(dut.clk)
    
    dut._log.info("✓ AXI Lite protocol test completed successfully")

@cocotb.test()
async def test_axi_lite_protocol_compliance(dut):
    """Test AXI Lite protocol compliance"""
    
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Wait for reset to propagate
    for _ in range(10):
        await RisingEdge(dut.clk)
    
    dut._log.info("Testing AXI Lite protocol compliance")
    
    # Test 1: Check that all signals are properly initialized
    dut._log.info("Test 1: Signal initialization")
    
    # Initially, no valid signals should be asserted
    assert not dut.axi_lite_if.awvalid.value, "awvalid should be low initially"
    assert not dut.axi_lite_if.wvalid.value, "wvalid should be low initially"
    assert not dut.axi_lite_if.arvalid.value, "arvalid should be low initially"
    
    dut._log.info("✓ All signals properly initialized")
    
    # Test 2: Monitor write transaction handshakes
    dut._log.info("Test 2: Write transaction handshakes")
    
    # Wait for write address handshake
    aw_handshake_found = False
    for i in range(100):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.awvalid.value and dut.axi_lite_if.awready.value:
            aw_handshake_found = True
            dut._log.info(f"✓ Write address handshake at cycle {i}")
            break
    
    assert aw_handshake_found, "Write address handshake not found"
    
    # Wait for write data handshake
    w_handshake_found = False
    for i in range(100):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.wvalid.value and dut.axi_lite_if.wready.value:
            w_handshake_found = True
            dut._log.info(f"✓ Write data handshake at cycle {i}")
            break
    
    assert w_handshake_found, "Write data handshake not found"
    
    # Wait for write response handshake
    b_handshake_found = False
    for i in range(100):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.bvalid.value and dut.axi_lite_if.bready.value:
            b_handshake_found = True
            dut._log.info(f"✓ Write response handshake at cycle {i}")
            break
    
    assert b_handshake_found, "Write response handshake not found"
    
    # Test 3: Monitor read transaction handshakes
    dut._log.info("Test 3: Read transaction handshakes")
    
    # Wait for read address handshake
    ar_handshake_found = False
    for i in range(100):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.arvalid.value and dut.axi_lite_if.arready.value:
            ar_handshake_found = True
            dut._log.info(f"✓ Read address handshake at cycle {i}")
            break
    
    assert ar_handshake_found, "Read address handshake not found"
    
    # Wait for read data handshake
    r_handshake_found = False
    for i in range(100):
        await RisingEdge(dut.clk)
        if dut.axi_lite_if.rvalid.value and dut.axi_lite_if.rready.value:
            r_handshake_found = True
            dut._log.info(f"✓ Read data handshake at cycle {i}")
            break
    
    assert r_handshake_found, "Read data handshake not found"
    
    dut._log.info("✓ AXI Lite protocol compliance test passed")