module axi_lite_slave (
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,

    // AXI Lite interface
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output reg         awready,
    input  wire [31:0] wdata,
    input  wire [3:0]  wstrb,
    input  wire        wvalid,
    output reg         wready,
    output reg [1:0]   bresp,
    output reg         bvalid,
    input  wire        bready,
    input  wire [31:0] araddr,
    input  wire        arvalid,
    output reg         arready,
    output reg [31:0]  rdata,
    output reg [1:0]   rresp,
    output reg         rvalid,
    input  wire        rready
);

    // FSM states
    localparam IDLE   = 3'b000;
    localparam WRITE  = 3'b001;
    localparam READ   = 3'b010;
    localparam BRESP  = 3'b011;
    localparam RRESP  = 3'b100;

    // Internal registers
    reg [2:0] state;
    reg [2:0] next_state;

    // Internal memory
    reg [31:0] mem [0:255];

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (awvalid) begin
                    next_state = WRITE;
                end else if (arvalid) begin
                    next_state = READ;
                end else begin
                    next_state = IDLE;
                end
            end

            WRITE: begin
                if (wvalid) begin
                    next_state = BRESP;
                end else begin
                    next_state = WRITE;
                end
            end

            READ: begin
                next_state = RRESP;
            end

            BRESP: begin
                if (bready) begin
                    next_state = IDLE;
                end else begin
                    next_state = BRESP;
                end
            end

            RRESP: begin
                if (rready) begin
                    next_state = IDLE;
                end else begin
                    next_state = RRESP;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awready  <= 1'b0;
            wready   <= 1'b0;
            bresp    <= 2'b00;
            bvalid   <= 1'b0;
            arready  <= 1'b0;
            rdata    <= 32'h0;
            rresp    <= 2'b00;
            rvalid   <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    awready  <= 1'b1;
                    wready   <= 1'b0;
                    bvalid   <= 1'b0;
                    arready  <= 1'b1;
                    rvalid   <= 1'b0;
                end

                WRITE: begin
                    awready  <= 1'b0;
                    wready   <= 1'b1;
                end

                READ: begin
                    arready  <= 1'b0;
                    rdata    <= mem[araddr[9:2]];
                    rresp    <= 2'b00;
                    rvalid   <= 1'b1;
                end

                BRESP: begin
                    bresp    <= 2'b00;
                    bvalid   <= 1'b1;
                end

                RRESP: begin
                    rvalid   <= 1'b0;
                end

                default: begin
                    awready  <= 1'b0;
                    wready   <= 1'b0;
                    bvalid   <= 1'b0;
                    arready  <= 1'b0;
                    rvalid   <= 1'b0;
                end
            endcase
        end
    end

    // Memory write logic
    always @(posedge clk) begin
        if (state == WRITE && wvalid) begin
            if (wstrb[0]) mem[awaddr[9:2]][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[awaddr[9:2]][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[awaddr[9:2]][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[awaddr[9:2]][31:24] <= wdata[31:24];
        end
    end

endmodule