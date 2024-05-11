
`include "./duv/demosaic.sv"

module direct_tb();

    int line;
    int file;
    int WIDTH, HEIGHT;
    string filename = `IMAGE;

    initial begin
        for (int i = 0; i < filename.len(); i = i + 1) begin
            if (filename.getc(i) == ".") begin
                filename =  filename.substr(0, i-1);
                break;
            end
        end
    end

    initial begin
        file = $fopen($sformatf("./image/%s_size.dat", filename), "r");
        if (file == 0) begin
            $display("Error opening file.");
            $finish; 
        end
        
        if ($fgets(line, file) == 0) begin
            $display("Failed to get golden");
        end else begin
            $sscanf(line, "%d", HEIGHT);
        end

        if ($fgets(line, file) == 0) begin
            $display("Failed to get golden");
        end else begin
            $sscanf(line, "%d", WIDTH);
        end

        $fclose(file);
    end

    logic done;
    logic [ 7:0] data_in;
    logic wr_r, wr_g, wr_b;
    logic [18:0] addr_r, addr_g, addr_b, img_addr;
    logic [ 7:0] wdata_r, wdata_g, wdata_b;
    logic [ 7:0] rdata_r, rdata_g, rdata_b;

    logic [10:0] width, height;

    logic [ 7:0] bayer_ff     [$];
    logic [ 7:0] channel_r_ff [0:1024*512-1];
    logic [ 7:0] channel_g_ff [0:1024*512-1];
    logic [ 7:0] channel_b_ff [0:1024*512-1];


    logic clk, reset, in_en;
    initial begin
        $readmemh($sformatf("./image/%0s_bayer.dat", filename), bayer_ff);
    end

    initial begin
        clk = 1'b0;
        forever #20 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        repeat (4) @(posedge clk);
        reset = 1'b0;
        height = HEIGHT;
        width = WIDTH;
        in_en = 1'b1;
    end

    demosaic demosaic_(
        .clk        (clk    ),
        .reset      (reset  ),

        .in_en      (in_en  ),
        .data_in    (data_in),
        .img_addr   (img_addr),

        .height     (height ),
        .width      (width  ),
        
        .wr_r       (wr_r   ),
        .addr_r     (addr_r ),
        .wdata_r    (wdata_r),
        .rdata_r    (rdata_r),

        .wr_g       (wr_g   ),
        .addr_g     (addr_g ),
        .wdata_g    (wdata_g),
        .rdata_g    (rdata_g),

        .wr_b       (wr_b   ),
        .addr_b     (addr_b ),
        .wdata_b    (wdata_b),
        .rdata_b    (rdata_b),

        .done       (done   )
    );


    assign data_in = reset ? 'd0 : bayer_ff[img_addr];    
    assign rdata_r = reset ? 'd0 : channel_r_ff[addr_r];
    assign rdata_g = reset ? 'd0 : channel_g_ff[addr_g];
    assign rdata_b = reset ? 'd0 : channel_b_ff[addr_b];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 1024*512; i = i + 1) begin
                channel_r_ff[i] <= 'd0;
            end
        end else if (wr_r) begin
            channel_r_ff[addr_r] <= wdata_r;
        end else begin

        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 1024*512; i = i + 1) begin
                channel_g_ff[i] <= 'd0;
            end
        end else if (wr_g) begin
            channel_g_ff[addr_g] <= wdata_g;
        end else begin

        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 1024*512; i = i + 1) begin
                channel_b_ff[i] <= 'd0;
            end
        end else if (wr_b) begin
            channel_b_ff[addr_b] <= wdata_b;
        end else begin

        end
    end


    int channel_r_fail, channel_g_fail, channel_b_fail;
    logic [7:0] golden [$];
    
    initial begin
        channel_r_fail = 0;
        channel_g_fail = 0;
        channel_b_fail = 0;
        wait (done);
        $readmemh("./golden_channel_r.dat", golden);
        for (int i = 0; i < $size(bayer_ff); i++) begin
            if (~((i / WIDTH == 0) || (i / WIDTH == HEIGHT - 1) ||(i % WIDTH == 0) || (i % WIDTH == WIDTH - 1))) begin
                if (channel_r_ff[i] != golden[i]) begin
                    if (channel_r_fail == 0) 
                        file = $fopen($sformatf("./image/%s_idx.dat", filename), "w");
                    $fwrite(file, "=================================\n");
                    $fwrite(file, "R channel, idx = %0d\n", i);
                    $fwrite(file, "Golden = %0d\n", golden[i]);
                    $fwrite(file, "Your   = %0d\n", channel_r_ff[i]);
                    channel_r_fail++;
                end 
            end
        end 
            
        golden = {};
        $readmemh("./golden_channel_g.dat", golden);
        for (int i = 0; i < $size(bayer_ff); i++) begin
            if (~((i / WIDTH == 0) || (i / WIDTH == HEIGHT - 1) ||(i % WIDTH == 0) || (i % WIDTH == WIDTH - 1))) begin
                if (channel_g_ff[i] != golden[i]) begin
                    if ((channel_g_fail+channel_r_fail) == 0) 
                        file = $fopen($sformatf("./image/%s_idx.dat", filename), "w");
                    $fwrite(file, "=================================\n");
                    $fwrite(file, "G channel, idx = %0d\n", i);
                    $fwrite(file, "Golden = %0d\n", golden[i]);
                    $fwrite(file, "Your   = %0d\n", channel_g_ff[i]);
                    channel_g_fail++;
                end 
            end
        end 

        golden = {};
        $readmemh("./golden_channel_b.dat", golden);
        for (int i = 0; i < $size(bayer_ff); i++) begin
            if (~((i / WIDTH == 0) || (i / WIDTH == HEIGHT - 1) ||(i % WIDTH == 0) || (i % WIDTH == WIDTH - 1))) begin
                if (channel_b_ff[i] != golden[i]) begin
                    if ((channel_b_fail+channel_g_fail+channel_r_fail) == 0) 
                        file = $fopen($sformatf("./image/%s_idx.dat", filename), "w");
                    $fwrite(file, "=================================\n");
                    $fwrite(file, "B channel, idx = %0d\n", i);
                    $fwrite(file, "Golden = %0d\n", golden[i]);
                    $fwrite(file, "Your   = %0d\n", channel_b_ff[i]);
                    channel_b_fail++;
                end 
            end
        end 

        if ((channel_b_fail+channel_g_fail+channel_r_fail) != 0) begin
            $display("");
            $display("");
            $display("***********************************************************");
            $display("******************** Simulation failed ********************");
            $display("***********************************************************\n");
            $display("Examine the file %s_idx.dat to locate the erroneous index.", filename);
            $display("R channel failed %0d / %0d", (HEIGHT-2)*(WIDTH-2)-channel_r_fail, (HEIGHT-2)*(WIDTH-2));
            $display("G channel failed %0d / %0d", (HEIGHT-2)*(WIDTH-2)-channel_g_fail, (HEIGHT-2)*(WIDTH-2));
            $display("B channel failed %0d / %0d\n", (HEIGHT-2)*(WIDTH-2)-channel_b_fail, (HEIGHT-2)*(WIDTH-2));
            $display("***********************************************************\n\n");
            $fclose(file);
        end else begin
            $display("");
            $display("");
            $display("***********************************************************");
            $display("******************** Simulation passed ********************");
            $display("***********************************************************\n");
            $display("R channel passed %0d / %0d", (HEIGHT-2)*(WIDTH-2)-channel_r_fail, (HEIGHT-2)*(WIDTH-2));
            $display("G channel passed %0d / %0d", (HEIGHT-2)*(WIDTH-2)-channel_g_fail, (HEIGHT-2)*(WIDTH-2));
            $display("B channel passed %0d / %0d\n", (HEIGHT-2)*(WIDTH-2)-channel_b_fail, (HEIGHT-2)*(WIDTH-2));
            $display("***********************************************************\n\n");
        end
        $finish;
    end

    
    `ifdef FSDB
        initial begin
            $fsdbDumpfile("wave.fsdb");
            $fsdbDumpvars(0, "+mda");
        end
    `endif
endmodule