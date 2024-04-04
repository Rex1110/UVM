class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)

    virtual duv_if vif;
    transaction trans;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif)) 
            `uvm_error("drv", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                vif.data_queue = trans.data_queue; // 用於傳送整筆至 monitor 所以使用 blocking
                vif.reset <= trans.reset;
                for (int i = 0; i < trans.data_queue.size(); i++) begin
                    vif.data  <= trans.data_queue[i];
                    @(posedge vif.clk);
                    if (vif.valid) 
                        break;
                end
                if (trans.data_queue.size() == 0)
                    @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
    
endclass