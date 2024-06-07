class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

            logic                           ACLK;
            logic                           ARESETn;  
                             
            logic   [`AXI_IDS_BITS-1:0  ]   AWID;
    rand    logic   [`AXI_ADDR_BITS-1:0 ]   AWADDR;
    rand    logic   [`AXI_LEN_BITS-1:0  ]   AWLEN;
    rand    logic   [`AXI_SIZE_BITS-1:0 ]   AWSIZE;
            logic   [1:0                ]   AWBURST;
            logic                           AWVALID;
            logic                           AWREADY;

            logic   [`AXI_DATA_BITS-1:0 ]   WDATA;
            logic   [`AXI_STRB_BITS-1:0 ]   WSTRB;
            logic                           WLAST;
            logic                           WVALID;
            logic                           WREADY;

            logic   [`AXI_IDS_BITS-1:0  ]   BID;
            logic   [1:0                ]   BRESP;
            logic                           BVALID;
            logic                           BREADY;

            logic   [`AXI_IDS_BITS-1:0  ]   ARID;
    rand    logic   [`AXI_ADDR_BITS-1:0 ]   ARADDR;
            logic   [`AXI_LEN_BITS-1:0  ]   ARLEN;
            logic   [`AXI_SIZE_BITS-1:0 ]   ARSIZE;
            logic   [1:0                ]   ARBURST;
            logic                           ARVALID;
            logic                           ARREADY;

            logic   [`AXI_IDS_BITS-1:0  ]   RID;
            logic   [`AXI_DATA_BITS-1:0 ]   RDATA;
            logic   [1:0                ]   RRESP;
            logic                           RLAST;
            logic                           RVALID;
            logic                           RREADY;

            logic   [7:0                ]   refModel [0:63];
            logic   [7:0                ]   duv      [0:63];
            logic   [`AXI_ADDR_BITS-1:0 ]   arAddrReg;

    function new(string name = "transaction");
        super.new(name);
    endfunction

    static function logic [`AXI_SIZE_BITS-1:0] getArsize(logic [`AXI_LEN_BITS-1:0] awlen, logic [`AXI_SIZE_BITS-1:0] awsize);
        int byteNum;
        logic [`AXI_SIZE_BITS-1:0] arsize;
        byteNum = (2 ** awsize) * (awlen + 1);

        if (byteNum % 2 != 0) begin
            arsize = 'd0;
        end else begin
            if (byteNum <= 16) begin
                if (byteNum % 4 == 0)   arsize = $urandom_range(0, 2);
                else                    arsize = $urandom_range(0, 1);
            end else if (byteNum <= 32) begin
                if (byteNum % 4 == 0)   arsize = $urandom_range(1, 2);
                else                    arsize = 'd1;
            end else begin
                arsize = 'd2;
            end
        end
        return arsize;
    endfunction

    static function logic [`AXI_LEN_BITS-1:0] getArlen(logic [`AXI_LEN_BITS-1:0] awlen, logic [`AXI_SIZE_BITS-1:0] awsize, logic [`AXI_SIZE_BITS-1:0] arsize);
        int byteNum;
        byteNum = (2 ** awsize) * (awlen + 1);
        return ((byteNum / (2 ** arsize)) - 1);
    endfunction

    constraint AWLENconstraint {
        'd0 <= AWLEN <= 'b1111;
    }

    constraint AWSIZEconstraint {
        AWSIZE inside {'d0, 'd1, 'd2};
    }

    constraint AWADDRconstraint {
        AWADDR[1:0] == 'b00;
        AWADDR < 'd16384;
    }

    constraint ARADDRconstraint {
        ARADDR == AWADDR;
    }

endclass