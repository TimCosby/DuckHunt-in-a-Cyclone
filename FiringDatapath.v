module FiringDatapath(clk, reset_n, control, RemainingShots);
	input       clk;
	input       reset_n;
	input [2:0] control;
	
	output reg [1:0] RemainingShots = 2'b11;
	
	//reg [3:0] animation = 4'b1100;
	//reg       offset;
	
	localparam S_RELOAD = 2'b00,
				  S_HOLD   = 2'b01,
				  S_SHOT   = 2'b11;
		
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			RemainingShots <= 2'b11;
			//animation      <= 4'b1000;
		end
		
		else
		begin
			case(control)
				S_SHOT: 
				begin
					if(RemainingShots > 0)
					begin
						RemainingShots <= RemainingShots - 1;
						//animation <= 4'b0000;
						//plot <= 1;
					end
					
					else
					begin
						// Out of bullets
					end
				end
			endcase
			
			/*if(animation < 4'b1100)
			begin
				if(animation[1:0] == 2'b00)
					offset <= 0;
				else if(animation[1:0] == 2'b01)
				begin
					offset <= 1;
				end
				else if(animation[1:0] == 2'b10)
					offset <= 2;
				
				if(animation[3:2] == 2'b00)
				begin
					Xout <= Xhold - offset;
					Yout <= Yhold - offset;
				end
				else if(animation[3:2] == 2'b01)
				begin
					Xout <= Xhold + 2 + offset;
					Yout <= Yhold - offset;
				end
				else if(animation[3:2] == 2'b10)
				begin
					Xout <= Xhold - offset;
					Yout <= Yhold + 2 + offset;
				end
				else if(animation[3:2] == 2'b11)
				begin
					Xout <= Xhold + 2 + offset;
					Yout <= Yhold + 2 + offset;
				end
				
				animation <= animation + 1;
			end	
			else
			begin
				plot <= 0;
			end*/
		end
	end
endmodule
