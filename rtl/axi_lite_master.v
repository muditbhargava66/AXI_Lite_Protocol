module axi_lite_master (
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,

    // AXI Lite interface
    output reg [31:0] awaddr,
    output reg        awvalid,
    input  wire        awready,
    output reg [31:0] wdata,
    output reg [3:0]  wstrb,
    output reg        wvalid,
    input  wire        wready,
    input  wire [1:0]  bresp,
    input  wire        bvalid,
    output reg        bready,
    output reg [31:0] araddr,
    output reg        arvalid,
    input  wire        arready,
    input  wire [31:0] rdata,
    input  wire [1:0]  rresp,
    input  wire        rvalid,
    output reg        rready
);

    // FSM states
    localparam IDLE       = 4'b0000;
    localparam WRITE_ADDR = 4'b0001;
    localparam WRITE_DATA = 4'b0010;
    localparam WRITE_RESP = 4'b0011;
    localparam READ_ADDR  = 4'b0100;
    localparam READ_DATA  = 4'b0101;
    localparam DONE       = 4'b0110;

    // Internal registers
    reg [3:0] state, next_state;
    reg [31:0] test_addr;
    reg [31:0] test_data;
    reg [7:0] delay_counter;
    reg write_done, read_done;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            delay_counter <= 8'd10; // Initial delay
        end else begin
            if (delay_counter > 0) begin
                delay_counter <= delay_counter - 1;
            end else begin
                state <= next_state;
            end
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!write_done) begin
                    next_state = WRITE_ADDR;
                end else if (!read_done) begin
                    next_state = READ_ADDR;
                end else begin
                    next_state = DONE;
                end
            end

            WRITE_ADDR: begin
                if (awvalid && awready) begin
                    next_state = WRITE_DATA;
                end
            end

            WRITE_DATA: begin
                if (wvalid && wready) begin
                    next_state = WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                if (bvalid && bready) begin
                    next_state = IDLE;
                end
            end

            READ_ADDR: begin
                if (arvalid && arready) begin
                    next_state = READ_DATA;
                end
            end

            READ_DATA: begin
                if (rvalid && rready) begin
                    next_state = IDLE;
                end
            end

            DONE: begin
                next_state = DONE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awaddr   <= 32'h0;
            awvalid  <= 1'b0;
            wdata    <= 32'h0;
            wstrb    <= 4'h0;
            wvalid   <= 1'b0;
            bready   <= 1'b0;
            araddr   <= 32'h0;
            arvalid  <= 1'b0;
            rready   <= 1'b0;
            test_addr <= 32'h1000;
            test_data <= 32'hDEADBEEF;
            write_done <= 1'b0;
            read_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    awvalid  <= 1'b0;
                    wvalid   <= 1'b0;
                    bready   <= 1'b0;
                    arvalid  <= 1'b0;
                    rready   <= 1'b0;
                end

                WRITE_ADDR: begin
                    awaddr   <= test_addr;
                    awvalid  <= 1'b1;
                    if (awvalid && awready) begin
                        awvalid <= 1'b0;
                    end
                end

                WRITE_DATA: begin
                    wdata    <= test_data;
                    wstrb    <= 4'hF;
                    wvalid   <= 1'b1;
                    if (wvalid && wready) begin
                        wvalid <= 1'b0;
                    end
                end

                WRITE_RESP: begin
                    bready   <= 1'b1;
                    if (bvalid && bready) begin
                        bready <= 1'b0;
                        write_done <= 1'b1;
                        delay_counter <= 8'd5; // Add delay before read
                    end
                end

                READ_ADDR: begin
                    araddr   <= test_addr;
                    arvalid  <= 1'b1;
                    if (arvalid && arready) begin
                        arvalid <= 1'b0;
                    end
                end

                READ_DATA: begin
                    rready   <= 1'b1;
                    if (rvalid && rready) begin
                        rready <= 1'b0;
                        read_done <= 1'b1;
                    end
                end

                DONE: begin
                    // Stay in done state
                end

                default: begin
                    awvalid  <= 1'b0;
                    wvalid   <= 1'b0;
                    bready   <= 1'b0;
                    arvalid  <= 1'b0;
                    rready   <= 1'b0;
                end
            endcase
        end
    end

endmodule