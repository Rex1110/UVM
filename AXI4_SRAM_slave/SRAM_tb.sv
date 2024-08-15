`include "uvm_macros.svh"
import uvm_pkg::*;

module SRAM_tb;

    duv_if vif();

    SRAM_wrapper i_SRAM_wrapper(
        .ACLK       (vif.ACLK   ),
        .ARESETn    (vif.ARESETn),

        .AWID       (vif.AWID   ),
        .AWADDR     (vif.AWADDR ),
        .AWLEN      (vif.AWLEN  ),
        .AWSIZE     (vif.AWSIZE ),
        .AWBURST    (vif.AWBURST),
        .AWVALID    (vif.AWVALID),
        .AWREADY    (vif.AWREADY),

        .WDATA      (vif.WDATA  ),
        .WSTRB      (vif.WSTRB  ),
        .WLAST      (vif.WLAST  ),
        .WVALID     (vif.WVALID ),
        .WREADY     (vif.WREADY ),

        .BID        (vif.BID    ),
        .BRESP      (vif.BRESP  ),
        .BVALID     (vif.BVALID ),
        .BREADY     (vif.BREADY ),

        .ARID       (vif.ARID   ),
        .ARADDR     (vif.ARADDR ),
        .ARLEN      (vif.ARLEN  ),
        .ARSIZE     (vif.ARSIZE ),
        .ARBURST    (vif.ARBURST),
        .ARVALID    (vif.ARVALID),
        .ARREADY    (vif.ARREADY),

        .RID        (vif.RID    ),
        .RDATA      (vif.RDATA  ),
        .RRESP      (vif.RRESP  ),
        .RLAST      (vif.RLAST  ),
        .RVALID     (vif.RVALID ),
        .RREADY     (vif.RREADY )
    );

    initial begin
        vif.ACLK = 1'b1;
        forever #100 vif.ACLK = ~vif.ACLK;
    end

    initial begin
        uvm_config_db #(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
    
    `ifdef VCD
        initial begin
            $dumpfile("wave.vcd");
            $dumpvars(0, SRAM_tb);
        end
    `endif

endmodule