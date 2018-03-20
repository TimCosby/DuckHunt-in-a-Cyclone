module FiringDatapath(clk, reset_n, control, RemainingShots);
	input       clk;
	input       reset_n;
	input [2:0] control;
	
	output reg [1:0] RemainingShots = 2'b11;
	
	localparam S_PRELOAD = 3'b010,
				  S_HOLD1   = 3'b000,
				  S_SHOT1   = 3'b001,
				  S_HOLD2   = 3'b101,
				  S_SHOT2   = 3'b100,
				  S_HOLD3   = 3'b110,
				  S_SHOT3   = 3'b111,
				  S_OUT     = 3'b011;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			RemainingShots <= 2'b11;
		end
		
		else
		begin
			case(control)
				S_SHOT1: RemainingShots <= 2'b10;
				
				S_SHOT2: RemainingShots <= 2'b01;
				
				S_SHOT3: RemainingShots <= 2'b00;
			endcase
		end
	end
endmodule
