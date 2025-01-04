class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)
            logic                           ACLK;
    rand    logic                           ARESETn;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   AWID;
    rand    logic   [`AXI_ADDR_BITS-1:0 ]   AWADDR;
    rand    logic   [`AXI_LEN_BITS-1:0  ]   AWLEN;
    rand    logic   [`AXI_SIZE_BITS-1:0 ]   AWSIZE;
    rand    logic   [1:0                ]   AWBURST;
    rand    logic                           AWVALID;
            logic                           AWREADY;

    rand    logic   [`AXI_DATA_BITS-1:0 ]   WDATA[$];
    rand    logic   [`AXI_STRB_BITS-1:0 ]   WSTRB;
    rand    logic                           WLAST;
    rand    logic                           WVALID;
            logic                           WREADY;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   BID;
    rand    logic   [1:0                ]   BRESP;
            logic                           BVALID;
    rand    logic                           BREADY;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   ARID;
    rand    logic   [`AXI_ADDR_BITS-1:0 ]   ARADDR;
    rand    logic   [`AXI_LEN_BITS-1:0  ]   ARLEN;
    rand    logic   [`AXI_SIZE_BITS-1:0 ]   ARSIZE;
    rand    logic   [1:0                ]   ARBURST;
    rand    logic                           ARVALID;
            logic                           ARREADY;

    rand    logic   [`AXI_IDS_BITS-1:0  ]   RID;
            logic   [`AXI_DATA_BITS-1:0 ]   RDATA;
    rand    logic   [1:0                ]   RRESP;
            logic                           RLAST;
            logic                           RVALID;
    rand    logic                           RREADY;

    function new(string name = "transaction");
        super.new(name);
    endfunction

    constraint ID_constraint {
        AWID == BID;
        ARID == RID;
    }

    constraint AxBURST_constraint {
        AWBURST inside {`FIXED, `INCR, `WRAP};
        ARBURST inside {`FIXED, `INCR, `WRAP};
    }

    constraint AxSIZE_constraint {
        AWSIZE inside {`BYTE, `HALFWORD, `WORD};
        ARSIZE inside {`BYTE, `HALFWORD, `WORD};
    }

    constraint AxADDR_constraint {
        (AWVALID == 1'b1) && (AWBURST == `WRAP) -> (AWADDR % (2 ** AWSIZE)) == 0;
        (ARVALID == 1'b1) && (ARBURST == `WRAP) -> (ARADDR % (2 ** ARSIZE)) == 0;
    }

    constraint AxLEN_constraint {
        (AWVALID == 1'b1) && (AWBURST == `WRAP) -> AWLEN inside {'d1, 'd3, 'd7, 'd15};
        (ARVALID == 1'b1) && (ARBURST == `WRAP) -> ARLEN inside {'d1, 'd3, 'd7, 'd15};
    }

    constraint Memory_boundary_4KB_constraint {
        (AWVALID == 1'b1) && (AWBURST == `INCR)
        -> (AWADDR % 4096) + (2 ** AWSIZE) * (AWLEN + 1) < 4096;
 
        (ARVALID == 1'b1) && (ARBURST == `INCR)  
        -> (ARADDR % 4096) + (2 ** ARSIZE) * (ARLEN + 1) < 4096;
    }

    constraint WDATA_constraint {
        WDATA.size() == (AWLEN + 1);
    }
    
endclass