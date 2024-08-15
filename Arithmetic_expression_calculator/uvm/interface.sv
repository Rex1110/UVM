interface duv_if();
    logic           clk;
    logic           rst;
    logic [ 7:0]    ascii_in;
    logic [31:0]    result;
    logic           ready;
    logic           finish;
    logic           startWork;

    logic [ 7:0]    data_queue[$];
endinterface