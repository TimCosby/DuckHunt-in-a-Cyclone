module COUNT(clk, reset_n, enable);
	input clk;
	input reset_n;
	
	output enable;
	
	wire[3:0] DELAY = 14;
	
	reg[3:0] count = 14;
	reg enable = 0;

	always @ (posedge clk, negedge reset_n)
		if(~reset_n)
		begin
			enable <= 0;
			count = DELAY;
		end
		
		else
		begin
			if(count == 0)
			begin
				enable <= 1;
				count <= DELAY;
			end
			
			else
			begin
				enable <= 0;
				count <= count - 1;
			end
		end
endmodule
