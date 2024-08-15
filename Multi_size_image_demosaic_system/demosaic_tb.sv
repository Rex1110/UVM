`include "./uvm_macros.svh"
import uvm_pkg::*;

module demosaic_tb();

    // 系統目前最大只處理 width = 256, height = 125
    // 最小的圖必須為 3x3 扣除掉 邊界 3x3 需計算一個 pixel 在小就沒了
    initial begin
        assert (`WIDTH_MIN >= 3 && `WIDTH_MAX <= 256) else `uvm_fatal("demosaic_tb", "3 <= WIDTH <= 256");
        assert (`WIDTH_MAX >= `WIDTH_MIN) else `uvm_fatal("demosaic_tb", "WIDTH_MAX >= WIDTH_MIN");
        assert (`HEIGHT_MIN >= 3 && `HEIGHT_MAX <= 128) else `uvm_fatal("demosaic_tb", "3 <= HEIGHT <= 128");
        assert (`HEIGHT_MAX >= `HEIGHT_MIN) else `uvm_fatal("demosaic_tb", "HEIGHT_MAX >= HEIGHT_MIN");
    end

    duv_if vif();

    top top_(
        .clk        (vif.clk        ),
        .reset      (vif.reset      ),

        .in_en      (vif.in_en      ),
        .width      (vif.width      ),
        .height     (vif.height     ),

        .bayer_img  (vif.bayer_img  ),
        .channel_r  (vif.channel_r  ),
        .channel_g  (vif.channel_g  ),
        .channel_b  (vif.channel_b  ),
        
        .done       (vif.done       )
    );

    initial begin
        vif.clk = 0;
        forever #1 vif.clk = ~vif.clk;
    end

    initial begin
        uvm_config_db#(virtual duv_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
endmodule