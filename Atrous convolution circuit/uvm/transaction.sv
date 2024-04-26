class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    logic reset;
    logic ready;

    rand logic [12:0] image_mem [0:4095];
    logic [12:0] layer1_mem [0:4095];
    logic [12:0] layer2_mem [0:1023];

    function new(string name = "transaction");
        super.new(name);
    endfunction
endclass