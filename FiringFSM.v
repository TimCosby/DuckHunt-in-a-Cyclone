module FiringFSM(clk, reset_n, gunShot, STATE);
	input clk;
	input reset_n;
	input gunShot;
	
	output reg [1:0] STATE = S_RELOAD;
	
	localparam S_RELOAD = 2'b00,
				  S_HOLD   = 2'b01,
				  S_SHOT   = 2'b11;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			STATE <= S_RELOAD;
		end
		
		else
		begin
			case(STATE)
				S_RELOAD:
				begin
					if(~gunShot)
						STATE <= S_HOLD;
					else
						STATE <= S_RELOAD;
				end
			
				S_HOLD:
				begin
					if(gunShot)
						STATE <= S_SHOT;
					else
						STATE <= S_HOLD;
				end
				
				S_SHOT:
				begin
					STATE <= S_RELOAD;
				end
			endcase
		end
	end
endmodule
