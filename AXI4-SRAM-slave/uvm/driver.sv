class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)

    virtual duv_if vif;
    transaction trans;  

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "vif failed")
    endfunction

    virtual task rst(logic [`AXI_ADDR_BITS-1:0 ] awaddr);

        vif.ARESETn <= 'd1;
        
        vif.AWID    <= 'd0; 
        vif.AWADDR  <= awaddr;

        vif.AWLEN   <= 'd15;
        vif.AWSIZE  <= 'd2;
        vif.AWBURST <= 'd1;
        vif.AWVALID <= 'd1;

        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;
    
        vif.ARID    <= 'd0;
        vif.ARADDR  <= 'd0;
        vif.ARLEN   <= 'd0;
        vif.ARSIZE  <= 'd0;
        vif.ARBURST <= 'd0;
        vif.ARVALID <= 'd0;

        vif.RREADY  <= 'd0;

        wait (vif.AWREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 'd0;
        for (int i = 0; i < vif.AWLEN + 1; i++) begin
            vif.WVALID <= 'd1;
            vif.WDATA  <= 'd0;
            vif.WSTRB  <= 'b1111;
            if (i == vif.AWLEN) begin
                vif.WLAST <= 'd1;
            end else begin
                vif.WLAST <= 'd0;
            end
            wait (vif.WREADY);
            @(posedge vif.ACLK);
        end
        
        vif.BREADY <= 'd1;
        wait (vif.BVALID);
        @(negedge vif.BVALID);

        vif.AWID    <= 'd0; 
        vif.AWADDR  <= 'd0;
        vif.AWLEN   <= 'd0;
        vif.AWSIZE  <= 'd0;
        vif.AWBURST <= 'd0;
        vif.AWVALID <= 'd0;
                        
        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;
        @(posedge vif.ACLK);
    endtask
    
    virtual task WMODE(logic [`AXI_ADDR_BITS-1:0 ] awaddr, logic [`AXI_LEN_BITS-1:0] awlen, logic [`AXI_SIZE_BITS-1:0] awsize, int min, int max);
        vif.ARESETn <= 'd1;
        
        vif.AWID    <= 'd0; 
        vif.AWADDR  <= awaddr;

        vif.AWLEN   <= awlen;
        vif.AWSIZE  <= awsize;
        vif.AWBURST <= 'd1;
        vif.AWVALID <= 'd1;

        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;
    
        vif.ARID    <= 'd0;
        vif.ARADDR  <= 'd0;
        vif.ARLEN   <= 'd0;
        vif.ARSIZE  <= 'd0;
        vif.ARBURST <= 'd0;
        vif.ARVALID <= 'd0;

        vif.RREADY  <= 'd0;

        wait (vif.AWREADY);
        @(posedge vif.ACLK);
        vif.AWVALID <= 'd0;
        for (int i = 0; i < vif.AWLEN + 1; i++) begin
            vif.WVALID <= 'd1;
            case (awsize)
                0: vif.WSTRB <= 'b0001;
                1: vif.WSTRB <= $urandom_range(1, 3);
                2: vif.WSTRB <= $urandom_range(1, 15);
            endcase
            vif.WDATA <= $urandom_range(min, max);
            if (i == vif.AWLEN) begin
                vif.WLAST <= 'd1;
            end else begin
                vif.WLAST <= 'd0;
            end
            wait (vif.WREADY);
            @(posedge vif.ACLK);
        end
        
        vif.BREADY <= 'd1;
        wait (vif.BVALID);
        @(negedge vif.BVALID);

        vif.AWID    <= 'd0; 
        vif.AWADDR  <= 'd0;
        vif.AWLEN   <= 'd0;
        vif.AWSIZE  <= 'd0;
        vif.AWBURST <= 'd0;
        vif.AWVALID <= 'd0;
                        
        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;
    endtask

    virtual task RMODE(logic [`AXI_ADDR_BITS-1:0 ] araddr, logic [`AXI_LEN_BITS-1:0 ] arlen, logic [`AXI_SIZE_BITS-1:0] arsize);   

        vif.ARESETn <= 'd1;
        
        vif.AWID    <= 'd0; 
        vif.AWADDR  <= 'd0;
        vif.AWLEN   <= 'd0;
        vif.AWSIZE  <= 'd0;
        vif.AWBURST <= 'd0;
        vif.AWVALID <= 'd0;

        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;
    
        vif.ARID    <= 'd0;
        vif.ARADDR  <= araddr;

        vif.ARLEN   <= arlen;
        vif.ARSIZE  <= arsize;
        vif.ARBURST <= 'd1;
        vif.ARVALID <= 'd1;

        vif.RREADY  <= 'd0;

        wait (vif.ARREADY);
        @(posedge vif.ACLK);
        vif.ARVALID <= 'd0;
        
        vif.RREADY <= 'd1;
        for (int i = 0; i < vif.ARLEN + 1; i++) begin
            wait (vif.RVALID);
            @(posedge vif.ACLK);
        end

        @(negedge vif.RLAST);

        vif.AWID    <= 'd0; 
        vif.AWADDR  <= 'd0;
        vif.AWLEN   <= 'd0;
        vif.AWSIZE  <= 'd0;
        vif.AWBURST <= 'd0;
        vif.AWVALID <= 'd0;
                        
        vif.WDATA   <= 'd0;
        vif.WSTRB   <= 'd0;
        vif.WLAST   <= 'd0;
        vif.WVALID  <= 'd0;

        vif.BREADY  <= 'd0;

        vif.ARID    <= 'd0;
        vif.ARADDR  <= 'd0;
        vif.ARLEN   <= 'd0;
        vif.ARSIZE  <= 'd0;
        vif.ARBURST <= 'd0;
        vif.ARVALID <= 'd0;

        vif.RREADY  <= 'd0;
    endtask

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                if (trans.ARESETn == 'b0) begin
                    for (int i = 0; i < 16384; i++) begin
                        driver::rst(64 * i);
                    end
                end else begin
                    trans.randomize();
                    `ifdef AWLEN
                        trans.AWLEN = `AWLEN;
                        assert (0 <= `AWLEN && `AWLEN <= 15) else $fatal("AWLEN must be between 0 and 15");
                    `endif
                    `ifdef AWSIZE
                        trans.AWSIZE = `AWSIZE;
                        assert (0 <= `AWSIZE && `AWSIZE <= 2) else $fatal("AWSIZE must be between 0 and 2");
                    `endif
                    `ifdef ARSIZE
                        trans.ARSIZE = `ARSIZE;
                        assert (0 <= `ARSIZE && `ARSIZE <= 2) else $fatal("ARSIZE must be between 0 and 2");
                    `endif
                    `ifdef ARLEN
                        trans.ARLEN = `ARLEN;
                        assert (0 <= `ARLEN && `ARLEN <= 15) else $fatal("ARLEN must be between 0 and 15");
                    `endif
                    vif.spaceReset = 1;
                    driver::RMODE(trans.ARADDR, 15, 2);
                    vif.spaceReset = 0;
                    driver::WMODE(trans.AWADDR, trans.AWLEN, trans.AWSIZE, (2**32)-1, 2**31);
                    driver::RMODE(trans.ARADDR, trans.ARLEN, trans.ARSIZE);
                end
                @(posedge vif.ACLK);
            seq_item_port.item_done();
        end
    endtask

endclass

