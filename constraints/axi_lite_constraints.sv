class axi_lite_constraints extends uvm_object;

    // Address constraints
    rand bit [31:0] addr;
    constraint addr_c {
        addr inside {[32'h0000_0000 : 32'hFFFF_FFFF]};
        addr[1:0] == 2'b00; // Word-aligned addresses
    }

    // Write data constraints
    rand bit [31:0] wdata;
    constraint wdata_c {
        wdata inside {[32'h0000_0000 : 32'hFFFF_FFFF]};
    }

    // Write strobe constraints
    rand bit [3:0] wstrb;
    constraint wstrb_c {
        wstrb inside {4'b0001, 4'b0010, 4'b0100, 4'b1000, 4'b0011, 4'b1100, 4'b1111};
    }

    // Burst type constraints
    rand bit [1:0] burst;
    constraint burst_c {
        burst inside {2'b00, 2'b01}; // Fixed and INCR bursts only
    }

    // Burst length constraints
    rand bit [7:0] len;
    constraint len_c {
        len inside {[1:16]}; // Burst length of 1 to 16 beats
    }

    // Size constraints
    rand bit [2:0] size;
    constraint size_c {
        size inside {3'b000, 3'b001, 3'b010}; // Byte, half-word, and word sizes only
    }

    // Constructor
    function new(string name = "axi_lite_constraints");
        super.new(name);
    endfunction

endclass