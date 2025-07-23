class axi_lite_ral_model extends uvm_reg_block;

    // Register definitions
    rand uvm_reg_field addr;
    rand uvm_reg_field data;
    rand uvm_reg_field ctrl;

    // Constructor
    function new(string name = "axi_lite_ral_model");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    // Build phase
    virtual function void build();
        // Create registers
        addr = uvm_reg_field::type_id::create("addr");
        data = uvm_reg_field::type_id::create("data");
        ctrl = uvm_reg_field::type_id::create("ctrl");

        // Configure registers
        addr.configure(this, 32, 0, "RW", 0, 32'h0000_0000, 1, 1, 1);
        data.configure(this, 32, 0, "RW", 0, 32'h0000_0000, 1, 1, 1);
        ctrl.configure(this, 32, 0, "RW", 0, 32'h0000_0000, 1, 1, 1);
    endfunction

    // Access methods
    virtual function void write(uvm_reg_addr_t offset, uvm_reg_data_t data);
        case (offset)
            'h00: addr.write(status, data);
            'h04: this.data.write(status, data);
            'h08: ctrl.write(status, data);
            default: `uvm_error("RAL_MODEL", $sformatf("Invalid offset: 'h%0h", offset))
        endcase
    endfunction

    virtual function uvm_reg_data_t read(uvm_reg_addr_t offset);
        case (offset)
            'h00: return addr.read(status);
            'h04: return this.data.read(status);
            'h08: return ctrl.read(status);
            default: `uvm_error("RAL_MODEL", $sformatf("Invalid offset: 'h%0h", offset))
        endcase
    endfunction

endclass