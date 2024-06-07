module Write_Address_Channel(
    input   [1:0]   W_state,

    input   [`AXI_ID_BITS-1:0   ]   AWID_M1,
    input   [`AXI_ADDR_BITS-1:0 ]   AWADDR_M1,
    input   [`AXI_LEN_BITS-1:0  ]   AWLEN_M1,
    input   [`AXI_SIZE_BITS-1:0 ]   AWSIZE_M1,
    input   [1:0                ]   AWBURST_M1,
    input                           AWVALID_M1,
    output  logic                   AWREADY_M1,


    output  logic   [`AXI_IDS_BITS-1:0  ]   AWID_S0,
    output  logic   [`AXI_ADDR_BITS-1:0 ]   AWADDR_S0,
    output  logic   [`AXI_LEN_BITS-1:0  ]   AWLEN_S0,
    output  logic   [`AXI_SIZE_BITS-1:0 ]   AWSIZE_S0,
    output  logic   [1:0                ]   AWBURST_S0,
    output  logic                           AWVALID_S0,
    input                                   AWREADY_S0,

    output  logic   [`AXI_IDS_BITS-1:0  ]   AWID_S1,
    output  logic   [`AXI_ADDR_BITS-1:0 ]   AWADDR_S1,
    output  logic   [`AXI_LEN_BITS-1:0  ]   AWLEN_S1,
    output  logic   [`AXI_SIZE_BITS-1:0 ]   AWSIZE_S1,
    output  logic   [1:0                ]   AWBURST_S1,
    output  logic                           AWVALID_S1,
    input                                   AWREADY_S1
);
    localparam IDLE 	= 2'd0;
    localparam AW_M1_S0 = 2'd1;
    localparam AW_M1_S1 = 2'd2;
    always_comb begin
        AWREADY_M1  = 1'd0;

        AWID_S0     = `AXI_IDS_BITS'd0;
        AWADDR_S0   = `AXI_ADDR_BITS'd0;
        AWLEN_S0    = `AXI_LEN_BITS'd0;
        AWSIZE_S0   = `AXI_SIZE_BITS'd0;
        AWBURST_S0  = 2'd0;
        AWVALID_S0  = 1'd0;

        AWID_S1     = `AXI_IDS_BITS'd0;
        AWADDR_S1   = `AXI_ADDR_BITS'd0;
        AWLEN_S1    = `AXI_LEN_BITS'd0;
        AWSIZE_S1   = `AXI_SIZE_BITS'd0;
        AWBURST_S1  = 2'd0;
        AWVALID_S1  = 1'd0;
        unique case (W_state)
            AW_M1_S0: begin
                AWREADY_M1  = AWREADY_S0;

                AWID_S0     = {4'b0001, AWID_M1};
                AWADDR_S0   = AWADDR_M1;
                AWLEN_S0    = AWLEN_M1;
                AWSIZE_S0   = AWSIZE_M1;
                AWBURST_S0  = AWBURST_M1;
                AWVALID_S0  = AWVALID_M1;
            end
            AW_M1_S1: begin
                AWREADY_M1  = AWREADY_S1;

                AWID_S1     = {4'b0001, AWID_M1};
                AWADDR_S1   = AWADDR_M1;
                AWLEN_S1    = AWLEN_M1;
                AWSIZE_S1   = AWSIZE_M1;
                AWBURST_S1  = AWBURST_M1;
                AWVALID_S1  = AWVALID_M1;
            end
            default: begin
                AWREADY_M1  = 1'd0;

                AWID_S0     = `AXI_IDS_BITS'd0;
                AWADDR_S0   = `AXI_ADDR_BITS'd0;
                AWLEN_S0    = `AXI_LEN_BITS'd0;
                AWSIZE_S0   = `AXI_SIZE_BITS'd0;
                AWBURST_S0  = 2'd0;
                AWVALID_S0  = 1'd0;

                AWID_S1     = `AXI_IDS_BITS'd0;
                AWADDR_S1   = `AXI_ADDR_BITS'd0;
                AWLEN_S1    = `AXI_LEN_BITS'd0;
                AWSIZE_S1   = `AXI_SIZE_BITS'd0;
                AWBURST_S1  = 2'd0;
                AWVALID_S1  = 1'd0;
            end
        endcase 
    end
endmodule
