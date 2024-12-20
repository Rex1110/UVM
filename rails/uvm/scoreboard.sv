class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    int ans;
    uvm_analysis_imp #(transaction, scoreboard) imp;
    int pass = 0;
    int fail = 0;
    
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function automatic logic gold(ref logic [3:0] nums[$]);
        logic [3:0] stack[$];
        logic [3:0] ans[$];
        void'(nums.pop_front());
        while (nums.size() != 0) begin
            if (stack.size() == 0) begin
                stack.push_back(nums.pop_back());
            end else begin
                if (nums[nums.size() - 1] < stack[stack.size() - 1]) begin
                    ans.push_back(stack.pop_back());
                end else begin
                    stack.push_back(nums.pop_back());
                end
            end
        end

        while (stack.size() != 0) begin
            ans.push_back(stack.pop_back());
        end
        for (int i = 0, logic [3:0] j = ans.size(); i < ans.size(); i++, j--) begin
            if (ans[i] !== j) return 0;
        end
        return 1;
    endfunction

    virtual function void write(transaction trans);

        ans = gold(trans.data_queue);

        $display("Answer = %0d", ans);
        $display("Result = %0d", trans.result);

        if (ans === trans.result) begin
            $display("PASSED");
            pass++;
        end else begin
            $display("FAILED");
            fail++;
        end

    endfunction
endclass