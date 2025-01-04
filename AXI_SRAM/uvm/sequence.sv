class seq#(int MEM_SIZE = `MEM_SIZE) extends uvm_sequence #(transaction);
    `uvm_object_param_utils(seq#(MEM_SIZE))

    int WADDR;
    int RADDR;
    transaction trans;

    typedef enum int {AW, AR, AWAR} MODE;

    function new(string name = "seq");
        super.new(name);
    endfunction

    task rst();
        trans = transaction::type_id::create("trans");
        start_item(trans);
            trans.randomize();
            trans.ARESETn = 1'b0;
            trans.AWVALID = 1'b0;
            trans.WVALID  = 1'b0;
            trans.ARVALID = 1'b0;
        finish_item(trans);
    endtask

    task run(MODE mode);
        trans = transaction::type_id::create("trans");
        start_item(trans);
            if (mode == AWAR) begin
                trans.randomize() with {
                    AWADDR[`AXI_ADDR_BITS-1] == 0;
                    ARADDR[`AXI_ADDR_BITS-1] == 0;
                    AWADDR/(2**AWSIZE)*(2**AWSIZE)+((2**AWSIZE)*(AWLEN+1)) < MEM_SIZE + 1;
                    ARADDR/(2**ARSIZE)*(2**ARSIZE)+((2**ARSIZE)*(ARLEN+1)) < MEM_SIZE + 1;
                    WLAST   == 1'd0;
                    BREADY  == 1'd0;
                    RREADY  == 1'd0;
                    ARESETn == 1'b1;
                };
            end else begin
                trans.randomize() with {
                    AWADDR == WADDR;
                    ARADDR == RADDR;
                    if (WADDR > (MEM_SIZE-1) || mode == AR) {
                        AWVALID == 1'b0;
                    }
                    if (RADDR > (MEM_SIZE-1) || mode == AW) {
                        ARVALID == 1'b0;
                    }
                    WLAST   == 1'd0;
                    BREADY  == 1'd0;
                    RREADY  == 1'd0;
                    ARESETn == 1'b1;
                };
                if (trans.AWVALID) begin
                    case (trans.AWBURST)
                        `FIXED: WADDR = WADDR / (2 ** trans.AWSIZE) * (2 ** trans.AWSIZE) + (2 ** trans.AWSIZE);
                        `INCR : WADDR = WADDR / (2 ** trans.AWSIZE) * (2 ** trans.AWSIZE) + (trans.AWLEN + 1) * (2 ** trans.AWSIZE);
                        `WRAP : WADDR = (WADDR / ((trans.AWLEN + 1) * (2 ** trans.AWSIZE))) * (trans.AWLEN + 1) * (2 ** trans.AWSIZE) + (trans.AWLEN + 1) * (2 ** trans.AWSIZE);
                    endcase
                end
                if (trans.ARVALID) begin
                    case (trans.ARBURST)
                        `FIXED: RADDR = RADDR / (2 ** trans.ARSIZE) * (2 ** trans.ARSIZE) + (2 ** trans.ARSIZE);
                        `INCR : RADDR = RADDR / (2 ** trans.ARSIZE) * (2 ** trans.ARSIZE) + (trans.ARLEN + 1) * (2 ** trans.ARSIZE);
                        `WRAP : RADDR = (RADDR / ((trans.ARLEN + 1) * (2 ** trans.ARSIZE))) * (trans.ARLEN + 1) * (2 ** trans.ARSIZE) + (trans.ARLEN + 1) * (2 ** trans.ARSIZE);
                    endcase
                end
            end
        finish_item(trans);
    endtask

    task body();
        MODE mode;
        rst();
        WADDR = 0;
        RADDR = 0;
        mode = AW;
        while (WADDR < MEM_SIZE) run(mode);
        mode = AR;
        while (RADDR < MEM_SIZE) run(mode);
        mode = AWAR;
        repeat (50000) run(mode);
    endtask
endclass