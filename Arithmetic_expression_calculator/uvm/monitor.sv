class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    // file
    int file;
    string s = "";
    virtual duv_if vif;
    transaction trans;
    uvm_analysis_port #(transaction) ap;
    int i;
    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "failed build_phase")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        i = 0;
        forever begin
            if (!vif.rst && vif.finish && vif.startWork) begin
                i++;
                file = $fopen("./testcase.dat", "w");
                for (int i = 0; i < vif.data_queue.size()-1; i++) begin
                    $fwrite(file, "%0d ", vif.data_queue[i]);
                end
                $fclose(file);
                trans.result     = vif.result;
                trans.valid      = vif.valid;
                trans.data_queue = vif.data_queue;
                ap.write(trans);
            end
            @(posedge vif.clk);
        end
    endtask
endclass