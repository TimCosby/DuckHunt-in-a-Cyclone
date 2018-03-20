module BirdFSM(clk, reset_n, enable, STATE, enableDraw, shot, outOfAmmo, flying);
	input clk;
	input reset_n;
	input enable;
	input enableDraw;
	input shot;
	input outOfAmmo;
	input flying;
	
	wire [7:0] rand;
	wire [3:0] move;
	wire overflow;
	
	assign move = rand[3:0];
	
	lfsr_updown L0(clk, ~reset_n, enable, 1'b1, rand, overflow);  
	
	output[3:0] STATE;

	reg[3:0] STATE = 4'b1001;
	
	localparam S_HOLD = 4'b0000,
				  S_B_LEFT = 4'b0001,
				  S_B_RIGHT = 4'b0010,
				  S_B_UP = 4'b0011,
				  S_B_DOWN = 4'b0100,
				  S_B_CLEAR = 4'b0101,
				  S_B_DRAW = 4'b0110,
				  S_B_SHOT = 4'b0111,
				  S_B_ESCAPE = 4'b1000,
				  S_B_CHECK = 4'b1001,
				  S_PREHOLD = 4'b1011;
				  
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			STATE <= 4'b0000;
		end
		
		else
		begin
			case(STATE)
				S_PREHOLD:
				begin
					if(~enable)
						STATE <= S_HOLD;
					else
						STATE <= S_PREHOLD;
				end
				
				S_B_SHOT:
				begin
					STATE <= S_B_CHECK;
				end
				
				S_B_ESCAPE:
				begin
					STATE <= S_B_CHECK;
				end
				
				S_B_CHECK:
				begin
					if(~flying)
						STATE <= S_PREHOLD;
					else
						STATE <= S_B_CLEAR;
				end
				
				S_HOLD:
				begin
					if(enable)
					begin
						if(move[0])
							STATE <= S_B_RIGHT;
						else if(move[1])
							STATE <= S_B_LEFT;
						else if(move[2])
							STATE <= S_B_DOWN;
						else if(move[3])
							STATE <= S_B_UP;
						else
							STATE <= S_HOLD;
					end
					
					else
						STATE <= S_HOLD;
				end
				
				S_B_RIGHT:
				begin
					if(move[2])
						STATE <= S_B_DOWN;
					else if(move[3])
						STATE <= S_B_UP;
					else
						STATE <= S_B_CLEAR;
				end
				
				S_B_LEFT:
				begin
					if(move[2])
						STATE <= S_B_DOWN;
					else if(move[3])
						STATE <= S_B_UP;
					else
						STATE <= S_B_CLEAR;
				end
				
				S_B_UP:
					STATE <= S_B_CLEAR;
				
				S_B_DOWN:
					STATE <= S_B_CLEAR;
					
				S_B_CLEAR:
				begin
					if(enableDraw)
						STATE <= S_B_DRAW;
					else
						STATE <= S_B_CLEAR;
				end
				
				S_B_DRAW:
				begin
					if(enableDraw && shot)
						STATE <= S_B_SHOT;
					else if(enableDraw && outOfAmmo)
						STATE <= S_B_ESCAPE;
					else if(enableDraw)
						STATE <= S_HOLD;
					else
						STATE <= S_B_DRAW;
				end
			endcase
		end
	end
endmodule
