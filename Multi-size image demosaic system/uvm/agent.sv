class agent extends uvm_agent;
    `uvm_component_utils(agent)

    driver drv;
    monitor mon;
    uvm_sequencer #(transaction) seqr;

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv = driver::type_id::create("drv", this);
            seqr= uvm_sequencer#(transaction)::type_id::create("seqr", this);
        end else begin
            mon = monitor::type_id::create("mon", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (this.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass