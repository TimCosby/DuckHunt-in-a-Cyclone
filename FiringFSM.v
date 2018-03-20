module FiringFSM(clk, reset_n, gunShot, STATE);
	input clk;
	input reset_n;
	input gunShot;
	
	output reg [2:0] STATE = 3'b010;

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
			STATE <= 3'b110;
		end
		
		else
		begin
			case(STATE)
				S_PRELOAD:
				begin
					if(~gunShot)
						STATE <= S_HOLD1;
					else
						STATE <= S_PRELOAD;
				end
			
				S_HOLD1:
				begin
					if(gunShot)
						STATE <= S_SHOT1;
					else
						STATE <= S_HOLD1;
				end
				
				S_SHOT1:
				begin
					if(~gunShot)
						STATE <= S_HOLD2;
					else
						STATE <= S_SHOT1;
				end
				
				S_HOLD2:
				begin
					if(gunShot)
						STATE <= S_SHOT2;
					else
						STATE <= S_HOLD2;
				end
				
				S_SHOT2:
				begin
					if(~gunShot)
						STATE <= S_HOLD3;
					else
						STATE <= S_SHOT2;
				end
				
				S_HOLD3:
				begin
					if(gunShot)
						STATE <= S_SHOT3;
					else
						STATE <= S_HOLD3;
				end
				
				S_SHOT3:
				begin
					STATE <= S_SHOT3;
				end
			endcase
		end
	end
endmodule
