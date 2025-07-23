// AXI Lite Scoreboard
// Checks correctness of AXI Lite transactions

`ifndef AXI_LITE_SCOREBOARD_SV
`define AXI_LITE_SCOREBOARD_SV

class axi_lite_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_lite_scoreboard)
    
    // Analysis export for receiving transactions from monitor
    uvm_analysis_export#(axi_lite_transaction) analysis_export;
    
    // Internal mailbox for transaction processing
    uvm_tlm_analysis_fifo#(axi_lite_transaction) trans_fifo;
    
    // Memory model for checking
    bit [31:0] memory [bit [31:0]];
    
    // Statistics
    int write_count = 0;
    int read_count = 0;
    int error_count = 0;
    
    function new(string name = "axi_lite_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        trans_fifo = new("trans_fifo", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        analysis_export.connect(trans_fifo.analysis_export);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        axi_lite_transaction trans;
        
        forever begin
            trans_fifo.get(trans);
            check_transaction(trans);
        end
    endtask
    
    virtual function void check_transaction(axi_lite_transaction trans);
        if (trans.is_write) begin
            check_write_transaction(trans);
        end else begin
            check_read_transaction(trans);
        end
    endfunction
    
    virtual function void check_write_transaction(axi_lite_transaction trans);
        write_count++;
        
        // Check response
        if (trans.resp != 2'b00) begin
            `uvm_error("SCOREBOARD", $sformatf("Write error response: addr=0x%08x, resp=%b", trans.addr, trans.resp))
            error_count++;
            return;
        end
        
        // Update memory model
        memory[trans.addr] = trans.data;
        
        `uvm_info("SCOREBOARD", $sformatf("Write OK: addr=0x%08x, data=0x%08x", trans.addr, trans.data), UVM_HIGH)
    endfunction
    
    virtual function void check_read_transaction(axi_lite_transaction trans);
        bit [31:0] expected_data;
        read_count++;
        
        // Check response
        if (trans.resp != 2'b00) begin
            `uvm_error("SCOREBOARD", $sformatf("Read error response: addr=0x%08x, resp=%b", trans.addr, trans.resp))
            error_count++;
            return;
        end
        
        // Check data if address was previously written
        if (memory.exists(trans.addr)) begin
            expected_data = memory[trans.addr];
            if (trans.rdata !== expected_data) begin
                `uvm_error("SCOREBOARD", $sformatf("Read data mismatch: addr=0x%08x, expected=0x%08x, actual=0x%08x", 
                          trans.addr, expected_data, trans.rdata))
                error_count++;
                return;
            end
        end
        
        `uvm_info("SCOREBOARD", $sformatf("Read OK: addr=0x%08x, data=0x%08x", trans.addr, trans.rdata), UVM_HIGH)
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("SCOREBOARD", "=== FINAL REPORT ===", UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Write transactions: %0d", write_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Read transactions: %0d", read_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Total transactions: %0d", write_count + read_count), UVM_LOW)
        `uvm_info("SCOREBOARD", $sformatf("Errors: %0d", error_count), UVM_LOW)
        
        if (error_count == 0) begin
            `uvm_info("SCOREBOARD", "*** TEST PASSED ***", UVM_LOW)
        end else begin
            `uvm_error("SCOREBOARD", "*** TEST FAILED ***")
        end
    endfunction
    
endclass

`endif // AXI_LITE_SCOREBOARD_SV