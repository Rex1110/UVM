module top#(
    parameter  WIDTH = 1024,
    parameter  HEIGHT = 512,
    parameter  IMG_SIZE = WIDTH * HEIGHT
)(
    input                   clk,
    input                   reset,
    input                   in_en,

    input           [ 7:0]  bayer_img [$],

    input           [10:0]  height,
    input           [10:0]  width,

    output  logic   [ 7:0]  channel_r [$],
    output  logic   [ 7:0]  channel_g [$],
    output  logic   [ 7:0]  channel_b [$],

    output  logic           done
);
    logic [ 7:0] data_in;
    logic wr_r, wr_g, wr_b;
    logic [18:0] addr_r, addr_g, addr_b, img_addr;
    logic [ 7:0] wdata_r, wdata_g, wdata_b;
    logic [ 7:0] rdata_r, rdata_g, rdata_b;

    logic [ 7:0] bayer_ff [0:IMG_SIZE-1];
    logic [ 7:0] channel_r_ff [0:IMG_SIZE-1];
    logic [ 7:0] channel_g_ff [0:IMG_SIZE-1];
    logic [ 7:0] channel_b_ff [0:IMG_SIZE-1];

    demosaic demosaic_(
        .clk        (clk    ),
        .reset      (reset  ),

        .in_en      (in_en  ),
        .data_in    (data_in),
        .img_addr   (img_addr),

        .height     (height ),
        .width      (width  ),
        
        .wr_r       (wr_r   ),
        .addr_r     (addr_r ),
        .wdata_r    (wdata_r),
        .rdata_r    (rdata_r),

        .wr_g       (wr_g   ),
        .addr_g     (addr_g ),
        .wdata_g    (wdata_g),
        .rdata_g    (rdata_g),

        .wr_b       (wr_b   ),
        .addr_b     (addr_b ),
        .wdata_b    (wdata_b),
        .rdata_b    (rdata_b),

        .done       (done   )
    );



    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < IMG_SIZE; i = i + 1) begin
                bayer_ff[i] <= 'd0;
            end 
        end else if (in_en) begin
            for (integer i = 0; i < IMG_SIZE; i = i + 1) begin
                bayer_ff[i] <= bayer_img[i];
            end 
        end
    end

    assign data_in = bayer_ff[img_addr];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < IMG_SIZE; i = i + 1) begin
                channel_r_ff[i] <= 'd0;
            end
        end else if (wr_r) begin
            channel_r_ff[addr_r] <= wdata_r;
        end else begin

        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < IMG_SIZE; i = i + 1) begin
                channel_g_ff[i] <= 'd0;
            end
        end else if (wr_g) begin
            channel_g_ff[addr_g] <= wdata_g;
        end else begin

        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < IMG_SIZE; i = i + 1) begin
                channel_b_ff[i] <= 'd0;
            end
        end else if (wr_b) begin
            channel_b_ff[addr_b] <= wdata_b;
        end else begin

        end
    end

    assign rdata_r = channel_r_ff[addr_r];
    assign rdata_g = channel_g_ff[addr_g];
    assign rdata_b = channel_b_ff[addr_b];

    always_comb begin        
        wait (done);
        channel_r = channel_r_ff;
        channel_g = channel_g_ff;
        channel_b = channel_b_ff;
    end
endmodule