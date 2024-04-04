class test extends uvm_test;
    `uvm_component_utils(test)

    environment env;
    seq seq1;
    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env", this);
        seq1= seq::type_id::create("seq1");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            seq1.start(env.i_agent.seqr);
            $display("=================================================");
            $display("");
            $display("");
            $display("=================================================");
            $display("==================== SUMMARY ====================");
            $display("=================================================");
            $display("Total test cases = %0d", env.scb.fail+env.scb.pass);
            $display("All  passed      = %0d", env.scb.pass);
            $display("All  failed      = %0d", env.scb.fail);
            $display("=================================================");
            $display("");
            $display("");
        phase.drop_objection(this);
    endtask
endclass