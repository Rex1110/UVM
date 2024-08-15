class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    int file_size;
    virtual duv_if vif;
    uvm_analysis_port #(transaction) ap;
    transaction trans;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (~uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans)");

        forever begin
            if (vif.done) begin
                
                trans.width = vif.width;
                trans.height= vif.height;
                for (int i = 0; i < trans.width*trans.height; i++) begin
                    trans.bayer_img[i] = vif.bayer_img[i];
                    trans.channel_r[i] = vif.channel_r[i];
                    trans.channel_g[i] = vif.channel_g[i];
                    trans.channel_b[i] = vif.channel_b[i];
                end

                file_size = $fopen("./size.dat", "w");
                $fwrite(file_size, "%0d\n%0d", vif.height, vif.width);
                $fclose(file_size);

                $writememh("./bayer.dat", vif.bayer_img);
                
                ap.write(trans);
            end
            @(posedge vif.clk);
        end
    endtask
endclass