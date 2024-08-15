interface duv_if;
    logic clk;
    logic reset;
    logic in_en;
    logic done;
    logic startWork;
    logic [7:0] height;
    logic [8:0] width;

    logic [7:0] bayer_img [`IMG_SIZE];
    logic [7:0] channel_r [`IMG_SIZE];
    logic [7:0] channel_g [`IMG_SIZE];
    logic [7:0] channel_b [`IMG_SIZE];
endinterface