module rails(
	input		clk,
	input		reset,
	input 	[3:0]	data,

	output 	logic	valid,
	output	logic	result
);

	logic  	[3:0] 	cnt;
	logic 	[3:0] 	min;
	

	always_ff @(posedge clk, posedge reset) begin
		if (reset || valid) begin
			cnt <= 'b0;
		end else if (cnt == 'b0) begin
			cnt <= data;
		end else begin
			cnt <= cnt - 'b1;
		end
	end

	logic	[8:0]	num;
	always_ff @(posedge clk, posedge reset) begin
		if (cnt == 'b0) begin
			num <= 'd0;
		end else begin
			num[data - 'd1] <= 'b1;
		end
	end
	always_comb begin
		if (num[8])begin	
			if 		(!num[7]) 	min = 'd8;
			else if (!num[6]) 	min = 'd7;
			else if (!num[5]) 	min = 'd6;
			else if (!num[4]) 	min = 'd5;
			else if (!num[3]) 	min = 'd4;
			else if (!num[2]) 	min = 'd3;
			else if (!num[1]) 	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end	
		else if (num[7])begin	
			if 		(!num[6]) 	min = 'd7;
			else if (!num[5]) 	min = 'd6;
			else if (!num[4]) 	min = 'd5;
			else if (!num[3]) 	min = 'd4;
			else if (!num[2]) 	min = 'd3;
			else if (!num[1])   min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end	
		else if (num[6])begin	
			if 		(!num[5]) 	min = 'd6;
			else if (!num[4]) 	min = 'd5;
			else if (!num[3]) 	min = 'd4;
			else if (!num[2]) 	min = 'd3;
			else if (!num[1]) 	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end	
		else if (num[5])begin	
			if 		(!num[4]) 	min = 'd5;
			else if (!num[3]) 	min = 'd4;
			else if (!num[2]) 	min = 'd3;
			else if (!num[1]) 	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end	
		else if (num[4])begin	
			if 		(!num[3]) 	min = 'd4;
			else if (!num[2]) 	min = 'd3;
			else if (!num[1]) 	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end	
		else if (num[3])begin	
			if 		(!num[2])	min = 'd3;
			else if (!num[1])	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end
		else if (num[2])begin	
			if 		(!num[1])	min = 'd2;
			else if (!num[0]) 	min = 'd1;
			else				min = 'd0;
		end
		else if (num[1])begin	
			if 	(!num[0]) 		min = 'd1;
			else				min = 'd0;
		end
		else 					min = 'd0;
	end
	
	assign valid = ((cnt != 'b0) && (min > data)) || (cnt == 4'b1) ? 1'b1 : 1'b0;
	assign result= (data >= min) ? 1'b1 : 1'b0;		

endmodule
