module MovementFSM(clk, reset_n, KEY, STATE, enableDraw, enable);
	input clk;
	input reset_n;
	input[3:0] KEY;
	input enableDraw;
	input enable;
	
	output[3:0] STATE;

	reg[3:0] STATE = 4'b0000;
	
	localparam S_HOLD = 4'b0000,
				  S_P_LEFT = 4'b0001,
				  S_P_RIGHT = 4'b0010,
				  S_P_UP = 4'b0011,
				  S_P_DOWN = 4'b0100,
				  S_P_CLEAR = 4'b0101,
				  S_P_DRAW = 4'b0110,
				  S_PREHOLD = 4'b0111;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			STATE <= 4'b0000;
		end
		
		else
		begin
			case(STATE)
				/*
				KEY[0] = RIGHT
				KEY[1] = DOWN
				KEY[2] = UP
				KEY[3] = LEFT
				*/
				S_PREHOLD:
				begin
					if(~enable)
						STATE <= S_HOLD;
					else
						STATE <= S_PREHOLD;
				end
				
				S_HOLD:
				begin
					if(enable)
					begin
						if(~KEY[0])
							STATE <= S_P_RIGHT;
						else if(~KEY[3])
							STATE <= S_P_LEFT;
						else if(~KEY[1])
							STATE <= S_P_DOWN;
						else if(~KEY[2])
							STATE <= S_P_UP;
						else
							STATE <= S_HOLD;
					end
					
					else
						STATE <= S_HOLD;
				end
				
				S_P_RIGHT:
				begin
					if(~KEY[1])
						STATE <= S_P_DOWN;
					else if(~KEY[2])
						STATE <= S_P_UP;
					else
						STATE <= S_P_CLEAR;
				end
				
				S_P_LEFT:
				begin
					if(~KEY[1])
						STATE <= S_P_DOWN;
					else if(~KEY[2])
						STATE <= S_P_UP;
					else
						STATE <= S_P_CLEAR;
				end
				
				S_P_UP:
					STATE <= S_P_CLEAR;
				
				S_P_DOWN:
					STATE <= S_P_CLEAR;
					
				S_P_CLEAR:
				begin
					if(enableDraw)
						STATE <= S_P_DRAW;
					else
						STATE <= S_P_CLEAR;
				end
				
				S_P_DRAW:
				begin
					if(enableDraw)
						STATE <= S_PREHOLD;
					else
						STATE <= S_P_DRAW;
				end
			endcase
		end
	end
endmodule
