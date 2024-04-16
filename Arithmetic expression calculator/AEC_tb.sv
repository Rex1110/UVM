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
        .finish     (vif.finish  )
    );
    
    initial begin
        vif.clk = 1'b1;
        forever #20 vif.clk = ~vif.clk;
    end

    initial begin
        uvm_config_db#(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end

    `ifdef FSDB
        initial begin
            $fsdbDumpfile("wave.fsdb");
            $fsdbDumpvars();
        end
    `endif
endmodule