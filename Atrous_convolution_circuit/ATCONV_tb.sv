`include "uvm_macros.svh"
import uvm_pkg::*;


module ATCONV_tb();

    top TOP(
        .clk        (vif.clk        ),
        .reset      (vif.reset      ),
        .busy       (vif.busy       ),
        .ready      (vif.ready      ),
        .image      (vif.image_mem  ),
        .layer1_mem (vif.layer1_mem ),
        .layer2_mem (vif.layer2_mem )
    );
   

    duv_if vif();

    
    initial begin
        vif.clk = 1'b0;
        forever #20 vif.clk = ~vif.clk;
    end


    initial begin
        uvm_config_db #(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end

    `ifdef VCD
        initial begin
            $dumpfile("wave.vcd");
            $dumpvars(0, ATCONV_tb);
        end
    `endif    
endmodule