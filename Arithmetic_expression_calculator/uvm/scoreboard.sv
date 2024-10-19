class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    int temp = 1;
    logic [31:0] golden;
    logic valid;
    int file;
    string line;
    uvm_analysis_imp #(transaction, scoreboard) imp;

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
        $display("=====================================================================");
        $display("                          The %0d test case", temp++);

        $system("python3 golden.py");
        file = $fopen("./golden.dat", "r");
        $fscanf(file, "%d\n", valid);
        if (valid == 1) begin
            $fscanf(file, "%d\n", golden);
        end

        $fclose(file);
        
        if (valid == 1) begin
            if (valid != trans.valid || golden != trans.result) begin
                fail++;
                $display("Correct answer is %0d", $signed(golden));
                $display("Your    answer is %0d", $signed(trans.result));
                $display("FAILED");
                file = $fopen("./data.dat", "a");
                $fwrite(file, "Testcase %0d\n", temp-1);
                foreach (trans.data_queue[i]) begin
                    $fwrite(file, "%0d ", trans.data_queue[i]);
                end
                $fwrite(file, "\n");
                $fclose(file);
            end else begin
                pass++;
                $display("Correct answer is %0d", $signed(golden));
                $display("Your    answer is %0d", $signed(trans.result));
                $display("PASSED");
            end
        end else begin
            if (trans.valid) begin
                fail++;
                $display("Correct answer is does not exist");
                $display("Your    answer is exist");
                $display("FAILED");
                file = $fopen("./data.dat", "a");
                $fwrite(file, "Testcase %0d\n", temp-1);
                foreach (trans.data_queue[i]) begin
                    $fwrite(file, "%0d ", trans.data_queue[i]);
                end
                $fwrite(file, "\n");
                $fclose(file);

            end else begin
                pass++;
                $display("Correct answer is does not exist");
                $display("Your    answer is does not exist");
                $display("PASSED");
            end
        end
    endfunction
endclass
