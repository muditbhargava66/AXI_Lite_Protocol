// AXI Lite Sequence Library
// Contains various test sequences for AXI Lite verification

`ifndef AXI_LITE_SEQ_LIB_SV
`define AXI_LITE_SEQ_LIB_SV

// Base sequence
class axi_lite_base_sequence extends uvm_sequence#(axi_lite_transaction);
    `uvm_object_utils(axi_lite_base_sequence)
    
    function new(string name = "axi_lite_base_sequence");
        super.new(name);
    endfunction
    
endclass

// Basic write-read sequence
class axi_lite_basic_sequence extends axi_lite_base_sequence;
    `uvm_object_utils(axi_lite_basic_sequence)
    
    int num_transactions = 5;
    
    function new(string name = "axi_lite_basic_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_transaction req;
        bit [31:0] test_addr;
        bit [31:0] test_data;
        
        `uvm_info("SEQUENCE", "Starting basic write-read sequence", UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            test_addr = 32'h1000 + (i * 4);
            test_data = 32'hDEAD0000 + i;
            
            // Write transaction
            req = axi_lite_transaction::type_id::create("write_req");
            start_item(req);
            assert(req.randomize() with {
                addr == test_addr;
                data == test_data;
                is_write == 1;
            });
            finish_item(req);
            
            // Read transaction
            req = axi_lite_transaction::type_id::create("read_req");
            start_item(req);
            assert(req.randomize() with {
                addr == test_addr;
                is_write == 0;
            });
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Basic write-read sequence completed", UVM_LOW)
    endtask
    
endclass

// Random sequence
class axi_lite_random_sequence extends axi_lite_base_sequence;
    `uvm_object_utils(axi_lite_random_sequence)
    
    int num_transactions = 20;
    
    function new(string name = "axi_lite_random_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_transaction req;
        
        `uvm_info("SEQUENCE", "Starting random sequence", UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            req = axi_lite_transaction::type_id::create("random_req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Random sequence completed", UVM_LOW)
    endtask
    
endclass

// Stress sequence - back-to-back transactions
class axi_lite_stress_sequence extends axi_lite_base_sequence;
    `uvm_object_utils(axi_lite_stress_sequence)
    
    int num_transactions = 50;
    
    function new(string name = "axi_lite_stress_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_transaction req;
        
        `uvm_info("SEQUENCE", "Starting stress sequence", UVM_LOW)
        
        for (int i = 0; i < num_transactions; i++) begin
            req = axi_lite_transaction::type_id::create("stress_req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
            
            // No delay between transactions for stress testing
        end
        
        `uvm_info("SEQUENCE", "Stress sequence completed", UVM_LOW)
    endtask
    
endclass

// Address walking sequence
class axi_lite_addr_walk_sequence extends axi_lite_base_sequence;
    `uvm_object_utils(axi_lite_addr_walk_sequence)
    
    function new(string name = "axi_lite_addr_walk_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_transaction req;
        bit [31:0] addr_pattern;
        
        `uvm_info("SEQUENCE", "Starting address walking sequence", UVM_LOW)
        
        // Walking 1s pattern
        for (int i = 0; i < 32; i++) begin
            addr_pattern = 32'h1000 + (1 << i);
            
            // Write
            req = axi_lite_transaction::type_id::create("walk_write");
            start_item(req);
            assert(req.randomize() with {
                addr == (addr_pattern & 32'hFFFFFFFC); // Word aligned
                is_write == 1;
            });
            finish_item(req);
            
            // Read back
            req = axi_lite_transaction::type_id::create("walk_read");
            start_item(req);
            assert(req.randomize() with {
                addr == (addr_pattern & 32'hFFFFFFFC);
                is_write == 0;
            });
            finish_item(req);
        end
        
        `uvm_info("SEQUENCE", "Address walking sequence completed", UVM_LOW)
    endtask
    
endclass

`endif // AXI_LITE_SEQ_LIB_SV