class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    transaction trans;
    virtual duv_if vif;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                foreach (trans.image_mem[i]) begin
                    vif.image_mem[i] <= trans.image_mem[i];
                end
                vif.startWork <= trans.startWork;
                vif.reset <= trans.reset;
                vif.ready <= trans.ready;
                if (vif.busy) begin
                    wait (!vif.busy);
                end
                if (trans.ready) begin
                    wait (vif.busy);
                end
                @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass