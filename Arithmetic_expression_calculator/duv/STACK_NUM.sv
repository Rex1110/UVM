`define DEPTH 6   // 2^x
`define DATA_WIDTH 32
module STACK_NUM(
    input               clk,
    input               rst,
    input               flush,
    input               push,
    input               pop2,
    input        [31:0] i_data,
    
    output logic        empty,
    output logic [31:0] o_data,
    output logic [31:0] o_data2
);

    logic [`DEPTH-1:0] sp;
    logic [31:0] stack [(1<<`DEPTH)-1:0];

    assign empty    = (sp == `DEPTH'd0) ? 1'd1 : 1'd0;
    assign o_data   = stack[sp];
    assign o_data2  = stack[sp - `DEPTH'd1];

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            sp <= `DEPTH'd0;
        else if (flush)
            sp <= `DEPTH'd0;
        else if (push) begin
            if (pop2) begin
                sp <= sp - `DEPTH'd1;
                stack[sp - `DEPTH'd1] <= i_data;
            end else begin
                sp <= sp + `DEPTH'd1;
                stack[sp + `DEPTH'd1] <= i_data;
            end
        end else
            sp <= sp;
    end

endmodule

