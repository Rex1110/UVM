class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    driver drv;
    uvm_sequencer#(transaction) seqr;
    monitor mon;

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
            drv  = driver::type_id::create("drv", this);
        end else begin
            mon  = monitor::type_id::create("mon", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass