module Read_Data_Channel(
    input   [2:0]   R_state,

    input   [`AXI_IDS_BITS-1:0  ]   RID_S0,
    input   [`AXI_DATA_BITS-1:0 ]   RDATA_S0,
    input   [1:0                ]   RRESP_S0,
    input                           RLAST_S0,
    input                           RVALID_S0,
    output  logic                   RREADY_S0,
    
    input   [`AXI_IDS_BITS-1:0  ]   RID_S1,
    input   [`AXI_DATA_BITS-1:0 ]   RDATA_S1,
    input   [1:0                ]   RRESP_S1,
    input                           RLAST_S1,
    input                           RVALID_S1,
    output  logic                   RREADY_S1,

    output  logic   [`AXI_ID_BITS-1:0   ]   RID_M0,
    output  logic   [`AXI_DATA_BITS-1:0 ]   RDATA_M0,
    output  logic   [1:0                ]   RRESP_M0,
    output  logic                           RLAST_M0,
    output  logic                           RVALID_M0,
    input                                   RREADY_M0,

    output  logic   [`AXI_ID_BITS-1:0   ]   RID_M1,
    output  logic   [`AXI_DATA_BITS-1:0 ]   RDATA_M1,
    output  logic   [1:0                ]   RRESP_M1,
    output  logic                           RLAST_M1,
    output  logic                           RVALID_M1,
    input                                   RREADY_M1

);
    localparam IDLE    = 3'd0;
    localparam R_M0_S0 = 3'd1;
    localparam R_M1_S0 = 3'd2;
    localparam R_M1_S1 = 3'd3;

    always_comb begin
        RREADY_S0   = 1'd0;
        RREADY_S1   = 1'd0;

        RID_M0      = `AXI_ID_BITS'd0;
        RDATA_M0    = `AXI_DATA_BITS'd0;
        RRESP_M0    = 2'd0;
        RLAST_M0    = 1'd0;
        RVALID_M0   = 1'd0;

        RID_M1      = `AXI_ID_BITS'd0;
        RDATA_M1    = `AXI_DATA_BITS'd0;
        RRESP_M1    = 2'd0;
        RLAST_M1    = 1'd0;
        RVALID_M1   = 1'd0;

        unique case (R_state)
            R_M0_S0: begin
                RREADY_S0   = RREADY_M0;

                RID_M0      = RID_S0[3:0];
                RDATA_M0    = RDATA_S0;
                RRESP_M0    = RRESP_S0;
                RLAST_M0    = RLAST_S0;
                RVALID_M0   = RVALID_S0;
            end
            R_M1_S0: begin
                RREADY_S0   = RREADY_M1;

                RID_M1      = RID_S0[3:0];
                RDATA_M1    = RDATA_S0;
                RRESP_M1    = RRESP_S0;
                RLAST_M1    = RLAST_S0;
                RVALID_M1   = RVALID_S0;
            end
            R_M1_S1: begin
                RREADY_S1   = RREADY_M1;

                RID_M1      = RID_S1[3:0];
                RDATA_M1    = RDATA_S1;
                RRESP_M1    = RRESP_S1;
                RLAST_M1    = RLAST_S1;
                RVALID_M1   = RVALID_S1;
            end

            default: begin
                RREADY_S0   = 1'd0;
                RREADY_S1   = 1'd0;

                RID_M0      = `AXI_ID_BITS'd0;
                RDATA_M0    = `AXI_DATA_BITS'd0;
                RRESP_M0    = 2'd0;
                RLAST_M0    = 1'd0;
                RVALID_M0   = 1'd0;

                RID_M1      = `AXI_ID_BITS'd0;
                RDATA_M1    = `AXI_DATA_BITS'd0;
                RRESP_M1    = 2'd0;
                RLAST_M1    = 1'd0;
                RVALID_M1   = 1'd0;
            end
        endcase
    end


endmodule