interface axi_lite_interface #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_n
);

    // Write address channel
    logic [ADDR_WIDTH-1:0] awaddr;
    logic awvalid;
    logic awready;

    // Write data channel
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic wvalid;
    logic wready;

    // Write response channel
    logic [1:0] bresp;
    logic bvalid;
    logic bready;

    // Read address channel
    logic [ADDR_WIDTH-1:0] araddr;
    logic arvalid;
    logic arready;

    // Read data channel
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic rvalid;
    logic rready;

    // Modport for master
    modport master (
        input clk,
        input rst_n,

        // Write address channel
        output awaddr,
        output awvalid,
        input awready,

        // Write data channel
        output wdata,
        output wstrb,
        output wvalid,
        input wready,

        // Write response channel
        input bresp,
        input bvalid,
        output bready,

        // Read address channel
        output araddr,
        output arvalid,
        input arready,

        // Read data channel
        input rdata,
        input rresp,
        input rvalid,
        output rready
    );

    // Modport for slave
    modport slave (
        input clk,
        input rst_n,

        // Write address channel
        input awaddr,
        input awvalid,
        output awready,

        // Write data channel
        input wdata,
        input wstrb,
        input wvalid,
        output wready,

        // Write response channel
        output bresp,
        output bvalid,
        input bready,

        // Read address channel
        input araddr,
        input arvalid,
        output arready,

        // Read data channel
        output rdata,
        output rresp,
        output rvalid,
        input rready
    );

endinterface