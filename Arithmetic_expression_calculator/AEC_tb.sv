`include "uvm_macros.svh"
import uvm_pkg::*;


module AEC_tb();

    duv_if vif();

    AEC AEC1(
        .clk        (vif.clk     ),
        .rst        (vif.rst     ),
        .ready      (vif.ready   ),
        .ascii_in   (vif.ascii_in),

        .result     (vif.result  ),
        .finish     (vif.finish  ),
        .valid      (vif.valid   )
    );
    
    initial begin
        vif.clk = 1'b1;
        forever #1 vif.clk = ~vif.clk;
    end

    initial begin
        uvm_config_db#(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end

    `ifdef VCD
        initial begin
            $dumpfile("wave.vcd.fsdb");
            $dumpvars(0, AEC_tb);
        end
    `endif
endmodule