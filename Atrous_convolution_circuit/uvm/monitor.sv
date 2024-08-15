class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    int file;
    virtual duv_if vif;
    transaction trans;

    uvm_analysis_port  #(transaction) ap;

    function new(string name = "monitor", uvm_component parent = null); 
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);    
        super.build_phase(phase);
        ap = new("ap", this);

        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            @(posedge vif.clk);
            if (!vif.busy && !vif.ready && !vif.reset && vif.startWork) begin

                trans.image_mem = vif.image_mem;
                trans.layer1_mem = vif.layer1_mem;
                trans.layer2_mem = vif.layer2_mem;

                file = $fopen("./image_mem.dat", "w");
                foreach (trans.image_mem[i]) begin
                    $fwrite(file, "%013b\n", trans.image_mem[i]);
                end
                $fclose(file);
                
                ap.write(trans);
            end
        end
    endtask

endclass