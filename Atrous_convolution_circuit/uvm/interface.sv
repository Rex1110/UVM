interface duv_if();
    logic clk;
    logic reset;
    logic ready;
    logic busy;
    logic startWork;

    logic [12:0] image_mem [0:4095];
    logic [12:0] layer1_mem [0:4095];
    logic [12:0] layer2_mem [0:1023];
endinterface