module RateDivider(clk, reset_n, enable);
	input clk;
	input reset_n;
	output reg enable;

	wire[26:0] delay = 1666666; //833332; // 1/60 Hz //49999999; // 1 Hz
	
	reg[26:0] q = 0;
	
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
