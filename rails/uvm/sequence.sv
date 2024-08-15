class rand_num;
    randc logic [3:0] data;
endclass

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
            trans.reset = 1'b0;
        finish_item(trans);

        start_item(trans);
            trans.reset = 1'b1;
        finish_item(trans);

        repeat (3) begin
            start_item(trans);
                trans.reset = 1'b1;
            finish_item(trans);
        end
    endtask

    virtual task work();

        rand_num num = new();
        trans = transaction::type_id::create("trans");

        start_item(trans);

            trans.reset = 1'b0;
            rand_var = $urandom_range(9, 3);
            trans.data_queue.push_back(rand_var);
            while (rand_var--) begin
                num.randomize() with {
                    trans.data_queue[0] >= num.data;
                    num.data != 0;
                };
                trans.data_queue.push_back(num.data);
            end

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