class seq extends uvm_sequence #(transaction);
    `uvm_object_utils(seq)

    transaction trans;

    function new(string name = "seq");
        super.new(name);
    endfunction

    virtual task wrok();
        trans = transaction::type_id::create("trans");
        start_item(trans);
            assert(trans.randomize());
            trans.ARESETn = 'd1;
        finish_item(trans);
    endtask

    virtual task body();
        $display("\n\n");
        repeat(`TESTCOUNT) seq::wrok();
    endtask
endclass