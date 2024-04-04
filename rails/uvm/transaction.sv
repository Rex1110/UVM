class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    logic           reset;
    logic           result;

    logic   [3:0]   data_queue[$];

    function new(string name = "transaction");
        super.new(name);
    endfunction
endclass