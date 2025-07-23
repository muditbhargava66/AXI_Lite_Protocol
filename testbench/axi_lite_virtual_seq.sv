// AXI Lite Virtual Sequence
// Coordinates multiple sequences and provides test scenarios

`ifndef AXI_LITE_VIRTUAL_SEQ_SV
`define AXI_LITE_VIRTUAL_SEQ_SV

class axi_lite_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(axi_lite_virtual_sequence)
    
    // Sequencer handle
    axi_lite_sequencer m_sequencer;
    
    function new(string name = "axi_lite_virtual_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        `uvm_info("VIRTUAL_SEQ", "Starting virtual sequence", UVM_LOW)
        
        // Run basic sequence first
        run_basic_test();
        
        // Run random sequence
        run_random_test();
        
        // Run stress test
        run_stress_test();
        
        `uvm_info("VIRTUAL_SEQ", "Virtual sequence completed", UVM_LOW)
    endtask
    
    virtual task run_basic_test();
        axi_lite_basic_sequence basic_seq;
        
        `uvm_info("VIRTUAL_SEQ", "Running basic test", UVM_LOW)
        basic_seq = axi_lite_basic_sequence::type_id::create("basic_seq");
        basic_seq.num_transactions = 10;
        basic_seq.start(m_sequencer);
    endtask
    
    virtual task run_random_test();
        axi_lite_random_sequence random_seq;
        
        `uvm_info("VIRTUAL_SEQ", "Running random test", UVM_LOW)
        random_seq = axi_lite_random_sequence::type_id::create("random_seq");
        random_seq.num_transactions = 20;
        random_seq.start(m_sequencer);
    endtask
    
    virtual task run_stress_test();
        axi_lite_stress_sequence stress_seq;
        
        `uvm_info("VIRTUAL_SEQ", "Running stress test", UVM_LOW)
        stress_seq = axi_lite_stress_sequence::type_id::create("stress_seq");
        stress_seq.num_transactions = 30;
        stress_seq.start(m_sequencer);
    endtask
    
endclass

// Specific test scenarios
class axi_lite_sanity_virtual_seq extends axi_lite_virtual_sequence;
    `uvm_object_utils(axi_lite_sanity_virtual_seq)
    
    function new(string name = "axi_lite_sanity_virtual_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_basic_sequence basic_seq;
        
        `uvm_info("VIRTUAL_SEQ", "Running sanity test", UVM_LOW)
        basic_seq = axi_lite_basic_sequence::type_id::create("sanity_seq");
        basic_seq.num_transactions = 5;
        basic_seq.start(m_sequencer);
    endtask
    
endclass

class axi_lite_regression_virtual_seq extends axi_lite_virtual_sequence;
    `uvm_object_utils(axi_lite_regression_virtual_seq)
    
    function new(string name = "axi_lite_regression_virtual_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        axi_lite_basic_sequence basic_seq;
        axi_lite_random_sequence random_seq;
        axi_lite_addr_walk_sequence walk_seq;
        
        `uvm_info("VIRTUAL_SEQ", "Running regression test", UVM_LOW)
        
        // Basic functionality
        basic_seq = axi_lite_basic_sequence::type_id::create("regression_basic");
        basic_seq.num_transactions = 10;
        basic_seq.start(m_sequencer);
        
        // Random testing
        random_seq = axi_lite_random_sequence::type_id::create("regression_random");
        random_seq.num_transactions = 50;
        random_seq.start(m_sequencer);
        
        // Address walking
        walk_seq = axi_lite_addr_walk_sequence::type_id::create("regression_walk");
        walk_seq.start(m_sequencer);
        
        `uvm_info("VIRTUAL_SEQ", "Regression test completed", UVM_LOW)
    endtask
    
endclass

`endif // AXI_LITE_VIRTUAL_SEQ_SV