module top(
    input                   clk,
    input                   reset,

    output  logic           busy,
    input                   ready,


    input           [12:0]  image [0:4095],

    output  logic   [12:0]  layer1_mem [0:4095],
    output  logic   [12:0]  layer2_mem [0:1023]
);

    logic [12:0] image_mem [0:4095];
    
    logic [11:0] iaddr, caddr_wr, caddr_rd;
    logic [12:0] idata, cdata_wr, cdata_rd;
    logic csel, crd, cwr;

    ATCONV ATCONV_(
        .clk        (clk        ), // input
        .reset      (reset      ), // input

        .busy       (busy       ), // output
        .ready      (ready      ), // input

        .iaddr      (iaddr      ), // output
        .idata      (idata      ), // input

        .csel       (csel       ), // output

        .crd        (crd        ), // output
        .caddr_rd   (caddr_rd   ), // output
        .cdata_rd   (cdata_rd   ), // input

        .cwr        (cwr        ), // output
        .caddr_wr   (caddr_wr   ), // output
        .cdata_wr   (cdata_wr   )  // output
    );

    // image_mem
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            foreach (image_mem[idx]) begin
                image_mem[idx] <= 'd0;    
            end
        end else begin
            if (ready) begin
                foreach (image_mem[idx]) begin
                    image_mem[idx] <= image[idx];    
                end
            end
        end
    end

    // layer1 image
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            foreach (layer1_mem[idx]) begin
                layer1_mem[idx] <= 'd0;
            end
        end else begin
            if (csel == 1'b0 && cwr == 1'b1)
                layer1_mem[caddr_wr] <= cdata_wr;
        end
    end

    // layer2 image
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            foreach (layer2_mem[idx]) begin
                layer2_mem[idx] <= 'd0;
            end
        end else begin
            if (csel == 1'b1 && cwr == 1'b1)
                layer2_mem[caddr_wr] <= cdata_wr;
        end
    end

    // memory output
    assign idata = image_mem[iaddr];

    always_comb begin
        if (crd) begin
            unique case (csel)
                1'b0: cdata_rd = layer1_mem[caddr_rd];
                1'b1: cdata_rd = layer2_mem[caddr_rd];
            endcase
        end
    end
endmodule