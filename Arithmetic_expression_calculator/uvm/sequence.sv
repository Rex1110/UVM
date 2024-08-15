class num;
    rand logic [7:0] opd1, opd2, op;

    constraint operator {
        ((opd1 > 47 && opd1 < 58) || (opd1 > 96 && opd1 < 103)) &&
        ((opd2 > 47 && opd2 < 58) || (opd2 > 96 && opd2 < 103));
    }

    constraint operand {
        (op == 42 || op == 43 || op == 45);
    }
endclass

class seq extends uvm_sequence #(transaction);
    `uvm_object_utils(seq)
    
    transaction trans;

    function new(string name = "seq");
        super.new(name);
    endfunction

    virtual task rst();
        $display("--------------------------------------------rst--------------------------------------------");
        trans = transaction::type_id::create("trans");
        start_item(trans);
            trans.rst = 1'b0;
            trans.startWork = 1'b0;
        finish_item(trans);
        start_item(trans);
            trans.rst = 1'b1;
            trans.startWork = 1'b0;
        finish_item(trans);

    endtask
    
    virtual task tree(ref logic [7:0] q[$]);
        int cnt = $urandom_range(`TREE_DEPTH_MIN, `TREE_DEPTH_MAX);
        num n = new();
        n.randomize();
        q.push_back(n.opd1);
        while (cnt--) begin
            n.randomize();
            case ($urandom_range(0, 5))
                0, 1: begin
                    q.push_front(n.op);
                    q.push_front(n.opd1);
                end 
                2, 3: begin
                    q.push_back(n.op);
                    q.push_back(n.opd1);
                end
                4, 5: begin // 40 = (, 41 = )
                    q.push_front(40);
                    q.push_back(41);
                end
            endcase
        end
    endtask

    virtual task forest();
        logic [7:0] q[][$];
        q = new[$urandom_range(`TREE_NUM_MIN, `TREE_NUM_MAX)];

        foreach (q[i]) seq::tree(q[i]);

        for (int i = 1; i < q.size(); i++) begin
            case ($urandom_range(0, 2))
                0: q[0].push_back(42); // *
                1: q[0].push_back(43); // +
                2: q[0].push_back(45); // -
            endcase
            foreach (q[i][j]) begin
                q[0].push_back(q[i][j]);
            end
        end

        q[0].push_back(61); // =
        start_item(trans);
            trans.rst = 1'b0;
            trans.startWork = 1'b1;
            trans.data_queue = q[0];
        finish_item(trans);
        
    endtask


    virtual task body();
        repeat (3) seq::rst();
        $display("--------------------------------------------work--------------------------------------------");
        repeat (`TESTCOUNT) seq::forest();
    endtask

endclass