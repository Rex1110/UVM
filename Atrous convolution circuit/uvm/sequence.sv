class seq extends uvm_sequence#(transaction);
    `uvm_object_utils(seq)

    transaction trans;

    function new(string name = "sequence");
        super.new(name);
    endfunction

    virtual task reset(ref transaction trans);
        start_item(trans);
            trans.reset = 1'b1;
            trans.ready = 1'b0;
            foreach (trans.image_mem[i]) begin
                trans.image_mem[i] = 13'd0;
            end
        finish_item(trans);
    endtask

    virtual task ready(ref transaction trans);
        start_item(trans);
            trans.reset = 1'b0;
            trans.ready = 1'b1;
            if (!trans.randomize() with {
                foreach (image_mem[i]) {
                    image_mem[i][12] == 1'b0;
                    image_mem[i][3:0] == 4'b0;
                }
            })
                `uvm_error("seq", "trans rand failed")
        finish_item(trans);
    endtask

    
    virtual task wait_for_finish(ref transaction trans);
        start_item(trans);
            trans.ready = 1'b0;
        finish_item(trans);
    endtask

    virtual task body();
        trans = transaction::type_id::create("trans");
        repeat (3) begin
            seq::reset(trans);
        end
        repeat (`TESTCOUNT) begin
            seq::ready(trans);
            seq::wait_for_finish(trans);
        end
        
    endtask
endclass