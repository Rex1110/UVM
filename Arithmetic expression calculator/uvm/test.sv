class test extends uvm_test;
    `uvm_component_utils(test)

    seq seq1;
    environment env;

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq1 = seq::type_id::create("seq1");
        env  = environment::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            seq1.start(env.i_agent.seqr);
            $display("=====================================================================");
            $display("");
            $display("");
            $display("=================================================");
            $display("==================== SUMMARY ====================");
            $display("=================================================");
            $display("Total test cases = %0d", env.scb.pass+env.scb.fail);
            $display("All passed       = %0d", env.scb.pass);
            $display("All failed       = %0d", env.scb.fail);
            $display("");
            $display("TREE_NUMBER = %0d ~ %0d", `TREE_NUM_MIN, `TREE_NUM_MAX);
            $display("TREE_DEPTH  = %0d ~ %0d", `TREE_DEPTH_MIN, `TREE_DEPTH_MAX);

            $display("=================================================");
            $display("");
            $display("");
        phase.drop_objection(this);
    endtask

endclass