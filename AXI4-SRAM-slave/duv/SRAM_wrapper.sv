module SRAM_wrapper(
    input   ACLK,
    input   ARESETn,

    input   [`AXI_IDS_BITS-1:0  ]   AWID,
    input   [`AXI_ADDR_BITS-1:0 ]   AWADDR,
    input   [`AXI_LEN_BITS-1:0  ]   AWLEN,
    input   [`AXI_SIZE_BITS-1:0 ]   AWSIZE,
    input   [1:0                ]   AWBURST,
    input                           AWVALID,
    output  logic                   AWREADY,

    input   [`AXI_DATA_BITS-1:0 ]   WDATA,
    input   [`AXI_STRB_BITS-1:0 ]   WSTRB,
    input                           WLAST,
    input                           WVALID,
    output  logic                   WREADY,

    output  logic   [`AXI_IDS_BITS-1:0  ]   BID,
    output  logic   [1:0                ]   BRESP,
    output  logic                           BVALID,
    input                                   BREADY,

    input   [`AXI_IDS_BITS-1:0  ]   ARID,
    input   [`AXI_ADDR_BITS-1:0 ]   ARADDR,
    input   [`AXI_LEN_BITS-1:0  ]   ARLEN,
    input   [`AXI_SIZE_BITS-1:0 ]   ARSIZE,
    input   [1:0                ]   ARBURST,
    input                           ARVALID,
    output  logic                   ARREADY,

    output  logic   [`AXI_IDS_BITS-1:0  ]   RID,
    output  logic   [`AXI_DATA_BITS-1:0 ]   RDATA,
    output  logic   [1:0                ]   RRESP,
    output  logic                           RLAST,
    output  logic                           RVALID,
    input                                   RREADY
);
    logic [13:0] A;
    logic [`AXI_STRB_BITS-1:0] WEB;
    logic [`AXI_DATA_BITS-1:0] DI;
    logic [`AXI_DATA_BITS-1:0] DO;

    logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
    logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
    logic [`AXI_SIZE_BITS-1:0 ] arsizeReg;

    logic [2:0] state, next_state;
    logic [1:0] awsize_cnt, arsize_cnt;
    logic [3:0] read_burst_cnt, write_burst_cnt;

    localparam IDLE             = 3'd0;
    localparam READ_ADDRESS     = 3'd1;
    localparam READ_DATA        = 3'd2;
    localparam WRITE_ADDRESS    = 3'd3;
    localparam WRITE_DATA       = 3'd4;
    localparam WRITE_RESPONSE   = 3'd5;
    
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
                if (AWVALID) begin
                    next_state = WRITE_ADDRESS;
                end else if (ARVALID) begin
                    next_state = READ_ADDRESS;
                end else begin
                    next_state = IDLE;
                end
            end 
            WRITE_ADDRESS   : next_state = (AWVALID && AWREADY) ? WRITE_DATA : WRITE_ADDRESS;
            WRITE_DATA      : next_state = (WVALID && WREADY && WLAST) ? WRITE_RESPONSE : WRITE_DATA;
            WRITE_RESPONSE  : next_state = (BVALID && BREADY) ? IDLE : WRITE_RESPONSE;

            READ_ADDRESS    : next_state = (ARVALID && ARREADY) ? READ_DATA : READ_ADDRESS;
            READ_DATA       : next_state = (RVALID && RREADY && RLAST) ? IDLE : READ_DATA;

            default         : next_state = IDLE;
        endcase
    end

    assign AWREADY  = (state == WRITE_ADDRESS) ? 1'b1 : 1'b0;
    assign WREADY   = (state == WRITE_DATA) ? 1'b1 : 1'b0;

    assign BRESP    = `AXI_RESP_OKAY;
    assign BVALID   = (state == WRITE_RESPONSE) ? 1'b1 : 1'b0;

    assign ARREADY  = (state == READ_ADDRESS) ? 1'b1 : 1'b0;

    
    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            arsizeReg <= 'd0;
        end else if (ARVALID && ARREADY) begin
            arsizeReg <= ARSIZE;
        end else begin
            arsizeReg <= arsizeReg;
        end
    end
    always_comb begin
        if (arsizeReg == 'd0) begin
            if (arsize_cnt == 'd3) begin
                RDATA = DO[7:0];
            end else if (arsize_cnt == 'd2) begin
                RDATA = DO[15:8];
            end else if (arsize_cnt == 'd1) begin
                RDATA = DO[23:16];
            end else begin
                RDATA = DO[31:24];
            end
        end else if (arsizeReg == 'd1) begin
            if (arsize_cnt == 'd2) begin
                RDATA = DO[15:0];
            end else begin
                RDATA = DO[31:16];
            end
        end else begin
            RDATA = DO;
        end
    end
    assign RRESP    = `AXI_RESP_OKAY;
    assign RLAST    = ((state == READ_DATA) && (read_burst_cnt == 0)) ? 1'b1 : 1'b0;

    assign RVALID   = (state == READ_DATA) ? 1'b1 : 1'b0;

    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            BID <= 8'd0;
            RID <= 8'd0;
        end else begin
            BID <= (AWVALID && AWREADY) ? AWID : BID;
            RID <= (ARVALID && ARREADY) ? ARID : RID;
        end
    end

    // ADDR reg
    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            read_burst_cnt  <= 4'd0;
            ARADDR_reg      <= 32'd0;
        end else begin
            if (ARVALID && ARREADY) begin
                read_burst_cnt  <= ARLEN;
                ARADDR_reg      <= ARADDR;
            end else if (RVALID && RREADY) begin
                read_burst_cnt  <= read_burst_cnt - 4'd1;
                if (arsize_cnt == 'd0) begin
                    ARADDR_reg <= ARADDR_reg + 'd4;
                end else begin
                    ARADDR_reg <= ARADDR_reg;
                end
            end
        end
    end
    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            write_burst_cnt <= 4'd0;
            AWADDR_reg      <= 'd0;
        end else begin
            if (AWVALID && AWREADY) begin
                write_burst_cnt <= AWLEN;
                AWADDR_reg      <= AWADDR;
            end else if (WVALID && WREADY) begin
                write_burst_cnt <= write_burst_cnt - 'd1;
                if (awsize_cnt == 'd0) begin
                    AWADDR_reg <= AWADDR_reg + 'd4;
                end else begin
                    AWADDR_reg <= AWADDR_reg;
                end
            end
        end
    end

    // burst cnt
    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            arsize_cnt <= 'd0;
        end else begin
            if (ARVALID && ARREADY) begin
                if (ARSIZE == 'd0) begin
                    arsize_cnt <= 'd3;
                end else if (ARSIZE == 'd1) begin
                    arsize_cnt <= 'd2;
                end else begin
                    arsize_cnt <= 'd0;
                end
            end else if (RVALID && RREADY) begin
                if (ARSIZE == 'd0) begin
                    arsize_cnt <= arsize_cnt - 'd1;
                end else if (ARSIZE == 'd1) begin
                    arsize_cnt <= arsize_cnt - 'd2;
                end else begin
                    arsize_cnt <= 'd0;
                end
            end
        end
    end

    always_ff @(posedge ACLK, negedge ARESETn) begin
        if (~ARESETn) begin
            awsize_cnt <= 'd0;
        end else begin
            if (AWVALID && AWREADY) begin
                if (AWSIZE == 'd0) begin
                    awsize_cnt <= 'd3;
                end else if (AWSIZE == 'd1) begin
                    awsize_cnt <= 'd2;
                end else begin
                    awsize_cnt <= 'd0;
                end
            end else if (WVALID && WREADY) begin
                if (AWSIZE == 'd0) begin
                    awsize_cnt <= awsize_cnt - 'd1;
                end else if (AWSIZE == 'd1) begin
                    awsize_cnt <= awsize_cnt - 'd2;
                end else begin
                    awsize_cnt <= 'd0;
                end
            end
        end
    end
    

    always_comb begin
        if (state == WRITE_DATA) begin
            A = AWADDR_reg[15:2];
        end else if (state == READ_ADDRESS) begin
            A = ARADDR[15:2];
        end else if (state == READ_DATA) begin
            if (RVALID && RREADY && (arsize_cnt == 'd0)) begin
                A = ARADDR_reg[15:2] + 14'd1;
            end else begin
                A = ARADDR_reg[15:2];
            end
        end else begin
            A = 'd0;
        end
    end
    
    always_comb begin
        if (WVALID && WREADY) begin
            if (AWSIZE == 'd0) begin
                case (awsize_cnt)
                    'd0: begin
                        WEB = WSTRB << 3;
                        DI  = WDATA << 24;
                    end
                    'd1: begin
                        WEB = WSTRB << 2;
                        DI  = WDATA << 16;
                    end
                    'd2: begin
                        WEB = WSTRB << 1;
                        DI  = WDATA << 8;
                    end
                    'd3: begin
                        WEB = WSTRB;
                        DI  = WDATA;
                    end
                endcase
            end else if (AWSIZE == 'd1) begin
                case (awsize_cnt) 
                    'd0: begin
                        WEB = WSTRB << 2;
                        DI  = WDATA << 16;
                    end
                    'd2: begin
                        WEB = WSTRB;
                        DI  = WDATA;
                    end
                endcase
            end else begin
                WEB = WSTRB;
                DI  = WDATA;
            end
        end else begin
            WEB = 'd0;
            DI  = 'd0;
        end
    end

SRAM  i_SRAM (
    .A0     (A[0]  ),
    .A1     (A[1]  ),
    .A2     (A[2]  ),
    .A3     (A[3]  ),
    .A4     (A[4]  ),
    .A5     (A[5]  ),
    .A6     (A[6]  ),
    .A7     (A[7]  ),
    .A8     (A[8]  ),
    .A9     (A[9]  ),
    .A10    (A[10] ),
    .A11    (A[11] ),
    .A12    (A[12] ),
    .A13    (A[13] ),
    .DO0    (DO[0] ),
    .DO1    (DO[1] ),
    .DO2    (DO[2] ),
    .DO3    (DO[3] ),
    .DO4    (DO[4] ),
    .DO5    (DO[5] ),
    .DO6    (DO[6] ),
    .DO7    (DO[7] ),
    .DO8    (DO[8] ),
    .DO9    (DO[9] ),
    .DO10   (DO[10]),
    .DO11   (DO[11]),
    .DO12   (DO[12]),
    .DO13   (DO[13]),
    .DO14   (DO[14]),
    .DO15   (DO[15]),
    .DO16   (DO[16]),
    .DO17   (DO[17]),
    .DO18   (DO[18]),
    .DO19   (DO[19]),
    .DO20   (DO[20]),
    .DO21   (DO[21]),
    .DO22   (DO[22]),
    .DO23   (DO[23]),
    .DO24   (DO[24]),
    .DO25   (DO[25]),
    .DO26   (DO[26]),
    .DO27   (DO[27]),
    .DO28   (DO[28]),
    .DO29   (DO[29]),
    .DO30   (DO[30]),
    .DO31   (DO[31]),
    .DI0    (DI[0] ),
    .DI1    (DI[1] ),
    .DI2    (DI[2] ),
    .DI3    (DI[3] ),
    .DI4    (DI[4] ),
    .DI5    (DI[5] ),
    .DI6    (DI[6] ),
    .DI7    (DI[7] ),
    .DI8    (DI[8] ),
    .DI9    (DI[9] ),
    .DI10   (DI[10]),
    .DI11   (DI[11]),
    .DI12   (DI[12]),
    .DI13   (DI[13]),
    .DI14   (DI[14]),
    .DI15   (DI[15]),
    .DI16   (DI[16]),
    .DI17   (DI[17]),
    .DI18   (DI[18]),
    .DI19   (DI[19]),
    .DI20   (DI[20]),
    .DI21   (DI[21]),
    .DI22   (DI[22]),
    .DI23   (DI[23]),
    .DI24   (DI[24]),
    .DI25   (DI[25]),
    .DI26   (DI[26]),
    .DI27   (DI[27]),
    .DI28   (DI[28]),
    .DI29   (DI[29]),
    .DI30   (DI[30]),
    .DI31   (DI[31]),
    .CK     (ACLK  ),
    .WEB0   (~WEB[0]),
    .WEB1   (~WEB[1]),
    .WEB2   (~WEB[2]),
    .WEB3   (~WEB[3]),
    .OE     (1'b1  ),
    .CS     (1'b1  )
);

endmodule
