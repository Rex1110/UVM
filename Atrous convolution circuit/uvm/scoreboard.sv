class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    logic [12:0] layer1_golden [0:4095];
    logic [12:0] layer2_golden [0:1023];
    int image_count = 0;
    int err_layer1, err_layer2;
    int file;
    int pass = 0;
    int fail = 0;
    uvm_analysis_imp #(transaction, scoreboard) imp;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    virtual function void write(transaction trans);
        $system("python3 golden.py");

        $readmemb("./layer1_golden.dat", layer1_golden);
        $readmemb("./layer2_golden.dat", layer2_golden);
        err_layer1 = 0;
        err_layer2 = 0;
        image_count++;

        $display("--------- test image %0d ---------", image_count);

        foreach (layer1_golden[i]) begin
            if (err_layer1 == 0) begin
                if (layer1_golden[i] != trans.layer1_mem[i]) begin
                    file = $fopen($sformatf("./failed_image/image_addr_%02d.dat", image_count), "w");

                    $fwrite(file, "------ Layer1 address %0d ------\n", i);
                    $fwrite(file, "Your   answer is %013b\n", trans.layer1_mem[i]);
                    $fwrite(file, "Golden answer is %013b\n\n", layer1_golden[i]);

                    err_layer1++;
                end
            end else begin
                if (layer1_golden[i] != trans.layer1_mem[i]) begin
                    $fwrite(file, "------ Layer1 address %0d ------\n", i);
                    $fwrite(file, "Your   answer is %013b\n", trans.layer1_mem[i]);
                    $fwrite(file, "Golden answer is %013b\n\n", layer1_golden[i]);

                    err_layer1++;
                end
            end
        end

        if (err_layer1 == 0) $display("Layer 1 pass");
        else                 $display("Layer 1 fail");

        foreach (layer2_golden[i]) begin
            if (err_layer2 == 0) begin
                if (layer2_golden[i] != trans.layer2_mem[i]) begin
                    if (err_layer1 == 0)  file = $fopen($sformatf("./failed_image/image_addr_%02d.dat", image_count), "w");
                    $fwrite(file, "------ Layer2 address %0d ------\n", i);
                    $fwrite(file, "Your   answer is %013b\n", trans.layer2_mem[i]);
                    $fwrite(file, "Golden answer is %013b\n\n", layer2_golden[i]);

                    err_layer2++;
                end
            end else begin
                if (layer2_golden[i] != trans.layer2_mem[i]) begin
                    $fwrite(file, "------ Layer2 address %0d ------\n", i);
                    $fwrite(file, "Your   answer is %013b\n", trans.layer2_mem[i]);
                    $fwrite(file, "Golden answer is %013b\n\n", layer2_golden[i]);

                    err_layer2++;
                end
            end
        end

        if (err_layer2 == 0) $display("Layer 2 pass");
        else                 $display("Layer 2 fail");

        if (err_layer1 != 0 || err_layer2 != 0) begin
            fail++;
            $fclose(file);
            file = $fopen($sformatf("./failed_image/image_%02d.dat", image_count), "w");

            foreach (trans.image_mem[i]) begin
                $fwrite(file, "%013b\n", trans.image_mem[i]);
            end
            $fclose(file);
        end else begin
            pass++;
        end
    endfunction
endclass
