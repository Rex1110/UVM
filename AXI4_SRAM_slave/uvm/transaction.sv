class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)
            logic                           startWork;
            logic                           ACLK;
            logic                           ARESETn;  
                             
    rand    logic   [`AXI_IDS_BITS-1:0  ]   AWID;
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

    rand    logic   [`AXI_IDS_BITS-1:0  ]   BID;
    rand    logic   [1:0                ]   BRESP;
            logic                           BVALID;
            logic                           BREADY;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   ARID;
    rand    logic   [`AXI_ADDR_BITS-1:0 ]   ARADDR;
    rand    logic   [`AXI_LEN_BITS-1:0  ]   ARLEN;
    rand    logic   [`AXI_SIZE_BITS-1:0 ]   ARSIZE;
            logic   [1:0                ]   ARBURST;
            logic                           ARVALID;
            logic                           ARREADY;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   RID;
            logic   [`AXI_DATA_BITS-1:0 ]   RDATA;
    rand    logic   [1:0                ]   RRESP;
            logic                           RLAST;
            logic                           RVALID;
            logic                           RREADY;

            logic   [7:0                ]   refModel [0:63];
            logic   [7:0                ]   duv      [$];
            logic   [`AXI_ADDR_BITS-1:0 ]   arAddrReg;

    function new(string name = "transaction");
        super.new(name);
    endfunction

    constraint IDconstraint {
        AWID == BID;
        ARID == RID;
    }

    constraint AWLENconstraint {
        'd0 <= AWLEN <= 'b1111;
    }

    constraint AWSIZEconstraint {
        AWSIZE inside {'d2};
    }

    constraint ARLENconstraint {
        'd0 <= ARLEN <= 'b1111;
    }

    constraint ARSIZEconstraint {
        ARSIZE inside {'d2};
    }

    constraint AWADDRconstraint {
        AWADDR[1:0] == 'b00;
        AWADDR < 16384 * 4;
        AWADDR + (2 ** (AWSIZE) * (AWLEN + 1)) <= 16384 * 4;
    }

    constraint ARADDRconstraint {
        ARADDR == AWADDR;
        ARADDR + (2 ** (ARSIZE) * (ARLEN + 1)) <= 16384 * 4;
    }

endclass