class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    logic        reset;
    logic        in_en;
    logic        startWork;
    logic [ 7:0] height;
    logic [ 8:0] width;

    logic [ 7:0] bayer_img [`IMG_SIZE];
    logic [ 7:0] channel_r [`IMG_SIZE];
    logic [ 7:0] channel_g [`IMG_SIZE];
    logic [ 7:0] channel_b [`IMG_SIZE];

    function new(string name = "transaction");
        super.new(name);
    endfunction

    
endclass