class environment extends uvm_env;
    `uvm_component_utils(environment)

    scoreboard scb;
    agent i_agent, o_agent;

    function new(string name = "environment", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb = scoreboard::type_id::create("scb", this);
        i_agent = agent::type_id::create("i_agent", this);
        o_agent = agent::type_id::create("o_agent", this);

        i_agent.is_active = UVM_ACTIVE;
        o_agent.is_active = UVM_PASSIVE;

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        o_agent.mon.ap.connect(scb.imp);
    endfunction
endclass