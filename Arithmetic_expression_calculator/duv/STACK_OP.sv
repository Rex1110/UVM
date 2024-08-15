`define DEPTH 6   // 2^x
`define DATA_WIDTH 32
module STACK_OP(
    input               clk,
    input               rst,
    input               flush,
    input               push,
    input               pop,
    input        [7:0] i_data,
    
    output logic        empty,
    output logic [7:0] o_data
);

    logic [`DEPTH-1:0] sp;
    logic [7:0] stack [(1<<`DEPTH)-1:0];

    assign empty    = (sp == `DEPTH'd0) ? 1'd1 : 1'd0;
    assign o_data   = stack[sp];

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            sp <= `DEPTH'd0;
        else if (flush)
            sp <= `DEPTH'd0;
        else if (push) begin
            sp  <= sp + `DEPTH'd1;
            stack[sp + `DEPTH'd1] <= i_data;
        end else if (pop)
            sp <= sp - `DEPTH'd1;
        else
            sp <= sp;
    end

endmodule

