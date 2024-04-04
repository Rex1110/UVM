class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    int file;
    virtual duv_if vif;
    transaction trans;
    uvm_analysis_port #(transaction) ap;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        
        forever begin
            @(posedge vif.clk);            
            if (vif.valid) begin
                
                trans.result = vif.result;
                trans.data_queue = vif.data_queue;

                // 將 data_queue 寫入外部 file
                file = $fopen("./testcase.txt", "w");
                foreach (trans.data_queue[i]) begin
                    if (i == 0) begin
                        $display("Number of coming trains = %-2d", trans.data_queue[i]);
                        $write("Departure order = ");
                    end else begin
                        $fwrite(file, "%-0d", trans.data_queue[i]);
                        if (i == (trans.data_queue.size()-1)) begin
                            $display("%0d", trans.data_queue[i]);
                        end else begin
                            $write("%0d, ", trans.data_queue[i]);
                        end
                    end
                end
                $fclose(file);
                // 送至 monitor
                ap.write(trans);

            end
        end

    endtask
endclass
