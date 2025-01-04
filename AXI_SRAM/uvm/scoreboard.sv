class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    transaction trans1, trans2;
    virtual duv_if vif;
    int pass = 0;
    int fail = 0;
    uvm_get_port #(transaction) tlm_get;
    
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tlm_get = new("tlm_get", this);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "failed build_phase")
    endfunction

    task run_phase(uvm_phase phase);
        trans1 = transaction::type_id::create("trans1");
        trans2 = transaction::type_id::create("trans2");
        forever begin
            if (vif.RVALID && vif.RREADY) begin
                tlm_get.get(trans1);
                tlm_get.get(trans2);
                if (trans1.RDATA === trans2.RDATA) begin
                    $display("DUT = %8h, Expect = %8h", trans1.RDATA, trans2.RDATA);
                    $display("PASS");
                    pass++;
                end else begin
                    $display("DUT = %8h, Expect = %8h", trans1.RDATA, trans2.RDATA);
                    $display("FAIL");
                    $finish();
                    fail++;
                end
            end
            @(negedge vif.ACLK);
        end
    endtask

endclass