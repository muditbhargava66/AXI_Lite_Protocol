// AXI Lite Monitor
// Monitors AXI Lite interface and reports transactions

`ifndef AXI_LITE_MONITOR_SV
`define AXI_LITE_MONITOR_SV

class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)
    
    // Virtual interface
    virtual axi_lite_interface vif;
    
    // Analysis port for sending transactions to scoreboard
    uvm_analysis_port#(axi_lite_transaction) analysis_port;
    
    // Configuration
    axi_lite_config m_config;
    
    function new(string name = "axi_lite_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", m_config)) begin
            `uvm_fatal("MONITOR", "Failed to get configuration")
        end
        
        vif = m_config.vif;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // Wait for reset deassertion
        wait(vif.rst_n);
        @(posedge vif.clk);
        
        fork
            monitor_write();
            monitor_read();
        join
    endtask
    
    virtual task monitor_write();
        axi_lite_transaction trans;
        
        forever begin
            // Wait for write address valid
            @(posedge vif.clk);
            if (vif.awvalid && vif.awready) begin
                trans = axi_lite_transaction::type_id::create("write_trans");
                trans.addr = vif.awaddr;
                trans.is_write = 1;
                
                // Wait for write data
                while (!(vif.wvalid && vif.wready)) @(posedge vif.clk);
                trans.data = vif.wdata;
                trans.strb = vif.wstrb;
                
                // Wait for write response
                while (!(vif.bvalid && vif.bready)) @(posedge vif.clk);
                trans.resp = vif.bresp;
                
                `uvm_info("MONITOR", $sformatf("Write transaction: %s", trans.convert2string()), UVM_MEDIUM)
                analysis_port.write(trans);
            end
        end
    endtask
    
    virtual task monitor_read();
        axi_lite_transaction trans;
        
        forever begin
            // Wait for read address valid
            @(posedge vif.clk);
            if (vif.arvalid && vif.arready) begin
                trans = axi_lite_transaction::type_id::create("read_trans");
                trans.addr = vif.araddr;
                trans.is_write = 0;
                
                // Wait for read data
                while (!(vif.rvalid && vif.rready)) @(posedge vif.clk);
                trans.rdata = vif.rdata;
                trans.resp = vif.rresp;
                
                `uvm_info("MONITOR", $sformatf("Read transaction: %s", trans.convert2string()), UVM_MEDIUM)
                analysis_port.write(trans);
            end
        end
    endtask
    
endclass

`endif // AXI_LITE_MONITOR_SV