module tb_top;
    `ifdef UVM_TEST
    import uvm_pkg::*;
    `endif
    
    // Clock and reset signals
    logic clk;
    logic rst_n;

    // Instantiate the AXI Lite interface
    axi_lite_interface #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32)
    ) axi_lite_if (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Instantiate the AXI Lite master module (only for cocotb testing)
    `ifndef UVM_TEST
    axi_lite_master master (
        .clk(clk),
        .rst_n(rst_n),
        .awaddr(axi_lite_if.awaddr),
        .awvalid(axi_lite_if.awvalid),
        .awready(axi_lite_if.awready),
        .wdata(axi_lite_if.wdata),
        .wstrb(axi_lite_if.wstrb),
        .wvalid(axi_lite_if.wvalid),
        .wready(axi_lite_if.wready),
        .bresp(axi_lite_if.bresp),
        .bvalid(axi_lite_if.bvalid),
        .bready(axi_lite_if.bready),
        .araddr(axi_lite_if.araddr),
        .arvalid(axi_lite_if.arvalid),
        .arready(axi_lite_if.arready),
        .rdata(axi_lite_if.rdata),
        .rresp(axi_lite_if.rresp),
        .rvalid(axi_lite_if.rvalid),
        .rready(axi_lite_if.rready)
    );
    `endif

    // Always instantiate the slave
    axi_lite_slave slave (
        .clk(clk),
        .rst_n(rst_n),
        .awaddr(axi_lite_if.awaddr),
        .awvalid(axi_lite_if.awvalid),
        .awready(axi_lite_if.awready),
        .wdata(axi_lite_if.wdata),
        .wstrb(axi_lite_if.wstrb),
        .wvalid(axi_lite_if.wvalid),
        .wready(axi_lite_if.wready),
        .bresp(axi_lite_if.bresp),
        .bvalid(axi_lite_if.bvalid),
        .bready(axi_lite_if.bready),
        .araddr(axi_lite_if.araddr),
        .arvalid(axi_lite_if.arvalid),
        .arready(axi_lite_if.arready),
        .rdata(axi_lite_if.rdata),
        .rresp(axi_lite_if.rresp),
        .rvalid(axi_lite_if.rvalid),
        .rready(axi_lite_if.rready)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        clk = 0;
        rst_n = 0;
        #10 rst_n = 1;
    end

    // UVM test initialization
    `ifdef UVM_TEST
    initial begin
        // Set interface in config database
        uvm_config_db#(virtual axi_lite_interface)::set(null, "*", "vif", axi_lite_if);
        
        // Run the test
        run_test();
    end
    `endif
    
endmodule