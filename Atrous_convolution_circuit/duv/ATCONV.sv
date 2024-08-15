module  ATCONV(
	input					clk,
	input					reset,
	output	logic			busy,	
	input					ready,	
			
	output 	logic	[11:0]	iaddr,
	input 	signed 	[12:0]	idata,
	
	output	logic 			cwr,
	output  logic	[11:0]	caddr_wr,
	output 	logic	[12:0] 	cdata_wr,
	
	output	logic 			crd,
	output 	logic	[11:0] 	caddr_rd,
	input 			[12:0] 	cdata_rd,
	
	output 	logic 			csel
);

	parameter IDLE 			= 2'd0;
	parameter CONVOLUTION 	= 2'd1;
	parameter POOLING       = 2'd2;
	parameter STRIDE2       = 2'd3;


	logic [12:0] answer;
	logic [1:0] state, next_state;
	logic [5:0] image_X, image_Y;
	logic [8:0] filter_X, filter_Y;
	logic [12:0] acc;

	logic [5:0] addr_X, addr_Y;
	logic [143:0] filter;

	// filter
	
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			filter <= 144'h1FFF_1FFE_1FFF_1FFC_0010_1FFC_1FFF_1FFE_1FFF;
		end else if (state == IDLE) begin
			filter <= 144'h1FFF_1FFE_1FFF_1FFC_0010_1FFC_1FFF_1FFE_1FFF;
		end else if (state == CONVOLUTION) begin
			filter <= {filter[15:0], filter[143:16]};
		end else begin
			filter <= filter;
		end
	end

	// filter_X
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			filter_X <= 9'b010_000_110;
		end else if (state == IDLE) begin
			filter_X <= 9'b010_000_110;
		end else if (state == CONVOLUTION) begin
			if (next_state == POOLING) begin
				filter_X <= 9'b0;
			end else begin
				filter_X <= {filter_X[2:0], filter_X[8:3]};
			end
		end else if (state == POOLING) begin
			filter_X <= filter_X ^ 9'b1;
		end else begin
			filter_X <= filter_X;
		end
	end

	// filter_Y
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			filter_Y <= 9'b010_000_110;
		end else if (state == IDLE) begin
			filter_Y <= 9'b010_000_110;
		end else if (filter_X[2:0] == 3'b010) begin
			if (next_state == POOLING) begin
				filter_Y <= 9'b0;
			end else begin
				filter_Y <= {filter_Y[2:0], filter_Y[8:3]};
			end
		end else if (state == POOLING && filter_X == 9'b1) begin
			filter_Y <= filter_Y ^ 9'b1;
		end else begin
			filter_Y <= filter_Y;
		end
	end

	// image_X
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			image_X <= 6'b0;
		end else if (state == IDLE) begin
			image_X <= 6'b0;
		end else if (filter_X[2:0] == 3'b010 && filter_Y[2:0] == 3'b010) begin
			if (next_state == POOLING) begin
				image_X <= 6'b0;
			end else begin
				image_X <= image_X + 6'b1;
			end
		end else if (state == STRIDE2) begin
			image_X <= image_X + 6'd2;
		end else begin
			image_X <= image_X;
		end
	end

	// image_Y
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			image_Y <= 6'b0;
		end else if (state == IDLE) begin
			image_Y <= 6'b0;
		end else if (filter_X[2:0] == 3'b010 && filter_Y[2:0] == 3'b010 && image_X == 6'b11_1111) begin
			if (next_state == POOLING) begin
				image_Y <= 6'b0;
			end else begin
				image_Y <= image_Y + 6'b1;
			end
		end else if (state == STRIDE2 && image_X == 6'd62) begin
			image_Y <= image_Y + 6'd2;
		end else begin
			image_Y <= image_Y;
		end
	end

	// addr_X
	always_comb begin
		if ($signed({1'b0, image_X}) + $signed(filter_X[2:0]) < 0) begin
			addr_X = 6'd0;
		end else if ($signed({1'b0, image_X}) + $signed(filter_X[2:0]) > 63) begin
			addr_X = 6'd63;
		end else begin
			addr_X = $signed({1'b0, image_X}) + $signed(filter_X[2:0]);
		end
	end

	// addr_Y
	always_comb begin
		if ($signed({1'b0, image_Y}) + $signed(filter_Y[2:0]) < 0) begin
			addr_Y = 6'd0;
		end else if ($signed({1'b0, image_Y}) + $signed(filter_Y[2:0]) > 63) begin
			addr_Y = 6'd63;
		end else begin
			addr_Y = $signed({1'b0, image_Y}) + $signed(filter_Y[2:0]);
		end
	end
	
	// memory addr
	always_comb begin
		iaddr = addr_X + (addr_Y * 64);
	end

	// conv result
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			acc <= 13'b0;
		end else if (state == IDLE) begin
			acc <= 13'b0;
		end else if (filter_X[2:0] == 3'b010 && filter_Y[2:0] == 3'b010) begin
			acc <= 13'b0;
		end else if (state == CONVOLUTION) begin
			acc <= $signed(acc) + ((idata >> 4) * $signed(filter[12:0]));
		end else if (state == STRIDE2) begin
			acc <= 13'b0;
		end else if (state == POOLING && cdata_rd > acc) begin
			acc <= cdata_rd;
		end else begin
			acc <= acc;
		end
	end
	assign answer = $signed(acc) + ((idata >> 4) * $signed(filter[12:0])) + $signed(13'h1FF4);

	// wr_en 發生在conv x y 都等於-2 以及stride2 cuz layer 0 1 一次只能操作一個
	always_comb begin
		if ((filter_X[2:0] == 3'b010 && filter_Y[2:0] == 3'b010) || state == STRIDE2) begin
			cwr = 1'b1;
		end else begin
			cwr = 1'b0;
		end
	end

	// relu / round
	always_comb begin
		if (state == CONVOLUTION) begin
			if (answer[12] == 1'b1) begin
				cdata_wr = 13'b0;
			end else begin
				cdata_wr = answer;
			end
		end else begin
			cdata_wr = {acc[12:4], 4'b0} + ((|acc[3:0]) << 4);
		end
	end

	// layer memory 剩餘狀態
	always_comb begin
		if (state == IDLE) begin
			csel = 'b0;
			crd  = 'b0;
			caddr_rd = 'd0;
			caddr_wr = 'd0;
		end else if (state == CONVOLUTION || state == POOLING) begin
			csel = 1'b0;
			crd = 1'b1;
			caddr_rd = addr_X + (addr_Y * 64);
			caddr_wr = image_X + 64 * image_Y;
		end else begin
			csel = 1'b1;
			crd = 1'b1;
			caddr_rd = addr_X + (addr_Y * 64);
			caddr_wr = (image_X >> 1) + (16 * image_Y);
		end
	end

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end
	
	always_comb begin
		case (state)
			IDLE: begin
				if (ready) begin
					next_state = CONVOLUTION;
				end else begin
					next_state = IDLE;
				end
			end
			CONVOLUTION: begin
				if (filter_X[2:0] == 3'b010 && filter_Y[2:0] == 3'b010 && caddr_wr == 12'd4095) begin
					next_state = POOLING;
				end else begin
					next_state = CONVOLUTION;
				end
			end
			POOLING: begin
				if (filter_X[0] == 1'b1 && filter_Y[0] == 1'b1) begin
					next_state = STRIDE2;
				end else begin
					next_state = POOLING;
				end
			end
			STRIDE2: begin
				if (caddr_wr == 12'd1023) begin
					next_state = IDLE;
				end else begin
					next_state = POOLING;
				end
			end
		endcase
	end

	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			busy <= 1'b0;
		end else if (ready) begin
			busy <= 1'b1;
		end else if (next_state == IDLE) begin
			busy <= 1'b0;
		end else begin
			busy <= busy;
		end
	end

endmodule