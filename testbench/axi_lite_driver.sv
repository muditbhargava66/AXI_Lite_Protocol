// AXI Lite Driver
// Drives transactions on the AXI Lite interface

`ifndef AXI_LITE_DRIVER_SV
`define AXI_LITE_DRIVER_SV

class axi_lite_driver extends uvm_driver#(axi_lite_transaction);
    `uvm_component_utils(axi_lite_driver)
    
    // Virtual interface
    virtual axi_lite_interface vif;
    
    // Configuration
    axi_lite_config m_config;
    
    function new(string name = "axi_lite_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration
        if (!uvm_config_db#(axi_lite_config)::get(this, "", "config", m_config)) begin
            `uvm_fatal("DRIVER", "Failed to get configuration")
        end
        
        vif = m_config.vif;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        axi_lite_transaction req;
        
        // Initialize signals
        vif.awvalid <= 0;
        vif.wvalid <= 0;
        vif.bready <= 0;
        vif.arvalid <= 0;
        vif.rready <= 0;
        
        // Wait for reset deassertion
        wait(vif.rst_n);
        @(posedge vif.clk);
        
        forever begin
            seq_item_port.get_next_item(req);
            
            if (req.is_write) begin
                drive_write(req);
            end else begin
                drive_read(req);
            end
            
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_write(axi_lite_transaction req);
        `uvm_info("DRIVER", $sformatf("Driving write: %s", req.convert2string()), UVM_MEDIUM)
        
        // Write address phase
        @(posedge vif.clk);
        vif.awaddr <= req.addr;
        vif.awvalid <= 1;
        
        // Wait for address ready
        while (!vif.awready) @(posedge vif.clk);
        vif.awvalid <= 0;
        
        // Write data phase
        vif.wdata <= req.data;
        vif.wstrb <= req.strb;
        vif.wvalid <= 1;
        
        // Wait for data ready
        while (!vif.wready) @(posedge vif.clk);
        vif.wvalid <= 0;
        
        // Write response phase
        vif.bready <= 1;
        while (!vif.bvalid) @(posedge vif.clk);
        
        req.resp = vif.bresp;
        @(posedge vif.clk);
        vif.bready <= 0;
        
        `uvm_info("DRIVER", $sformatf("Write complete: resp=%b", req.resp), UVM_MEDIUM)
    endtask
    
    virtual task drive_read(axi_lite_transaction req);
        `uvm_info("DRIVER", $sformatf("Driving read: %s", req.convert2string()), UVM_MEDIUM)
        
        // Read address phase
        @(posedge vif.clk);
        vif.araddr <= req.addr;
        vif.arvalid <= 1;
        
        // Wait for address ready
        while (!vif.arready) @(posedge vif.clk);
        vif.arvalid <= 0;
        
        // Read data phase
        vif.rready <= 1;
        while (!vif.rvalid) @(posedge vif.clk);
        
        req.rdata = vif.rdata;
        req.resp = vif.rresp;
        @(posedge vif.clk);
        vif.rready <= 0;
        
        `uvm_info("DRIVER", $sformatf("Read complete: data=0x%08x, resp=%b", req.rdata, req.resp), UVM_MEDIUM)
    endtask
    
endclass

`endif // AXI_LITE_DRIVER_SV