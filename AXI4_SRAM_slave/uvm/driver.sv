class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)
    virtual duv_if vif;
    transaction trans;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "failed build_phase")
    endfunction

    task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                test(trans);
                @(posedge vif.ACLK);
            seq_item_port.item_done();
        end
    endtask

    // calculate WSTRB
    extern function logic [`AXI_STRB_BITS-1: 0] get_first_wstrb(logic [`AXI_ADDR_BITS-1: 0] AWADDR, logic [`AXI_SIZE_BITS-1: 0] AWSIZE);
    extern function logic [`AXI_STRB_BITS-1: 0] get_remaining_wstrb(logic [1:0] AWBURST, logic [`AXI_SIZE_BITS-1: 0] AWSIZE, logic [`AXI_LEN_BITS-1:0] AWLEN, logic [`AXI_STRB_BITS-1: 0] WSTRB);
        

    task test(transaction trans);
        logic [3:0] WSTRB;
        vif.ARESETn <= trans.ARESETn;
        
        vif.AWID    <= trans.AWID; 
        vif.AWADDR  <= trans.AWADDR;

        vif.AWLEN   <= trans.AWLEN;
        vif.AWSIZE  <= trans.AWSIZE;
        vif.AWBURST <= trans.AWBURST;

        vif.AWVALID <= trans.AWVALID;

        vif.WDATA   <= 'd0;
        vif.WSTRB   <= trans.WSTRB;
        vif.WLAST   <= trans.WLAST;
        vif.WVALID  <= trans.WVALID;

        vif.BREADY  <= trans.BREADY;
    
        vif.ARID    <= trans.ARID;
        vif.ARADDR  <= trans.ARADDR;

        vif.ARLEN   <= trans.ARLEN;
        vif.ARSIZE  <= trans.ARSIZE;
        vif.ARBURST <= trans.ARBURST;

        vif.ARVALID <= trans.ARVALID;

        vif.RREADY  <= trans.RREADY;
        fork 
            begin
                if (trans.AWVALID) begin
                    WSTRB = get_first_wstrb(trans.AWADDR, trans.AWSIZE);

                    wait (vif.AWREADY);
                    @(posedge vif.ACLK);
                    vif.AWVALID <= 'd0;
                    while (trans.WDATA.size() != 0) begin
                        if ($urandom_range(0, 1)) begin
                            vif.WVALID <= 'd0;
                        end else begin
                            vif.WVALID <= 'd1;
                            vif.WSTRB  <= WSTRB;
                            vif.WDATA  <= trans.WDATA.pop_front();
                            vif.WLAST  <= (trans.WDATA.size() == 0);
                            wait (vif.WREADY);
                            WSTRB = get_remaining_wstrb(trans.AWBURST, trans.AWSIZE, trans.AWLEN, WSTRB);
                        end
                        @(posedge vif.ACLK);
                    end

                    while (1) begin
                        vif.BREADY <= $urandom_range(0, 1);
                        @(posedge vif.ACLK);
                        if (vif.BREADY) break;
                    end
                    wait (vif.BVALID);
                    @(negedge vif.BVALID);

                    vif.AWVALID <= 'd0;
                    vif.WVALID  <= 'd0;

                end
            end

            begin
                if (trans.ARVALID) begin
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

                    vif.ARVALID <= 'd0;
                end
            end
        join


    endtask

endclass


function logic [`AXI_STRB_BITS-1: 0] driver::get_first_wstrb(logic [`AXI_ADDR_BITS-1: 0] AWADDR, logic [`AXI_SIZE_BITS-1: 0] AWSIZE);
    case (AWSIZE)
        `BYTE     : get_first_wstrb = 'b0001 << AWADDR[1:0];
        `HALFWORD : begin
            case (AWADDR[1:0])
                2'b00: get_first_wstrb = 'b0011;
                2'b01: get_first_wstrb = 'b0010;
                2'b10: get_first_wstrb = 'b1100;
                2'b11: get_first_wstrb = 'b1000;
            endcase
        end
        `WORD     : begin
            case (AWADDR[1:0])
                2'b00: get_first_wstrb = 'b1111;
                2'b01: get_first_wstrb = 'b1110;
                2'b10: get_first_wstrb = 'b1100;
                2'b11: get_first_wstrb = 'b1000;
            endcase
        end
    endcase

    return get_first_wstrb;
endfunction

function logic [`AXI_STRB_BITS-1: 0] driver::get_remaining_wstrb(logic [1:0] AWBURST, logic [`AXI_SIZE_BITS-1: 0] AWSIZE, logic [`AXI_LEN_BITS-1:0] AWLEN, logic [`AXI_STRB_BITS-1: 0] WSTRB);
    case (AWBURST)
        `FIXED: get_remaining_wstrb = WSTRB;
        `INCR,
        `WRAP: begin
            case (AWSIZE)
                `BYTE: begin
                    if (AWLEN == 'b1) begin
                        if      (WSTRB == 4'b0001) get_remaining_wstrb = 4'b0010;
                        else if (WSTRB == 4'b0010) get_remaining_wstrb = 4'b0001;
                        else if (WSTRB == 4'b0100) get_remaining_wstrb = 4'b1000;
                        else if (WSTRB == 4'b1000) get_remaining_wstrb = 4'b0100;
                    end else begin
                        if      (WSTRB == 4'b0001) get_remaining_wstrb = 4'b0010;
                        else if (WSTRB == 4'b0010) get_remaining_wstrb = 4'b0100;
                        else if (WSTRB == 4'b0100) get_remaining_wstrb = 4'b1000;
                        else if (WSTRB == 4'b1000) get_remaining_wstrb = 4'b0001;
                    end
                end
                `HALFWORD: begin
                    case (WSTRB)
                        4'b0011, 4'b0010: get_remaining_wstrb = 4'b1100;
                        4'b1100, 4'b1000: get_remaining_wstrb = 4'b0011;
                    endcase
                end
                `WORD: get_remaining_wstrb = 4'b1111;
            endcase
        end
    endcase
endfunction