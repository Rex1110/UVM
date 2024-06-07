module Read_Arbiter(
    input   ACLK,
    input   ARESETn,

    input   [`AXI_ADDR_BITS-1:0 ]   ARADDR_M0,
    input                           ARVALID_M0,

    input   [`AXI_ADDR_BITS-1:0 ]   ARADDR_M1,
    input                           ARVALID_M1,

    input                           ARREADY_S0,
    input                           ARREADY_S1,

    input                           RLAST_S0,
    input                           RVALID_S0,

    input                           RLAST_S1,
    input                           RVALID_S1,

    input                           RREADY_M0,
    input                           RREADY_M1,

    output  logic   [2:0]   AR_state,
    output  logic   [2:0]   R_state

);
    localparam IDLE = 4'd0;

    localparam AR_M0_S0 = 4'd1;
    localparam AR_M1_S0 = 4'd2;
    localparam AR_M1_S1 = 4'd3;

    localparam R_M0_S0 = 4'd4;
    localparam R_M1_S0 = 4'd5;
    localparam R_M1_S1 = 4'd6;

    logic [3:0] state, next_state;

    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        unique case (state)
            IDLE: begin
                if (ARVALID_M1) begin
                    if (ARADDR_M1[31:16] == 16'd0) begin
                        next_state = AR_M1_S0;
                    end else if (ARADDR_M1[31:16] == 16'd1) begin
                        next_state = AR_M1_S1;
                    end else begin
                        next_state = IDLE;
                    end
                end else if (ARVALID_M0) begin
                    if (ARADDR_M0[31:16] == 16'd0) begin
                        next_state = AR_M0_S0;
                    end else begin  
                        next_state = IDLE;
                    end
                end else begin
                    next_state = IDLE;
                end 
            end

            AR_M0_S0: next_state = (ARVALID_M0 && ARREADY_S0) ? R_M0_S0 : AR_M0_S0;
            AR_M1_S0: next_state = (ARVALID_M1 && ARREADY_S0) ? R_M1_S0 : AR_M1_S0;
            AR_M1_S1: next_state = (ARVALID_M1 && ARREADY_S1) ? R_M1_S1 : AR_M1_S1;

            R_M0_S0: next_state = (RREADY_M0 && RVALID_S0 && RLAST_S0) ? IDLE : R_M0_S0;
            R_M1_S0: next_state = (RREADY_M1 && RVALID_S0 && RLAST_S0) ? IDLE : R_M1_S0;
            R_M1_S1: next_state = (RREADY_M1 && RVALID_S1 && RLAST_S1) ? IDLE : R_M1_S1;
        endcase
    end

    always_comb begin
        unique case (state)
            AR_M0_S0:   AR_state = 3'd1;
            AR_M1_S0:   AR_state = 3'd2;
            AR_M1_S1:   AR_state = 3'd3;
            default:    AR_state = 3'd0;
        endcase
    end

    always_comb begin
        unique case (state)
            R_M0_S0:    R_state = 3'd1;
            R_M1_S0:    R_state = 3'd2;
            R_M1_S1:    R_state = 3'd3;
            default:    R_state = 3'd0;
        endcase
    end
endmodule