interface duv_if();
    logic           clk;
    logic           reset;
    logic   [3:0]   data;
    logic           valid;
    logic           result;
    logic   [3:0]   data_queue[$];
endinterface