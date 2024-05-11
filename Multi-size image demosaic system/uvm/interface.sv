interface duv_if;
    logic clk;
    logic reset;
    logic in_en;
    logic done;
    
    logic [10:0] height;
    logic [10:0] width;

    logic [7:0] data_in;

    logic [7:0] bayer_img [$];
    logic [7:0] channel_r [$];
    logic [7:0] channel_g [$];
    logic [7:0] channel_b [$];
endinterface