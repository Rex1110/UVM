class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(transaction, scoreboard) imp;

    logic [7:0] golden_channel [$];
    
    
    int file;
    int pass = 0, fail = 0;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    virtual function void write(transaction trans);

        int channel_r_fail = 0;
        int channel_g_fail = 0;
        int channel_b_fail = 0;

        int height = trans.height;
        int width = trans.width;

        $display("Image size = %0d x %0d", width, height);
        
        $system("python3 golden.py");

        $readmemh("./golden_channel_r.dat", golden_channel);
        for (int i = 0; i < width*height; i++)
            if (~((i / width == 0) || (i / width == height - 1) || (i % width == 0) || (i % width == width - 1)))
                if (trans.channel_r[i] != golden_channel[i])
                    channel_r_fail++;

        if (channel_r_fail == 0) $write("R channel passed "); else $write("R channel failed ");
        $display("%0d / %0d", (width-2)*(height-2)-channel_r_fail,(width-2)*(height-2));

        golden_channel = {};
        $readmemh("./golden_channel_g.dat", golden_channel);
        for (int i = 0; i < width*height; i++)
            if (~((i / width == 0) || (i / width == height - 1) || (i % width == 0) || (i % width == width - 1)))
                if (trans.channel_g[i] != golden_channel[i])
                    channel_g_fail++;

        if (channel_g_fail == 0) $write("G channel passed "); else $write("G channel failed ");
        $display("%0d / %0d", (width-2)*(height-2)-channel_g_fail,(width-2)*(height-2));

        golden_channel = {};
        $readmemh("./golden_channel_b.dat", golden_channel);
        for (int i = 0; i < width*height; i++)
            if (~((i / width == 0) || (i / width == height - 1) || (i % width == 0) || (i % width == width - 1)))
                if (trans.channel_b[i] != golden_channel[i])
                    channel_b_fail++;

        if (channel_b_fail == 0) $write("B channel passed "); else $write("B channel failed ");
        $display("%0d / %0d", (width-2)*(height-2)-channel_b_fail,(width-2)*(height-2));


        if (channel_r_fail+channel_g_fail+channel_b_fail != 0) begin

            file = $fopen($sformatf("./image/img_%02d_rgb.dat", pass+fail+1), "w");
            foreach (trans.bayer_img[i]) $fwrite(file, "%0h\n", trans.bayer_img[i]);
            $fclose(file);

            file = $fopen($sformatf("./image/img_%02d_size.dat", pass+fail+1), "w");
            $fwrite(file, "%0d\n%0d", height, width);
            $fclose(file);
            $system($sformatf("python3 golden.py save_image img_%02d.png", pass+fail+1));
            fail++;
        end else begin
            pass++;
        end

    endfunction
endclass