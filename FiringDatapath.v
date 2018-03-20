module FiringDatapath(clk, reset_n, control, RemainingShots);
	input clk;
	input reset_n;
	input[2:0] control;
	
	output[1:0] RemainingShots = 2'b11;
	reg[1:0] RemainingShots = 2'b11;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			RemainingShots <= 2'b11;
		end
		
		else
		begin
			case(control)
				3'b001: RemainingShots <= 2'b10;
				
				3'b011: RemainingShots <= 2'b01;
				
				3'b101: RemainingShots <= 2'b00;
			endcase
		end
	end
	
endmodule
