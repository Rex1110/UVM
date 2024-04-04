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

	logic	[9:0]	num;
	always_ff @(posedge clk, posedge reset) begin
		if (cnt == 'b0) begin
			for (integer i = 0; i < 11; i++) begin
				num[i] <= 'b0;
			end
		end else begin
			num[data] <= 'b1;
		end
	end
	always_comb begin
		if (num[9])begin	
			if 	(!num[8]) 	min = 'd8;
			else if (!num[7]) 	min = 'd7;
			else if (!num[6]) 	min = 'd6;
			else if (!num[5]) 	min = 'd5;
			else if (!num[4]) 	min = 'd4;
			else if (!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[8])begin	
			if 	(!num[7]) 	min = 'd7;
			else if (!num[6]) 	min = 'd6;
			else if (!num[5]) 	min = 'd5;
			else if (!num[4]) 	min = 'd4;
			else if (!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[7])begin	
			if 	(!num[6]) 	min = 'd6;
			else if (!num[5]) 	min = 'd5;
			else if (!num[4]) 	min = 'd4;
			else if (!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[6])begin	
			if 	(!num[5]) 	min = 'd5;
			else if (!num[4]) 	min = 'd4;
			else if (!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[5])begin	
			if 	(!num[4]) 	min = 'd4;
			else if (!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[4])begin	
			if 	(!num[3]) 	min = 'd3;
			else if (!num[2]) 	min = 'd2;
			else			min = 'd1;
		end	
		else if (num[3])begin	
			if 	(!num[2]) 	min = 'd2;
			else			min = 'd1;
		end
		else 				min = 'd1;
	end
	
	assign valid = ((cnt != 'b0) && (min > data)) || (cnt == 4'b1) ? 1'b1 : 1'b0;
	assign result= (data >= min) ? 1'b1 : 1'b0;		

endmodule
