class environment extends uvm_env;
    `uvm_component_utils(environment)

    agent i_agent, o_agent;
    scoreboard scb;
    referenceModel model;
    uvm_tlm_fifo #(transaction) fifo;

    function new(string name = "environment", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        i_agent = agent::type_id::create("i_agent", this);
        o_agent = agent::type_id::create("o_agent", this);
        model   = referenceModel::type_id::create("model", this);
        scb     = scoreboard::type_id::create("scb", this);
        fifo    = new("fifo", this, 2);

        i_agent.is_active = UVM_ACTIVE;
        o_agent.is_active = UVM_PASSIVE;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        o_agent.mon.tlm_put.connect(fifo.put_export);
        model.tlm_put.connect(fifo.put_export);
        scb.tlm_get.connect(fifo.get_export);
    endfunction
endclass