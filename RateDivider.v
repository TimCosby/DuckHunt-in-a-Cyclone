module RateDivider(clk, reset_n, enable, delay);
	input clk;
	input reset_n;
	input [26:0] delay;

	
	output reg enable;
		
	reg [26:0] q = 0;
	
	always @(posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			q <= delay;
			enable <= 0;
		end
		
		else
		begin
			if (q == 0)
			begin
				q <= delay; // 1 Hz
				enable <= ~enable;
			end
		
			else
			begin
				q <= q - 1;
			end
		end
	end
endmodule
