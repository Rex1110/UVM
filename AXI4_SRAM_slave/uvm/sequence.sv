class seq extends uvm_sequence #(transaction);
    `uvm_object_utils(seq)

    transaction trans;

    function new(string name = "seq");
        super.new(name);
    endfunction


    virtual task rst();
        trans = transaction::type_id::create("trans");
        repeat (2) begin
            start_item(trans);
                trans.ARESETn = 'd0;
                trans.startWork = 1'b0;
            finish_item(trans);

            start_item(trans);
                trans.ARESETn = 'd1;
                trans.startWork = 1'b0;
            finish_item(trans);
        end

        start_item(trans);
            trans.ARESETn = 'd0;
            trans.startWork = 1'b1;
        finish_item(trans);
    endtask

    virtual task wrok();
        trans = transaction::type_id::create("trans");
        start_item(trans);
            trans.startWork = 1'b1;
            assert(trans.randomize());
            trans.ARESETn = 'd1;
        finish_item(trans);
    endtask

    virtual task body();
        $display("\n\n");
        seq::rst();
        repeat(`TESTCOUNT) seq::wrok();
    endtask
endclass