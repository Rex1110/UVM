class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)

    transaction trans;
    virtual duv_if vif;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (~uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("drv", "vif failed")
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            seq_item_port.get_next_item(trans);
                if (trans.reset == 1'b0) begin
                    if (trans.in_en == 1'b1) begin
                        vif.reset <= trans.reset;
                        vif.in_en <= trans.in_en;
                        vif.width <= trans.width;
                        vif.height <= trans.height;
                        vif.bayer_img = trans.bayer_img;
                    end else begin
                        vif.reset <= trans.reset;
                        vif.in_en <= trans.in_en;
                        wait(vif.done);
                    end
                    @(posedge vif.clk);

                end else begin
                    vif.reset <= trans.reset;
                    vif.in_en <= trans.in_en;
                    @(posedge vif.clk);
                end
            seq_item_port.item_done();
        end
    endtask
endclass