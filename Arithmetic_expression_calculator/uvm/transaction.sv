class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)
    
    logic           startWork;
    logic           rst;
    logic           ready;
    logic [31:0]    result;
    logic [ 7:0]    ascii_in;
    logic [ 7:0]    data_queue[$];
    logic           valid;

    function new(string name = "transaction");
        super.new(name);
    endfunction
endclass