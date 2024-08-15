`include "./uvm_macros.svh"
import uvm_pkg::*;


module rails_tb();

    duv_if vif();

    rails duv(
        .clk    (vif.clk    ),
        .reset  (vif.reset  ),
        .data   (vif.data   ),
        .valid  (vif.valid  ),
        .result (vif.result )
    );

    initial begin
        vif.clk = 1'b1;
        forever #20 vif.clk = ~vif.clk;
    end

    initial begin
        uvm_config_db #(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end

    `ifdef VCD
        initial begin
            $dumpfile("wave.vcd");
            $dumpvars(0, rails_tb);
        end
    `endif

endmodule