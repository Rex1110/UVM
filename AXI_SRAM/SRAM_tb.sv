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
        vif.ACLK = 1'b0;
        forever #100 vif.ACLK = ~vif.ACLK;
    end

    initial begin
        uvm_config_db #(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
    
    ///////////////////////////////////////////////
    // AW
    ///////////////////////////////////////////////

    generate
        for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: FIXED_ALIGNED_AWSIZE
            for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.AWVALID && vif.AWREADY
                        |->
                        (vif.AWBURST == `FIXED) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar AWSIZE = 1; AWSIZE <= 2; AWSIZE++) begin: FIXED_UNALIGNED_AWSIZE
            for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.AWVALID && vif.AWREADY
                        |->
                        (vif.AWBURST == `FIXED) && (vif.AWADDR % (2 ** AWSIZE) != 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: INCR_ALIGNED_AWSIZE
            for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.AWVALID && vif.AWREADY
                        |->
                        (vif.AWBURST == `INCR) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar AWSIZE = 1; AWSIZE <= 2; AWSIZE++) begin: INCR_UNALIGNED_AWSIZE
            for (genvar AWLEN = 0; AWLEN <= 15; AWLEN++) begin: _AWLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.AWVALID && vif.AWREADY
                        |->
                        (vif.AWBURST == `INCR) && (vif.AWADDR % (2 ** AWSIZE) != 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar AWSIZE = 0; AWSIZE <= 2; AWSIZE++) begin: WRAP_ALIGNED_AWSIZE
            for (genvar AWLEN = 1; AWLEN <= 15; AWLEN = (AWLEN << 1) + 1) begin: _AWLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.AWVALID && vif.AWREADY
                        |->
                        (vif.AWBURST == `INCR) && (vif.AWADDR % (2 ** AWSIZE) == 0) && (vif.AWSIZE == AWSIZE) && (vif.AWLEN == AWLEN)
                    )
                );
            end
        end
    endgenerate

    ///////////////////////////////////////////////
    // AR
    ///////////////////////////////////////////////

    generate
        for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: FIXED_ALIGNED_ARSIZE
            for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.ARVALID && vif.ARREADY
                        |->
                        (vif.ARBURST == `FIXED) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar ARSIZE = 1; ARSIZE <= 2; ARSIZE++) begin: FIXED_UNALIGNED_ARSIZE
            for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.ARVALID && vif.ARREADY
                        |->
                        (vif.ARBURST == `FIXED) && (vif.ARADDR % (2 ** ARSIZE) != 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: INCR_ALIGNED_ARSIZE
            for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.ARVALID && vif.ARREADY
                        |->
                        (vif.ARBURST == `INCR) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar ARSIZE = 1; ARSIZE <= 2; ARSIZE++) begin: INCR_UNALIGNED_ARSIZE
            for (genvar ARLEN = 0; ARLEN <= 15; ARLEN++) begin: _ARLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.ARVALID && vif.ARREADY
                        |->
                        (vif.ARBURST == `INCR) && (vif.ARADDR % (2 ** ARSIZE) != 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
                    )
                );
            end
        end
    endgenerate

    generate
        for (genvar ARSIZE = 0; ARSIZE <= 2; ARSIZE++) begin: WRAP_ALIGNED_ARSIZE
            for (genvar ARLEN = 1; ARLEN <= 15; ARLEN = (ARLEN << 1) + 1) begin: _ARLEN
                cov: cover property (
                    @(posedge vif.ACLK) disable iff (~vif.ARESETn) (
                        vif.ARVALID && vif.ARREADY
                        |->
                        (vif.ARBURST == `INCR) && (vif.ARADDR % (2 ** ARSIZE) == 0) && (vif.ARSIZE == ARSIZE) && (vif.ARLEN == ARLEN)
                    )
                );
            end
        end
    endgenerate
   
endmodule