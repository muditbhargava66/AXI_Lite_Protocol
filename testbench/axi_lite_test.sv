// AXI Lite Test
// Top-level test that sets up the environment and runs sequences

`ifndef AXI_LITE_TEST_SV
`define AXI_LITE_TEST_SV

// Include all verification components
`include "axi_lite_env.sv"
`include "axi_lite_agent.sv"
`include "axi_lite_sequencer.sv"
`include "axi_lite_driver.sv"
`include "axi_lite_monitor.sv"
`include "axi_lite_scoreboard.sv"
`include "axi_lite_seq_lib.sv"
`include "axi_lite_virtual_seq.sv"

// Base test class
class axi_lite_base_test extends uvm_test;
    `uvm_component_utils(axi_lite_base_test)
    
    // Environment
    axi_lite_env m_env;
    axi_lite_config m_config;
    
    // Virtual interface
    virtual axi_lite_interface vif;
    
    function new(string name = "axi_lite_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get virtual interface
        if (!uvm_config_db#(virtual axi_lite_interface)::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST", "Failed to get virtual interface")
        end
        
        // Create configuration
        m_config = axi_lite_config::type_id::create("m_config");
        m_config.vif = vif;
        m_config.is_active = 1;
        
        // Set configuration in database
        uvm_config_db#(axi_lite_config)::set(this, "*", "config", m_config);
        
        // Create environment
        m_env = axi_lite_env::type_id::create("m_env", this);
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Wait for reset
        wait(vif.rst_n);
        repeat(10) @(posedge vif.clk);
        
        // Run default sequence
        run_test_sequence();
        
        // Wait for completion
        repeat(100) @(posedge vif.clk);
        
        phase.drop_objection(this);
    endtask
    
    virtual task run_test_sequence();
        // Override in derived tests
        `uvm_info("TEST", "Base test - no sequence run", UVM_LOW)
    endtask
    
endclass

// Sanity test
class axi_lite_sanity_test extends axi_lite_base_test;
    `uvm_component_utils(axi_lite_sanity_test)
    
    function new(string name = "axi_lite_sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_test_sequence();
        axi_lite_sanity_virtual_seq vseq;
        
        `uvm_info("TEST", "Running sanity test", UVM_LOW)
        vseq = axi_lite_sanity_virtual_seq::type_id::create("sanity_vseq");
        vseq.m_sequencer = m_env.m_agent.m_sequencer;
        vseq.start(null);
    endtask
    
endclass

// Basic test
class axi_lite_basic_test extends axi_lite_base_test;
    `uvm_component_utils(axi_lite_basic_test)
    
    function new(string name = "axi_lite_basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_test_sequence();
        axi_lite_basic_sequence seq;
        
        `uvm_info("TEST", "Running basic test", UVM_LOW)
        seq = axi_lite_basic_sequence::type_id::create("basic_seq");
        seq.num_transactions = 10;
        seq.start(m_env.m_agent.m_sequencer);
    endtask
    
endclass

// Random test
class axi_lite_random_test extends axi_lite_base_test;
    `uvm_component_utils(axi_lite_random_test)
    
    function new(string name = "axi_lite_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_test_sequence();
        axi_lite_random_sequence seq;
        
        `uvm_info("TEST", "Running random test", UVM_LOW)
        seq = axi_lite_random_sequence::type_id::create("random_seq");
        seq.num_transactions = 50;
        seq.start(m_env.m_agent.m_sequencer);
    endtask
    
endclass

// Regression test
class axi_lite_regression_test extends axi_lite_base_test;
    `uvm_component_utils(axi_lite_regression_test)
    
    function new(string name = "axi_lite_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_test_sequence();
        axi_lite_regression_virtual_seq vseq;
        
        `uvm_info("TEST", "Running regression test", UVM_LOW)
        vseq = axi_lite_regression_virtual_seq::type_id::create("regression_vseq");
        vseq.m_sequencer = m_env.m_agent.m_sequencer;
        vseq.start(null);
    endtask
    
endclass

`endif // AXI_LITE_TEST_SV