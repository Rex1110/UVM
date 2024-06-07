module Write_Arbiter(
    input   ACLK,
    input   ARESETn,
    // AW
    input   [`AXI_ADDR_BITS-1:0 ]   AWADDR_M1,
    input                           AWVALID_M1,

    input                           AWREADY_S0,
    input                           AWREADY_S1,
    // W
    input                           WLAST_M1,
    input                           WVALID_M1,

    input                           WREADY_S0,
    input                           WREADY_S1,
    // B
    input                           BVALID_S0,
    input                           BVALID_S1,

    input                           BREADY_M1,

    output  logic   [1:0]           W_state,
    output  logic   [1:0]           B_state
);
    localparam IDLE     = 4'd0;
    localparam AW_M1_S1 = 4'd2;
    localparam W_M1_S1  = 4'd4;
    localparam B_M1_S1  = 4'd6;

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
                if (AWVALID_M1) begin
                    if (AWADDR_M1[31:16] == 16'd1) begin
                        next_state = AW_M1_S1;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin
                    next_state = IDLE;
                end 
            end

            AW_M1_S1: next_state = (AWVALID_M1 && AWREADY_S1) ? W_M1_S1 : AW_M1_S1;

            W_M1_S1 : next_state = (WVALID_M1 && WREADY_S1 && WLAST_M1) ? B_M1_S1 : W_M1_S1;

            B_M1_S1 : next_state = (BREADY_M1 && BVALID_S1) ? IDLE : B_M1_S1;

            default : next_state = IDLE;
        endcase
    end

    always_comb begin
        unique case (state)

            AW_M1_S1, 
            W_M1_S1 : W_state = 2'b10;

            default : W_state = 2'b0;
        endcase
    end

    always_comb begin
        unique case (state)
            B_M1_S1: B_state = 2'b10;
            default: B_state = 2'b00;
        endcase
    end

endmodule