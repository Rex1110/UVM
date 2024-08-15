class seq extends uvm_sequence #(transaction);
    `uvm_object_utils(seq)

    transaction trans;
    function new(string name = "seq");
        super.new(name);
    endfunction

    virtual task reset();
        trans = transaction::type_id::create("trans");
        $display("--------------------------------------------rst--------------------------------------------");
        start_item(trans);
            trans.startWork = 1'b0;
            trans.reset = 1'b0;
        finish_item(trans);

        start_item(trans);
            trans.startWork = 1'b1;
            trans.reset = 1'b1;
        finish_item(trans);
    endtask

    virtual task waitf();
        start_item(trans);
            trans.startWork = 1'b1;
            trans.reset = 1'b0;
            trans.in_en = 1'b0;
        finish_item(trans);
    endtask

    virtual task bayer_img();

        int width_min = 0;
        int width_max = 0;
        int height_max = 0;
        int height_min = 0;

        trans = transaction::type_id::create("trans");

        start_item(trans);
            trans.startWork = 1'b1;
            trans.reset = 1'b0;
            trans.in_en = 1'b1;

            trans.width = $urandom_range(`WIDTH_MIN, `WIDTH_MAX);
            trans.height= $urandom_range(`HEIGHT_MIN, `HEIGHT_MAX);

            for (int i = 0; i < trans.width*trans.height; i++) begin
                trans.bayer_img[i] = $urandom_range(0, 255);
            end
        finish_item(trans);
    endtask

    virtual task body();
        repeat (3) seq::reset();
        for (int i = 0; i < `TESTCOUNT; i++) begin
            $display("=================================================");
            $display("                The %0d test case", i+1);
            seq::bayer_img();
            seq::waitf();
        end
    endtask
endclass