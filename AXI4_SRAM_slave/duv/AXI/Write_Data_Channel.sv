module Write_Data_Channel(
    input   [1:0]   W_state,

    input   [`AXI_DATA_BITS-1:0 ]   WDATA_M1,
    input   [`AXI_STRB_BITS-1:0 ]   WSTRB_M1,
    input                           WLAST_M1,
    input                           WVALID_M1,
    output  logic                   WREADY_M1,

    output  logic   [`AXI_DATA_BITS-1:0 ]   WDATA_S0,
    output  logic   [`AXI_STRB_BITS-1:0 ]   WSTRB_S0,
    output  logic                           WLAST_S0,
    output  logic                           WVALID_S0,
    input                                   WREADY_S0,

    output  logic   [`AXI_DATA_BITS-1:0 ]   WDATA_S1,
    output  logic   [`AXI_STRB_BITS-1:0 ]   WSTRB_S1,
    output  logic                           WLAST_S1,
    output  logic                           WVALID_S1,
    input                                   WREADY_S1
);

    localparam IDLE     = 2'd0;
    localparam W_M1_S0  = 2'd1;
    localparam W_M1_S1  = 2'd2;

    always_comb begin
        WREADY_M1   = 1'd0;

        WDATA_S0    = `AXI_DATA_BITS'd0;
        WSTRB_S0    = `AXI_STRB_BITS'd0;
        WLAST_S0    = 1'd0;
        WVALID_S0   = 1'd0;

        WDATA_S1    = `AXI_DATA_BITS'd0;
        WSTRB_S1    = `AXI_STRB_BITS'd0;
        WLAST_S1    = 1'd0;
        WVALID_S1   = 1'd0;
        unique case (W_state)
            W_M1_S0: begin
                WREADY_M1   = WREADY_S0;

                WDATA_S0    = WDATA_M1;
                WSTRB_S0    = WSTRB_M1;
                WLAST_S0    = WLAST_M1;
                WVALID_S0   = WVALID_M1;
            end
            W_M1_S1: begin
                WREADY_M1   = WREADY_S1;

                WDATA_S1    = WDATA_M1;
                WSTRB_S1    = WSTRB_M1;
                WLAST_S1    = WLAST_M1;
                WVALID_S1   = WVALID_M1;
            end
            default: begin
                WREADY_M1   = 1'd0;

                WDATA_S0    = `AXI_DATA_BITS'd0;
                WSTRB_S0    = `AXI_STRB_BITS'd0;
                WLAST_S0    = 1'd0;
                WVALID_S0   = 1'd0;

                WDATA_S1    = `AXI_DATA_BITS'd0;
                WSTRB_S1    = `AXI_STRB_BITS'd0;
                WLAST_S1    = 1'd0;
                WVALID_S1   = 1'd0;
            end
        endcase
    end
endmodule