class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    int file, ans;
    uvm_analysis_imp #(transaction, scoreboard) imp;
    string line;
    int pass = 0;
    int fail = 0;
    
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    virtual function void write(transaction trans);

        // Golden
        $system("./a.out");

        file = $fopen("answer.txt", "r");

        if ($fgets(line, file) == 0) begin
            $display("Failed to get golden");
        end else begin
            $sscanf(line, "%d", ans);
        end

        $display("Answer = %0d", ans);
        $display("Result = %0d", trans.result);

        if (ans == trans.result) begin
            $display("PASSED");
            pass++;
        end else begin
            $display("FAILED");
            fail++;
        end
        $fclose(file);

    endfunction
endclass