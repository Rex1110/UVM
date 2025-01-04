class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    transaction trans;
    uvm_put_port#(transaction) tlm_put;
    virtual duv_if vif;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tlm_put = new("tlm_put", this);
        if (!uvm_config_db#(virtual duv_if)::get(this, "", "vif", vif))
            `uvm_error("mon", "failed build_phase")
    endfunction

    task run_phase(uvm_phase phase);
        trans = transaction::type_id::create("trans");
        forever begin
            if (vif.RVALID && vif.RREADY) begin
                trans.RDATA = vif.RDATA;
                if (!tlm_put.try_put(trans)) begin
                    $display("Monitor put tlm failed");
                end
            end
            @(posedge vif.ACLK);
        end
    endtask

endclass