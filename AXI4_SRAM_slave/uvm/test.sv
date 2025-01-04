class test extends uvm_test;
    `uvm_component_utils(test)

    environment env;
    seq#(`MEM_SIZE) seq1;

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq1 = seq#(`MEM_SIZE)::type_id::create("seq1");
        env  = environment::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq1.start(env.i_agent.seqr);
        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("");
        $display("=================================================");
        $display("==================== SUMMARY ====================");
        $display("=================================================");
        $display("Total test cases = %0d", env.scb.pass+env.scb.fail);
        $display("All passed       = %0d", env.scb.pass);
        $display("All failed       = %0d", env.scb.fail);
        $display("");
    endfunction
    
endclass

