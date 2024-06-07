module Read_Address_Channel(
    input   [2:0]   AR_state,

    input   [`AXI_ID_BITS-1:0   ]   ARID_M0,
    input   [`AXI_ADDR_BITS-1:0 ]   ARADDR_M0,
    input   [`AXI_LEN_BITS-1:0  ]   ARLEN_M0,
    input   [`AXI_SIZE_BITS-1:0 ]   ARSIZE_M0,
    input   [1:0                ]   ARBURST_M0,
    input                           ARVALID_M0,
    output  logic                   ARREADY_M0,

    input   [`AXI_ID_BITS-1:0   ]   ARID_M1,
    input   [`AXI_ADDR_BITS-1:0 ]   ARADDR_M1,
    input   [`AXI_LEN_BITS-1:0  ]   ARLEN_M1,
    input   [`AXI_SIZE_BITS-1:0 ]   ARSIZE_M1,
    input   [1:0                ]   ARBURST_M1,
    input                           ARVALID_M1,
    output  logic                   ARREADY_M1,

    output  logic   [`AXI_IDS_BITS-1:0  ]   ARID_S0,
    output  logic   [`AXI_ADDR_BITS-1:0 ]   ARADDR_S0,
    output  logic   [`AXI_LEN_BITS-1:0  ]   ARLEN_S0,
    output  logic   [`AXI_SIZE_BITS-1:0 ]   ARSIZE_S0,
    output  logic   [1:0                ]   ARBURST_S0,
    output  logic                           ARVALID_S0,
    input                                   ARREADY_S0,

    output  logic   [`AXI_IDS_BITS-1:0  ]   ARID_S1,
    output  logic   [`AXI_ADDR_BITS-1:0 ]   ARADDR_S1,
    output  logic   [`AXI_LEN_BITS-1:0  ]   ARLEN_S1,
    output  logic   [`AXI_SIZE_BITS-1:0 ]   ARSIZE_S1,
    output  logic   [1:0                ]   ARBURST_S1,
    output  logic                           ARVALID_S1,
    input                                   ARREADY_S1
);

    localparam IDLE     = 3'd0;
    localparam AR_M0_S0 = 3'd1;
    localparam AR_M1_S0 = 3'd2;
    localparam AR_M1_S1 = 3'd3;
    
    always_comb begin
        ARREADY_M0  = 1'd0;
        ARREADY_M1  = 1'd0;

        ARID_S0     = `AXI_IDS_BITS'd0;
        ARADDR_S0   = `AXI_ADDR_BITS'd0;
        ARLEN_S0    = `AXI_LEN_BITS'd0;
        ARSIZE_S0   = `AXI_SIZE_BITS'd0;
        ARBURST_S0  = 2'd0;
        ARVALID_S0  = 1'd0;

        ARID_S1     = `AXI_IDS_BITS'd0;
        ARADDR_S1   = `AXI_ADDR_BITS'd0;
        ARLEN_S1    = `AXI_LEN_BITS'd0;
        ARSIZE_S1   = `AXI_SIZE_BITS'd0;
        ARBURST_S1  = 2'd0;
        ARVALID_S1  = 1'd0;

        unique case (AR_state)
            AR_M0_S0: begin
                ARREADY_M0  = ARREADY_S0;

                ARID_S0     = {4'b0000, ARID_M0};
                ARADDR_S0   = ARADDR_M0;
                ARLEN_S0    = ARLEN_M0;
                ARSIZE_S0   = ARSIZE_M0;
                ARBURST_S0  = ARBURST_M0;
                ARVALID_S0  = ARVALID_M0;
            end
            AR_M1_S0: begin
                ARREADY_M1  = ARREADY_S0;

                ARID_S0     = {4'b0001, ARID_M1};
                ARADDR_S0   = ARADDR_M1;
                ARLEN_S0    = ARLEN_M1;
                ARSIZE_S0   = ARSIZE_M1;
                ARBURST_S0  = ARBURST_M1;
                ARVALID_S0  = ARVALID_M1;
            end 
            AR_M1_S1: begin
                ARREADY_M1  = ARREADY_S1;

                ARID_S1     = {4'b0001, ARID_M1};
                ARADDR_S1   = ARADDR_M1;
                ARLEN_S1    = ARLEN_M1;
                ARSIZE_S1   = ARSIZE_M1;
                ARBURST_S1  = ARBURST_M1;
                ARVALID_S1  = ARVALID_M1;
            end
            default: begin
                ARREADY_M0  = 1'd0;
                ARREADY_M1  = 1'd0;

                ARID_S0     = `AXI_IDS_BITS'd0;
                ARADDR_S0   = `AXI_ADDR_BITS'd0;
                ARLEN_S0    = `AXI_LEN_BITS'd0;
                ARSIZE_S0   = `AXI_SIZE_BITS'd0;
                ARBURST_S0  = 2'd0;
                ARVALID_S0  = 1'd0;

                ARID_S1     = `AXI_IDS_BITS'd0;
                ARADDR_S1   = `AXI_ADDR_BITS'd0;
                ARLEN_S1    = `AXI_LEN_BITS'd0;
                ARSIZE_S1   = `AXI_SIZE_BITS'd0;
                ARBURST_S1  = 2'd0;
                ARVALID_S1  = 1'd0;
            end
        endcase
    end


endmodule