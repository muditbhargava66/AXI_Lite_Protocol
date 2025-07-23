// AXI Lite Sequencer
// Manages sequence items and coordinates with driver

`ifndef AXI_LITE_SEQUENCER_SV
`define AXI_LITE_SEQUENCER_SV

// Transaction item
class axi_lite_transaction extends uvm_sequence_item;
    `uvm_object_utils(axi_lite_transaction)
    
    // Transaction fields
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;
    rand bit        is_write;
    
    // Response fields
    bit [31:0] rdata;
    bit [1:0]  resp;
    
    // Constraints
    constraint addr_c {
        addr inside {[32'h1000:32'h1FFF]};
        addr[1:0] == 2'b00; // Word aligned
    }
    
    constraint strb_c {
        strb == 4'hF; // Full word writes
    }
    
    function new(string name = "axi_lite_transaction");
        super.new(name);
    endfunction
    
    virtual function string convert2string();
        return $sformatf("addr=0x%08x, data=0x%08x, strb=0x%x, is_write=%b, rdata=0x%08x, resp=%b",
                        addr, data, strb, is_write, rdata, resp);
    endfunction
    
endclass

// Sequencer
class axi_lite_sequencer extends uvm_sequencer#(axi_lite_transaction);
    `uvm_component_utils(axi_lite_sequencer)
    
    function new(string name = "axi_lite_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass

`endif // AXI_LITE_SEQUENCER_SV