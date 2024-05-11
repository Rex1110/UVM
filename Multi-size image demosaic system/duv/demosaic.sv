module demosaic(
    input                   clk,
    input                   reset,

    input                   in_en,
    input           [ 7:0]  data_in,
    output  logic   [18:0]  img_addr,

    input           [10:0]  width,
    input           [10:0]  height,

    output  logic           wr_r,
    output  logic   [18:0]  addr_r,
    output  logic   [ 7:0]  wdata_r,
    input           [ 7:0]  rdata_r,

    output  logic           wr_g,
    output  logic   [18:0]  addr_g,
    output  logic   [ 7:0]  wdata_g,
    input           [ 7:0]  rdata_g,

    output  logic           wr_b,
    output  logic   [18:0]  addr_b,
    output  logic   [ 7:0]  wdata_b,
    input           [ 7:0]  rdata_b,

    output  logic           done
);

    localparam IDLE                 = 3'd0;
    localparam READ_BAYER_PATTERN   = 3'd1;
    localparam INTERPOLATION        = 3'd2;
    localparam SAVE_RGB_CHANNEL     = 3'd3;
    localparam DONE                 = 3'd4;
    
    logic [2:0] state, next_state;
    logic [1:0] filter;
    logic [18:0] cnt;
    logic [9:0] acc_g, acc_r, acc_b;
    logic [1:0] acc_cnt;
    logic [10:0] width_cnt;
    logic odd_row;
    logic [10:0] height_ff, width_ff;


    // 用於判斷目前在處理 even row 或是 odd row
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            width_cnt <= 'd0;
        end else if (state == IDLE) begin
            width_cnt <= 'd0;
        end else if (state == READ_BAYER_PATTERN || state == SAVE_RGB_CHANNEL) begin
            if (width_cnt == (width_ff - 'd1)) begin
                width_cnt <= 'd0;
            end else begin
                width_cnt <= width_cnt + 'd1;
            end
        end else begin
            width_cnt <= width_cnt;
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            odd_row <= 'd0;
        end else if (state == IDLE || (state == READ_BAYER_PATTERN && next_state == INTERPOLATION)) begin
            odd_row <= 'd0;
        end else if ((width_cnt == (width_ff - 'd1)) && (state == READ_BAYER_PATTERN || state == SAVE_RGB_CHANNEL)) begin
            odd_row <= ~odd_row;    
        end else begin
            odd_row <= odd_row;
        end 
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            width_ff  <= 'd0;
            height_ff <= 'd0;
        end else if (in_en) begin
            width_ff  <= width;
            height_ff <= height;
        end else begin
            width_ff  <= width_ff;
            height_ff <= height_ff;
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        unique case (state) 
            IDLE: begin
                if (in_en) begin
                    next_state = READ_BAYER_PATTERN;
                end else begin
                    next_state = IDLE;
                end
            end

            READ_BAYER_PATTERN: begin
                if (cnt == (height_ff * width_ff -'d1)) begin
                    next_state = INTERPOLATION;
                end else begin
                    next_state = READ_BAYER_PATTERN;
                end
            end

            INTERPOLATION: begin
                if (odd_row == 'd0) begin
                    if (width_cnt[0] == 1'b0) begin
                        next_state = (filter == 2'b01) ? SAVE_RGB_CHANNEL : INTERPOLATION;
                    end else begin
                        next_state = (filter == 2'b11) ? SAVE_RGB_CHANNEL : INTERPOLATION;
                    end
                end else begin
                    if (width_cnt[0] == 1'b0) begin
                        next_state = (filter == 2'b11) ? SAVE_RGB_CHANNEL : INTERPOLATION;
                    end else begin
                        next_state = (filter == 2'b01) ? SAVE_RGB_CHANNEL : INTERPOLATION;
                    end
                end
            end
            SAVE_RGB_CHANNEL: begin
                if (cnt == (height_ff * width_ff -'d1)) begin
                    next_state = DONE;
                end else begin
                    next_state = INTERPOLATION;
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            cnt <= 'd0;
        end else if (state == IDLE) begin
            cnt <= 'd0;
        end else if (state == READ_BAYER_PATTERN) begin
            if (cnt == (height_ff * width_ff - 'd1)) begin
                cnt <= 'd0;
            end else begin
                cnt <= cnt + 'd1;
            end
        end else if (state == SAVE_RGB_CHANNEL) begin
            cnt <= cnt + 'd1;
        end else begin
            cnt <= cnt;
        end
    end

    always_comb begin
        unique case (state)
            READ_BAYER_PATTERN: begin
                if (odd_row == 'd0) begin
                    if (width_cnt[0] == 1'b0) begin
                        wr_r = 1'b0;
                        wr_g = 1'b1;
                        wr_b = 1'b0;
                    end else begin
                        wr_r = 1'b1;
                        wr_g = 1'b0;
                        wr_b = 1'b0;
                    end
                end else begin
                    if (width_cnt[0] == 1'b0) begin
                        wr_r = 1'b0;
                        wr_g = 1'b0;
                        wr_b = 1'b1;
                    end else begin
                        wr_r = 1'b0;
                        wr_g = 1'b1;
                        wr_b = 1'b0;
                    end
                end
            end

            SAVE_RGB_CHANNEL: begin
                if (odd_row == 'd0) begin
                    if (width_cnt[0] == 1'b0) begin
                        wr_r = 1'b1;
                        wr_g = 1'b0;
                        wr_b = 1'b1;
                    end else begin
                        wr_r = 1'b0;
                        wr_g = 1'b1;
                        wr_b = 1'b1;
                    end
                end else begin
                    if (width_cnt[0] == 1'b0) begin
                        wr_r = 1'b1;
                        wr_g = 1'b1;
                        wr_b = 1'b0;
                    end else begin
                        wr_r = 1'b1;
                        wr_g = 1'b0;
                        wr_b = 1'b1;
                    end
                end
            end

            default: begin
                wr_r = 1'b0;
                wr_g = 1'b0;
                wr_b = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            filter <= 'b0;
        end else if (state == IDLE) begin
            filter <= 'b0;
        end else if (state == INTERPOLATION) begin
            if (odd_row == 'd0) begin
                if (width_cnt[0] == 1'b0) begin
                    filter <= filter ^ 2'b1;
                end else begin
                    filter <= filter + 2'b1;
                end
            end else begin
                if (width_cnt[0] == 1'b0) begin
                    filter <= filter + 2'b1;
                end else begin
                    filter <= filter ^ 2'b1;
                end
            end
        end else begin
            filter <= filter;
        end
    end

    assign img_addr = cnt;

    always_comb begin
        if (state == READ_BAYER_PATTERN || state == SAVE_RGB_CHANNEL) begin
            addr_r = cnt;
            addr_g = cnt;
            addr_b = cnt;
        end else begin
            if (odd_row == 'd0) begin
                if (width_cnt[0] == 1'b0) begin
                    if (filter == 2'b0) begin
                        addr_r = cnt - 'd1;
                        addr_g = cnt;
                        addr_b = cnt - width_ff;
                    end else begin
                        addr_r = cnt + 'd1;
                        addr_g = cnt;
                        addr_b = cnt + width_ff;
                    end
                end else begin
                    if (filter == 2'b0) begin
                        addr_r = cnt;
                        addr_g = cnt - width_ff;
                        addr_b = cnt - (width_ff + 'd1);
                    end else if (filter == 2'b01) begin
                        addr_r = cnt;
                        addr_g = cnt - 'd1;
                        addr_b = cnt - (width_ff - 'd1);
                    end else if (filter == 2'b10) begin
                        addr_r = cnt;
                        addr_g = cnt + 'd1;
                        addr_b = cnt + (width_ff - 'd1);
                    end else if (filter == 2'b11) begin
                        addr_r = cnt;
                        addr_g = cnt + width_ff;
                        addr_b = cnt + (width_ff + 'd1);
                    end
                end
            end else begin
                if (width_cnt[0] == 1'b0) begin
                    if (filter == 2'b0) begin
                        addr_r = cnt - (width_ff + 'd1);
                        addr_g = cnt - width_ff;
                        addr_b = cnt;
                    end else if (filter == 2'b01) begin
                        addr_r = cnt - (width_ff - 'd1);
                        addr_g = cnt - 'd1;
                        addr_b = cnt;
                    end else if (filter == 2'b10) begin
                        addr_r = cnt + (width_ff - 'd1);
                        addr_g = cnt + 'd1;
                        addr_b = cnt;
                    end else if (filter == 2'b11) begin
                        addr_r = cnt + (width_ff + 'd1);
                        addr_g = cnt + width_ff;
                        addr_b = cnt;
                    end
                end else begin
                    if (filter == 2'b0) begin
                        addr_r = cnt - width_ff;
                        addr_g = cnt;
                        addr_b = cnt - 'd1;
                    end else begin
                        addr_r = cnt + width_ff;
                        addr_g = cnt;
                        addr_b = cnt + 'd1;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            acc_r <= 'd0;
            acc_g <= 'd0;
            acc_b <= 'd0;
        end else if (state == IDLE) begin
            acc_r <= 'd0;
            acc_g <= 'd0;
            acc_b <= 'd0;
        end else if (state == INTERPOLATION) begin
            acc_r <= acc_r + rdata_r;
            acc_g <= acc_g + rdata_g;
            acc_b <= acc_b + rdata_b;
        end else if (state == SAVE_RGB_CHANNEL) begin
            acc_r <= 'd0;
            acc_g <= 'd0;
            acc_b <= 'd0;
        end else begin
            acc_r <= acc_r;
            acc_g <= acc_g;
            acc_b <= acc_b;
        end
    end
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            acc_cnt <= 'd0;
        end else if (state == IDLE) begin
            acc_cnt <= 'd0;
        end else begin
            acc_cnt <= filter;
        end
    end

    always_comb begin
        if (state == SAVE_RGB_CHANNEL) begin
            wdata_r = acc_r >> ((acc_cnt >> 1) + 'd1);
            wdata_g = acc_g >> ((acc_cnt >> 1) + 'd1);
            wdata_b = acc_b >> ((acc_cnt >> 1) + 'd1);
        end else begin
            wdata_r = data_in;
            wdata_g = data_in;
            wdata_b = data_in;
        end
    end

    assign done = (state == DONE);
endmodule
