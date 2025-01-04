class referenceModel extends uvm_component;
    `uvm_component_utils(referenceModel)
    virtual duv_if vif;
    transaction trans;

    uvm_put_port#(transaction) tlm_put;

    logic [65535:0][7:0] mem;

    logic [`AXI_ADDR_BITS-1: 0] AWADDR;
    logic [1:0                ] AWBURST;
    logic [`AXI_LEN_BITS-1:0  ] AWLEN;
    logic [`AXI_SIZE_BITS-1:0 ] AWSIZE;

    logic [`AXI_ADDR_BITS-1: 0] ARADDR;
    logic [1:0                ] ARBURST;
    logic [`AXI_LEN_BITS-1:0  ] ARLEN;
    logic [`AXI_SIZE_BITS-1:0 ] ARSIZE;

    logic [3:0] WSTRB;

    int transfer;

    function new(string name = "referenceModel", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tlm_put = new("tlm_put", this);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))  
            `uvm_error("ref", "failed build_phase")
    endfunction

    task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        wait(vif.ARESETn);
        forever begin
            if (vif.AWVALID && vif.AWREADY) begin
                AWADDR  = vif.AWADDR;
                AWBURST = vif.AWBURST;
                AWLEN   = vif.AWLEN;
                AWSIZE  = vif.AWSIZE;
                $display("\n\n=============================== WRITE ADDRESS ===============================");
                $display("AWADDR  = 0x%8h", AWADDR);
                case (AWBURST)
                    `FIXED: $display("AWBURST = FIXED");
                    `INCR : $display("AWBURST = INCR");
                    `WRAP : $display("AWBURST = WRAP");
                endcase
                $display("AWLEN   = %0d", AWLEN);
                $display("AWSIZE  = %0d", AWSIZE);
                transfer = 0;
            end
            
            if (vif.WVALID && vif.WREADY) begin
                if (vif.WSTRB[0]) mem[int'((AWADDR+(2**AWSIZE)*transfer)/4)*4+0] = vif.WDATA[ 7: 0];
                if (vif.WSTRB[1]) mem[int'((AWADDR+(2**AWSIZE)*transfer)/4)*4+1] = vif.WDATA[15: 8];
                if (vif.WSTRB[2]) mem[int'((AWADDR+(2**AWSIZE)*transfer)/4)*4+2] = vif.WDATA[23:16];
                if (vif.WSTRB[3]) mem[int'((AWADDR+(2**AWSIZE)*transfer)/4)*4+3] = vif.WDATA[31:24];
                $display("--------------------------------- WRITE DATA ---------------------------------");
                $display("Write ADDR  = 0x%08h", int'((AWADDR+(2**AWSIZE)*transfer)/4)*4);
                $display("Write DATA  = 0x%08h", vif.WDATA);
                $display("Write WSTRB =    %0b %b %b %b", vif.WSTRB[3], vif.WSTRB[2], vif.WSTRB[1], vif.WSTRB[0]);
                transfer = (AWBURST == `FIXED) ? transfer : transfer + 1;
                if (AWBURST == `WRAP)
                    if (int'((AWADDR+(2**AWSIZE)*transfer)/4)*4 == int'(AWADDR/((2**AWSIZE)*(AWLEN+1)))*(2**AWSIZE)*(AWLEN+1)+(2**AWSIZE)*(AWLEN+1))
                        transfer = transfer - (AWLEN + 1);
            end

            if (vif.ARVALID && vif.ARREADY) begin
                ARADDR  = vif.ARADDR;
                ARBURST = vif.ARBURST;
                ARLEN   = vif.ARLEN;
                ARSIZE  = vif.ARSIZE;
                $display("\n\n=============================== READ ADDRESS ===============================");
                $display("ARADDR  = 0x%8h", ARADDR);
                case (ARBURST)
                    `FIXED: $display("ARBURST = FIXED");
                    `INCR : $display("ARBURST = INCR");
                    `WRAP : $display("ARBURST = WRAP");
                endcase
                $display("ARLEN   = %0d", ARLEN);
                $display("ARSIZE  = %0d", ARSIZE);
                transfer = 0;
            end

            if (vif.RVALID && vif.RREADY) begin
                $display("--------------------------------- READ DATA ---------------------------------");
                $display("ARADDR = 0x%8h", int'((ARADDR+(2**ARSIZE)*transfer)/4)*4);
                trans.RDATA = { mem[int'((ARADDR+(2**ARSIZE)*transfer)/4)*4+3], 
                                mem[int'((ARADDR+(2**ARSIZE)*transfer)/4)*4+2], 
                                mem[int'((ARADDR+(2**ARSIZE)*transfer)/4)*4+1], 
                                mem[int'((ARADDR+(2**ARSIZE)*transfer)/4)*4+0]};
                if (!tlm_put.try_put(trans)) begin
                    $display("Ref model put tlm failed");
                end

                transfer = (ARBURST == `FIXED) ? transfer : transfer + 1;
                if (ARBURST == `WRAP)
                    if (int'((ARADDR+(2**ARSIZE)*transfer)/4)*4 == int'(ARADDR/((2**ARSIZE)*(ARLEN+1)))*(2**ARSIZE)*(ARLEN+1)+(2**ARSIZE)*(ARLEN+1))
                        transfer = transfer - (ARLEN + 1);
            end
            @(posedge vif.ACLK);
        end
    endtask


endclass