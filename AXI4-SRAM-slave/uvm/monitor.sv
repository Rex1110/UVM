class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    uvm_analysis_port #(transaction) ap;
    virtual duv_if vif;
    transaction trans;


    logic [7:0] refModel [0:63];
    logic [7:0] duv [$];
    logic [5:0] ptr;
    int num = 0;
    logic [3:0] refPtr;
    logic [`AXI_ADDR_BITS-1: 0] awAddrReg;
    logic [`AXI_ADDR_BITS-1: 0] arAddrReg;

    logic [`AXI_LEN_BITS-1: 0] awLenReg;
    logic [`AXI_LEN_BITS-1: 0] arLenReg;

    logic [`AXI_SIZE_BITS-1: 0] awSizeReg;
    logic [`AXI_SIZE_BITS-1: 0] arSizeReg;



    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "failed build_phase")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        refPtr = 'd0;
        forever begin
            if (vif.ARESETn == 1'b1) begin
                if (vif.spaceReset) begin
                    if (vif.RVALID && vif.RREADY) begin
                        refModel[4*refPtr  ] = vif.RDATA[ 7: 0];
                        refModel[4*refPtr+1] = vif.RDATA[15: 8];
                        refModel[4*refPtr+2] = vif.RDATA[23:16];
                        refModel[4*refPtr+3] = vif.RDATA[31:24];

                        refPtr++;
                    end
                end else begin
                    if (vif.AWVALID && vif.AWREADY) begin
                        ptr = 0;
                        if (~vif.spaceReset) begin
                            $display("*****************************************************************");
                            $display("*********************** The %3d test case ***********************", num);
                            $display("*****************************************************************");
                            $display("");
                            $display(">>>>>>>>>>>>>>>>>> State of SRAM before writing <<<<<<<<<<<<<<<<<<\n");
                            for (int i = 0; i < 16; i++) begin
                                $display("SRAM[%04d] = %02h_%2h_%2h_%2h\t", vif.AWADDR + 4*i, refModel[4*i+3], refModel[4*i+2], refModel[4*i+1], refModel[4*i]);
                            end
                            $display("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>> WRITE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                            $display("");
                            $display("AWBURST = INCR");
                            $display("AWADDR  = %0d", vif.AWADDR);
                            $display("AWLEN   = %0d", vif.AWLEN);
                            $display("AWSIZE  = %0d", vif.AWSIZE);
                            $display(""); 
                        end
                        awAddrReg = vif.AWADDR;
                        awLenReg  = vif.AWLEN;
                        awSizeReg = vif.AWSIZE;
                    end

                    if (vif.WVALID && vif.WREADY) begin
                        if (~vif.spaceReset)
                            $display("ADDR[%04d] = %02h_%02h_%02h_%02h, WSTRB = %04b", awAddrReg + ptr /** (2 ** awSizeReg)*/, vif.WDATA[31:24], vif.WDATA[23:16], vif.WDATA[15:8], vif.WDATA[7:0], vif.WSTRB);
                        case (awSizeReg)
                            'd0: begin
                                if (vif.WSTRB[0]) refModel[ptr    ] = vif.WDATA[ 7: 0];
                                ptr = ptr + 'd1;
                            end
                            'd1: begin
                                if (vif.WSTRB[0]) refModel[ptr    ] = vif.WDATA[ 7: 0];
                                if (vif.WSTRB[1]) refModel[ptr + 1] = vif.WDATA[15: 8];
                                ptr = ptr + 'd2;
                            end
                            'd2: begin
                                if (vif.WSTRB[0]) refModel[ptr    ] = vif.WDATA[ 7: 0];
                                if (vif.WSTRB[1]) refModel[ptr + 1] = vif.WDATA[15: 8];
                                if (vif.WSTRB[2]) refModel[ptr + 2] = vif.WDATA[23:16];
                                if (vif.WSTRB[3]) refModel[ptr + 3] = vif.WDATA[31:24];
                                ptr = ptr + 'd4;
                            end
                        endcase
                    end

                    if (vif.ARVALID && vif.ARREADY) begin
                        ptr = 0;
                        $display("");
                        $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> READ <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
                        $display("");
                        $display("ARBURST = INCR");
                        $display("ARADDR  = %0d", vif.ARADDR);
                        $display("ARLEN   = %0d", vif.ARLEN);
                        $display("ARSIZE  = %0d", vif.ARSIZE);
                        $display("");
                        arAddrReg = vif.ARADDR; 
                        arSizeReg = vif.ARSIZE;
                        arLenReg  = vif.ARLEN;
                    end

                    if (vif.RVALID && vif.RREADY) begin
                        case (arSizeReg)
                            'd0: begin
                                duv.push_back(vif.RDATA[ 7: 0]);
                            end
                            'd1: begin
                                duv.push_back(vif.RDATA[ 7: 0]);
                                duv.push_back(vif.RDATA[15: 8]);
                            end
                            'd2: begin
                                duv.push_back(vif.RDATA[ 7: 0]);
                                duv.push_back(vif.RDATA[15: 8]);
                                duv.push_back(vif.RDATA[23:16]);
                                duv.push_back(vif.RDATA[31:24]);
                            end
                        endcase
                        ptr++;
                    end
                    if (vif.RLAST) begin
                        num++;
                        trans.refModel  = refModel;
                        trans.duv       = duv;
                        trans.arAddrReg = arAddrReg;
                        trans.ARLEN     = arLenReg;
                        trans.ARSIZE    = arSizeReg;
                        duv = {};
                        ap.write(trans);
                    end
                end
            end
            @(posedge vif.ACLK);
        end
    endtask
endclass