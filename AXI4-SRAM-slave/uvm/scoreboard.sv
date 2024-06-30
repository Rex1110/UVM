class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(transaction, scoreboard) imp;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    int err;
    int pass, fail;

    function void write(transaction trans);
        err = 0;
        $display(">>>>>>>>>>>>>>>>>>>>>>>>>>>>> RESULT <<<<<<<<<<<<<<<<<<<<<<<<<<<<\n");
        $display("        Reference model                    SRAM\n");

        for (int i = 0; i < 16; i++) begin
            $write("refModel[%04d] = %02h_%2h_%2h_%2h\t", trans.arAddrReg + 4*i, trans.refModel[4*i+3], trans.refModel[4*i+2], trans.refModel[4*i+1], trans.refModel[4*i]);
            if (trans.duv.size() >= 4*(i+1)) begin
                $write("SRAM[%04d] = %02h_%2h_%2h_%2h", trans.arAddrReg + 4*i, trans.duv[4*i+3], trans.duv[4*i+2], trans.duv[4*i+1], trans.duv[4*i]);
                if ((trans.refModel[4*i+3] != trans.duv[4*i+3]) || (trans.refModel[4*i+2] != trans.duv[4*i+2]) || (trans.refModel[4*i+1] != trans.duv[4*i+1]) || (trans.refModel[4*i] != trans.duv[4*i])) begin
                    err++;
                    $display("    FAIL");
                end else begin
                    $display("    PASS");
                end
            end else if (trans.duv.size() >= (4*(i+1) - 1)) begin
                $write("SRAM[%04d] =    %2h_%2h_%2h", trans.arAddrReg + 4*i, trans.duv[4*i+2], trans.duv[4*i+1], trans.duv[4*i]);
                if ((trans.refModel[4*i+2] != trans.duv[4*i+2]) || (trans.refModel[4*i+1] != trans.duv[4*i+1]) || (trans.refModel[4*i] != trans.duv[4*i])) begin
                    err++;
                    $display("    FAIL");
                end else begin
                    $display("    PASS");
                end
            end else if (trans.duv.size() >= (4*(i+1) - 2)) begin
                $write("SRAM[%04d] =       %2h_%2h", trans.arAddrReg + 4*i, trans.duv[4*i+1], trans.duv[4*i]);
                if ((trans.refModel[4*i+1] != trans.duv[4*i+1]) || (trans.refModel[4*i] != trans.duv[4*i])) begin
                    err++;
                    $display("    FAIL");
                end else begin
                    $display("    PASS");
                end
            end else if (trans.duv.size() >= (4*(i+1) - 3)) begin
                $write("SRAM[%04d] =          %2h", trans.arAddrReg + 4*i, trans.duv[4*i]);
                if (trans.refModel[4*i] != trans.duv[4*i]) begin
                    err++;
                    $display("    FAIL");
                end else begin
                    $display("    PASS");
                end
            end else begin
                $display("");
            end
        end
        $display("\n******************************************************************\n\n");
        trans.duv = {};
        if (err == 0) begin
            pass++;
        end else begin
            fail++;
        end
    endfunction
endclass