module Write_Response_Channel(
    input   [1:0]   B_state,

    input   [`AXI_IDS_BITS-1:0  ]   BID_S0,
    input   [1:0                ]   BRESP_S0,
    input                           BVALID_S0,
    output  logic                   BREADY_S0,

    input   [`AXI_IDS_BITS-1:0  ]   BID_S1,
    input   [1:0                ]   BRESP_S1,
    input                           BVALID_S1,
    output  logic                   BREADY_S1,

    output  logic   [`AXI_ID_BITS-1:0   ]   BID_M1,
    output  logic   [1:0                ]   BRESP_M1,
    output  logic                           BVALID_M1,
    input                                   BREADY_M1
);

    localparam IDLE     = 2'd0;
    localparam B_M1_S0  = 2'd1;
    localparam B_M1_S1  = 2'd2;

    always_comb begin
        BREADY_S0   = 1'd0;
        BREADY_S1   = 1'd0;
        
        BID_M1      = `AXI_ID_BITS'd0;
        BRESP_M1    = 2'd0;
        BVALID_M1   = 1'd0;
        unique case (B_state)
            B_M1_S0: begin
                BREADY_S0   = BREADY_M1;

                BID_M1      = BID_S0[3:0];
                BRESP_M1    = BRESP_S0;
                BVALID_M1   = BVALID_S0;
            end
            B_M1_S1: begin
                BREADY_S1   = BREADY_M1;

                BID_M1      = BID_S1[3:0];
                BRESP_M1    = BRESP_S1;
                BVALID_M1   = BVALID_S1;
            end
            default: begin
                BREADY_S0   = 1'd0;
                BREADY_S1   = 1'd0;
                
                BID_M1      = `AXI_ID_BITS'd0;
                BRESP_M1    = 2'd0;
                BVALID_M1   = 1'd0;
            end
        endcase
    end
endmodule