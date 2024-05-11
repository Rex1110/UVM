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
                trans.bayer_img = vif.bayer_img;
                trans.channel_r = vif.channel_r;
                trans.channel_g = vif.channel_g;
                trans.channel_b = vif.channel_b;

                file_size = $fopen("./size.dat", "w");
                $fwrite(file_size, "%0d\n%0d", vif.height, vif.width);
                $fclose(file_size);

                $writememh("./bayer.dat", vif.bayer_img);

                vif.bayer_img = {};
                vif.channel_r = {};
                vif.channel_g = {};
                vif.channel_b = {};
                
                ap.write(trans);
            end
            @(posedge vif.clk);
        end
    endtask
endclass