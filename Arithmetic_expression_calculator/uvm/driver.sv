class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)

    transaction trans;
    virtual duv_if vif;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "failed build_phase")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                vif.data_queue = trans.data_queue;
                vif.rst <= trans.rst;
                foreach (trans.data_queue[i]) begin
                    if (i == 0) begin
                        vif.ready <= 1'b1;
                    end else begin
                        vif.ready <= 1'b0;
                    end
                    vif.ascii_in <= trans.data_queue[i];
                    if (trans.data_queue[i] == 8'd61) begin
                        wait (vif.finish == 1'b1);
                    end else begin
                        @(posedge vif.clk);
                    end
                end
                vif.startWork <= trans.startWork;
                @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass