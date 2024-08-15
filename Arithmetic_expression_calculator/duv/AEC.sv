`define BUFFER_LEN 64
module AEC(
    input               clk,
    input               rst,
    input               ready,
    input        [7:0]  ascii_in,
    
    output logic        finish,
    output logic [31:0] result
);


    parameter IDLE              = 3'd0;
    parameter RECEIVE1          = 3'd1;
    parameter PARSE             = 3'd2;
    parameter CALUATE           = 3'd3;
    parameter CLEAR_PARENTHESES = 3'd4;

    logic [31:0] sum, src1, src2;
    logic [31:0] i_data_num;
    logic [2:0] state, next_state;
    logic [8*(`BUFFER_LEN)-1:0] in;         // queue to save num
    
    logic [6:0] cnt;                      // how many num in queue
    logic push_op, push_num;
    logic empty_op, empty_num;
    logic [7:0] i_data_op;
    logic [7:0] o_data_op;

    logic [7:0] DecNum;

    always_comb begin
        if (ascii_in > 8'd47 && ascii_in < 8'd58)
            DecNum = ascii_in - 8'd48; // 0 ~ 9
        else if (ascii_in > 8'd96)
            DecNum = ascii_in - 8'd87; // 10 ~ 15
        else if ((ascii_in > 8'd39 && ascii_in < 8'd46) && ascii_in != 8'd44)
            DecNum = ascii_in; // ()*+-
        else 
            DecNum = 8'd61;
    end

    always_comb begin
        if (next_state == PARSE)
            i_data_op = in[7:0];
        else
            i_data_op = 8'b0;
    end

    always_comb begin
        if (next_state == PARSE)
            i_data_num = in[7:0];
        else
            i_data_num = sum;
    end


    always_comb begin
        if (next_state == PARSE)
            if (in[7:0] > 8'd39 && in[7:0] < 8'd46)
                push_op = 1'b1;
            else
                push_op = 1'b0;
        else
                push_op = 1'b0;
    end

    always_comb begin
        if (next_state == PARSE)
            if (in[7:0] > 8'd39 && in[7:0] < 8'd46 || in[7:0] == 8'd61)
                push_num = 1'b0;
            else
                push_num = 1'b1;
        else if (next_state == CALUATE)
            push_num = 1'b1;
        else
            push_num = 1'b0;
    end



    STACK_NUM STACK_NUM1(
        .clk    (clk                    ),
        .rst    (rst                    ),
        .flush  (next_state == IDLE     ),
        .push   (push_num               ),
        .pop2   (next_state == CALUATE  ),
        .i_data (i_data_num             ),
        .empty  (empty_num              ),
        .o_data (src1                   ),
        .o_data2(src2                   )
    );

    STACK_OP STACK_OP1(
        .clk    (clk                    ),
        .rst    (rst                    ),
        .flush  (next_state == IDLE     ),
        .push   (push_op                ),
        .pop    ((next_state == CALUATE) || (next_state == CLEAR_PARENTHESES)),
        .i_data (i_data_op              ),
        .empty  (empty_op               ),
        .o_data (o_data_op              )
    );

    
    always_comb begin
        if (o_data_op[7:0] == 8'd42)
            sum = src2 * src1;
        else if (o_data_op[7:0] == 8'd43)
            sum = src2 + src1;
        else
            sum = src2 - src1;
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst)    state <= IDLE;
        else        state <= next_state; 
    end

    always_comb begin
        case (state)
            IDLE: begin
                next_state = (ready == 1'b1) ? RECEIVE1 : IDLE;
            end
            RECEIVE1:
                next_state = (ascii_in == 8'd61) ? IDLE : PARSE;
            PARSE: begin
                if (cnt == 32'b0)
                    next_state = CALUATE;
                else if (in[7:0] == 8'd42)  // if in[7:0] == * then if fifo_op == * - + pop and caluate
                    if (o_data_op == 8'd42) next_state = CALUATE; // *
                    else                    next_state = PARSE;
                else if ((in[7:0] == 8'd43) || (in[7:0] == 8'd45)) // + -
                    if (o_data_op == 8'd42 || o_data_op == 8'd43 || o_data_op == 8'd45) next_state = CALUATE;
                    else                                                                next_state = PARSE;
                else if (in[7:0] == 8'd41) // if in[7:0] == ) then if fifo_op == ( clear them else keep pop
                    if (o_data_op == 8'd40) next_state = CLEAR_PARENTHESES;
                    else                    next_state = CALUATE;
                else
                    next_state = PARSE;
                end
            CALUATE: begin
                if (cnt == 32'b0)
                    next_state = empty_op ? IDLE : CALUATE;
                else if (in[7:0] == 8'd42) // *
                    if (o_data_op == 8'd42) next_state = CALUATE;
                    else                    next_state = PARSE;
                else if ((in[7:0] == 8'd43) || (in[7:0] == 8'd45)) // + -
                    if (o_data_op == 8'd42 || o_data_op == 8'd43 || o_data_op == 8'd45) next_state = CALUATE;
                    else                                                                next_state = PARSE;
                else // if (in[7:0] == 8'd41) // clear ()
                    if (o_data_op == 8'd40) next_state = CLEAR_PARENTHESES;
                    else                    next_state = CALUATE;
                end
            CLEAR_PARENTHESES: begin
                if (cnt == 32'b0)
                    next_state = empty_op ? IDLE : CALUATE;
                else if (in[7:0] == 8'd42)
                    if (o_data_op == 8'd42) next_state = CALUATE;
                    else                    next_state = PARSE;
                else if ((in[7:0] == 8'd43) || (in[7:0] == 8'd45))
                    if (o_data_op == 8'd42 || o_data_op == 8'd43 || o_data_op == 8'd45) next_state = CALUATE;
                    else                                                                next_state = PARSE;
                else if (in[7:0] == 8'd41)
                    if (o_data_op == 8'd40) next_state = CLEAR_PARENTHESES;
                    else                    next_state = CALUATE;
                else
                    next_state = PARSE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            cnt <= 32'b0;
        else if (next_state == IDLE)
            cnt <= 32'b0;
        else if (next_state == RECEIVE1)
            cnt <= cnt + 32'b1;
        else if (next_state == PARSE && DecNum == 8'd61) // =
            cnt <= cnt - 32'b1;
        else if (next_state == CALUATE && DecNum != 8'd61) // keep push into queue
            cnt <= cnt + 32'b1;
        else if (next_state == CLEAR_PARENTHESES && DecNum == 8'd61)
            cnt <= cnt - 32'b1;
        else
            cnt <= cnt;
    end
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            in <= 8*`BUFFER_LEN'b0;
        else if (next_state == IDLE)
            in <= 8*`BUFFER_LEN'b0;
        else if (next_state == RECEIVE1)
            in <= DecNum;
        else if (next_state == PARSE && DecNum != 8'd61)
            in <= (in >> 8) + (DecNum << ((cnt - 1) * 8));
        else if (next_state == PARSE && DecNum == 8'd61)
            in <= (in >> 8);
        else if (next_state == CALUATE && DecNum != 8'd61)
            in <= (in + (DecNum << (cnt * 8)));
        else if (next_state == CLEAR_PARENTHESES && DecNum != 8'd61)
            in <= (in >> 8) + (DecNum << ((cnt - 1) * 8));
        else if (next_state == CLEAR_PARENTHESES && DecNum == 8'd61)
            in <= (in >> 8);
        else
            in <= in;
    end


    assign result = (state == RECEIVE1) ? in[7:0] : src1;
    assign finish = (next_state == IDLE);
endmodule


