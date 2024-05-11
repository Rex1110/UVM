class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    logic        reset;
    logic        in_en;

    logic [10:0] height;
    logic [10:0] width;

    logic [ 7:0] bayer_img [$];
    logic [ 7:0] channel_r [$];
    logic [ 7:0] channel_g [$];
    logic [ 7:0] channel_b [$];

    function new(string name = "transaction");
        super.new(name);
    endfunction

    
endclass