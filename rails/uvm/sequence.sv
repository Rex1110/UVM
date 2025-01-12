class seq extends uvm_sequence #(transaction);
    `uvm_object_utils(seq)

    transaction trans;
    randc logic [3:0] rand_var;
    
    function new(string name = "seq");
        super.new(name);
    endfunction

    virtual task reset();
        $display("--------------------------------------------rst--------------------------------------------");
        trans = transaction::type_id::create("trans");
        start_item(trans);
            trans.reset = 1'b1;
        finish_item(trans);

    endtask

    virtual task work();

        trans = transaction::type_id::create("trans");

        start_item(trans);

            trans.reset = 1'b0;
            rand_var = $urandom_range(9, 3);
            for (int i = 0; i < rand_var; i++) begin
                trans.data_queue.push_back(i+1);
            end
            trans.data_queue.shuffle();

            trans.data_queue.push_front(rand_var);

        finish_item(trans);
        
    endtask

    virtual task body();
        int t = 1;
        seq::reset();
        $display("--------------------------------------------work--------------------------------------------");
        repeat (`TESTCOUNT) begin
            $display("=================================================");
            $display("                The %0d test case", t++);
            seq::work();
        end
    endtask

endclass