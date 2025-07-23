// AXI Lite Agent
// Contains driver, monitor, and sequencer for AXI Lite transactions

`ifndef AXI_LITE_AGENT_SV
`define AXI_LITE_AGENT_SV

class axi_lite_agent extends uvm_agent;
    `uvm_component_utils(axi_lite_agent)
    
    // Agent components
    axi_lite_driver    m_driver;
    axi_lite_monitor   m_monitor;
    axi_lite_sequencer m_sequencer;
    
    // Configuration
    axi_lite_config    m_config;
    
    function new(string name = "axi_lite_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", m_config)) begin
            `uvm_fatal("AGENT", "Failed to get configuration")
        end
        
        // Always create monitor
        m_monitor = axi_lite_monitor::type_id::create("m_monitor", this);
        uvm_config_db#(axi_lite_config)::set(this, "m_monitor", "config", m_config);
        
        // Create driver and sequencer only if active
        if (m_config.is_active) begin
            m_driver = axi_lite_driver::type_id::create("m_driver", this);
            m_sequencer = axi_lite_sequencer::type_id::create("m_sequencer", this);
            
            uvm_config_db#(axi_lite_config)::set(this, "m_driver", "config", m_config);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect driver to sequencer if active
        if (m_config.is_active) begin
            m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
        end
    endfunction
    
endclass

`endif // AXI_LITE_AGENT_SV