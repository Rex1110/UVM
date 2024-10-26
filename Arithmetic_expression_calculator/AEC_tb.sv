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

    // ( *
    cov_40_42: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd40) && vif.ascii_in == 'd42 );
    // ( +
    cov_40_43: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd40) && vif.ascii_in == 'd43 );
    // ( -
    cov_40_45: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd40) && vif.ascii_in == 'd45 );
    // ( =
    cov_40_61: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd40) && vif.ascii_in == 'd61 );

    // ) num
    cov_41_num: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd41) && vif.ascii_in inside {'d48, 'd49, 'd50, 'd51, 'd52, 'd53, 'd54, 'd55, 'd56, 'd57, 'd97, 'd98, 'd99, 'd100, 'd101, 'd102} );
    // ) (
    cov_41_40: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd41) && vif.ascii_in == 'd40 );

    // * )
    cov_42_41: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd42) && vif.ascii_in == 'd41 );
    // * +
    cov_42_42: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd42) && vif.ascii_in == 'd42 );
    // * -
    cov_42_43: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd42) && vif.ascii_in == 'd43 );
    // * =
    cov_42_45: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd42) && vif.ascii_in == 'd45 );
    // * )
    cov_42_61: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd42) && vif.ascii_in == 'd61 );

    // + )
    cov_43_41: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd43) && vif.ascii_in == 'd41 );
    // + +
    cov_43_42: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd43) && vif.ascii_in == 'd42 );
    // + -
    cov_43_43: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd43) && vif.ascii_in == 'd43 );
    // + =
    cov_43_45: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd43) && vif.ascii_in == 'd45 );
    // + )
    cov_43_61: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd43) && vif.ascii_in == 'd61 );

    // - )
    cov_45_41: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd45) && vif.ascii_in == 'd41 );
    // - +
    cov_45_42: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd45) && vif.ascii_in == 'd42 );
    // - -
    cov_45_43: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd45) && vif.ascii_in == 'd43 );
    // - =
    cov_45_45: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd45) && vif.ascii_in == 'd45 );
    // - )
    cov_45_61: cover property ( @(posedge vif.clk) $past(vif.ascii_in == 'd45) && vif.ascii_in == 'd61 );

    // num 2 num and (
    cov_num2num_40: cover property ( @(posedge vif.clk) $past(vif.ascii_in inside {'d48, 'd49, 'd50, 'd51, 'd52, 'd53, 'd54, 'd55, 'd56, 'd57, 'd97, 'd98, 'd99, 'd100, 'd101, 'd102}) && vif.ascii_in inside {'d48, 'd49, 'd50, 'd51, 'd52, 'd53, 'd54, 'd55, 'd56, 'd57, 'd97, 'd98, 'd99, 'd100, 'd101, 'd102, 'd40} );


    `ifdef VCD
        initial begin
            $dumpfile("wave.vcd.fsdb");
            $dumpvars(0, AEC_tb);
        end
    `endif
endmodule