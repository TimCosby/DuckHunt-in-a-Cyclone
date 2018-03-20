module MovementFSM(clk, reset_n, KEY, STATE, doneDrawing, delayedClk);
	input clk;
	input reset_n;
	input [3:0] KEY;
	input doneDrawing;
	input delayedClk;
	
	output reg [3:0] STATE = 4'b0000;
	
	wire RIGHT = ~KEY[0];
	wire DOWN  = ~KEY[1];
	wire UP    = ~KEY[2];
	wire LEFT  = ~KEY[3];
	
	localparam S_PREHOLD = 4'b0100,
				  S_HOLD    = 4'b0000,
				  S_P_CLEAR = 4'b0001,
				  S_P_LEFT  = 4'b0011,
				  S_P_RIGHT = 4'b0010,
				  S_P_DOWN  = 4'b0110,
				  S_P_UP    = 4'b0111,
				  S_P_DRAW  = 4'b0101;
	
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
					if(~delayedClk) // Until off tick
						STATE <= S_HOLD;
					else
						STATE <= S_PREHOLD;
				end
				
				S_HOLD:
				begin
					if(delayedClk) // Until on tick
						STATE <= S_P_CLEAR;
					else
						STATE <= S_HOLD;
				end
				
				S_P_CLEAR: // Wipes away previous failures
				begin
					if(doneDrawing)
						if(RIGHT)
							STATE <= S_P_RIGHT;
						else if(LEFT)
							STATE <= S_P_LEFT;
						else if(DOWN)
							STATE <= S_P_DOWN;
						else if(UP)
							STATE <= S_P_UP;
						else
							STATE <= S_P_DRAW;
					else
						STATE <= S_P_CLEAR;
				end
				
				S_P_RIGHT:
				begin
					if(DOWN)
						STATE <= S_P_DOWN;
					else if(UP)
						STATE <= S_P_UP;
					else
						STATE <= S_P_DRAW;
				end
				
				S_P_LEFT:
				begin
					if(DOWN)
						STATE <= S_P_DOWN;
					else if(UP)
						STATE <= S_P_UP;
					else
						STATE <= S_P_DRAW;
				end
				
				S_P_UP:
					STATE <= S_P_DRAW;
				
				S_P_DOWN:
					STATE <= S_P_DRAW;
				
				S_P_DRAW:
				begin
					if(doneDrawing)
						if(delayedClk)
							STATE <= S_PREHOLD;
						else
							STATE <= S_HOLD;
					else
						STATE <= S_P_DRAW;
				end
			endcase
		end
	end
endmodule