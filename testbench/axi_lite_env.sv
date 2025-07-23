// AXI Lite Environment
// This is the top-level verification environment that instantiates and connects
// all verification components

`ifndef AXI_LITE_ENV_SV
`define AXI_LITE_ENV_SV

class axi_lite_env extends uvm_env;
    `uvm_component_utils(axi_lite_env)
    
    // Verification components
    axi_lite_agent      m_agent;
    axi_lite_scoreboard m_scoreboard;
    
    // Configuration
    axi_lite_config     m_config;
    
    function new(string name = "axi_lite_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", m_config)) begin
            `uvm_fatal("ENV", "Failed to get configuration")
        end
        
        // Create agent
        m_agent = axi_lite_agent::type_id::create("m_agent", this);
        uvm_config_db#(axi_lite_config)::set(this, "m_agent", "config", m_config);
        
        // Create scoreboard
        m_scoreboard = axi_lite_scoreboard::type_id::create("m_scoreboard", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect agent monitor to scoreboard
        m_agent.m_monitor.analysis_port.connect(m_scoreboard.analysis_export);
    endfunction
    
endclass

// Configuration class
class axi_lite_config extends uvm_object;
    `uvm_object_utils(axi_lite_config)
    
    // Interface handle
    virtual axi_lite_interface vif;
    
    // Configuration parameters
    bit is_active = 1;
    int num_transactions = 10;
    
    function new(string name = "axi_lite_config");
        super.new(name);
    endfunction
    
endclass

`endif // AXI_LITE_ENV_SV