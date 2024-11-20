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
    
    virtual task WMODE(transaction trans, int min, int max);
        vif.ARESETn <= 'd1;
        
        vif.AWID    <= trans.AWID; 
        vif.AWADDR  <= trans.AWADDR;

        vif.AWLEN   <= trans.AWLEN;
        vif.AWSIZE  <= trans.AWSIZE;
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
            if ($urandom_range(0, 1)) begin
                vif.WVALID <= 'd0;
                i--;
            end else begin
                vif.WVALID <= 'd1;
                case (trans.AWSIZE)
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
            end
            @(posedge vif.ACLK);
        end
        while (1) begin
            if ($urandom_range(0, 1)) begin
                vif.BREADY <= 'd1;
            end else begin
                vif.BREADY <= 'd0;
            end
            @(posedge vif.ACLK);
            if (vif.BREADY) break;
        end
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

    virtual task RMODE(transaction trans);   

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
    
        vif.ARID    <= trans.ARID;
        vif.ARADDR  <= trans.ARADDR;

        vif.ARLEN   <= trans.ARLEN;
        vif.ARSIZE  <= trans.ARSIZE;
        vif.ARBURST <= 'd1;
        vif.ARVALID <= 'd1;

        vif.RREADY  <= 'd0;

        wait (vif.ARREADY);
        @(posedge vif.ACLK);
        vif.ARVALID <= 'd0;

        for (int i = 0; i < vif.ARLEN + 1; i++) begin
            if ($urandom_range(0, 1)) begin
                vif.RREADY <= 'd0;
                i--;
            end else begin
                vif.RREADY <= 'd1;
                wait (vif.RVALID);
            end
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
                if (trans.startWork) begin
                    `ifdef AWLEN
                        trans.AWLEN = `AWLEN;
                        assert (0 <= `AWLEN && `AWLEN <= 15) else $fatal("AWLEN must be between 0 and 15");
                    `endif
                    `ifdef AWSIZE
                        trans.AWSIZE = `AWSIZE;
                        assert (`AWSIZE == 2) else $fatal("AWSIZE must be 2");
                    `endif
                    `ifdef ARSIZE
                        trans.ARSIZE = `ARSIZE;
                        assert (`ARSIZE == 2) else $fatal("ARSIZE must be 2");
                    `endif
                    `ifdef ARLEN
                        trans.ARLEN = `ARLEN;
                        assert (0 <= `ARLEN && `ARLEN <= 15) else $fatal("ARLEN must be between 0 and 15");
                    `endif
                    trans.randomize();
                    vif.spaceReset = 1;
                    trans.ARLEN = 'd15;
                    trans.ARSIZE = 'd2;
                    driver::RMODE(trans);
                    vif.spaceReset = 0;
                    driver::WMODE(trans, (2**32)-1, 2**31);
                    trans.ARLEN = $urandom_range(0, 15);
                    trans.ARSIZE = 2;
                    driver::RMODE(trans);
                end
                vif.ARESETn <= trans.ARESETn;
                vif.startWork <= trans.startWork;
                @(posedge vif.ACLK);
            seq_item_port.item_done();
        end
    endtask

endclass

