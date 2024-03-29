module MovementFSM(clk, reset_n, KEY, STATE, doneDrawing, delayedClk, isShot, outOfAmmo, PorB, RandX, RandY, escape, fly, fall, leave, round);
	input clk;
	input reset_n;
	input [3:0] KEY;
	input doneDrawing;
	input delayedClk;
	input isShot;
	input escape;
	input outOfAmmo;
	input RandX;
	input RandY;
	input [5:0] round;
	
	input leave;
	output reg fly;
	output reg fall;

	output reg [3:0] STATE;
	output reg       PorB;
	
	reg RIGHT;
	reg DOWN;
	reg UP;
	reg LEFT;
	
	reg [5:0] birdTurn;
	reg reset;
	
	localparam S_PREHOLD   = 4'b0100,
				  S_HOLD      = 4'b0000,
				  S_P_CLEAR   = 4'b0001,
				  S_P_LEFT    = 4'b0011,
				  S_P_RIGHT   = 4'b0010,
				  S_P_DOWN    = 4'b0110,
				  S_P_UP      = 4'b0111,
				  S_P_DRAW    = 4'b0101,
				  S_P_SHOT    = 4'b1000,
				  S_P_ESCAPED = 4'b1001,
				  S_P_IS_SHOT = 4'b1010;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			STATE <= S_P_CLEAR;
			reset <= 1;
			PorB  <= 0;
			birdTurn <= round;
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
					begin
						if(fly)
						begin
							RIGHT <= RandX;
							DOWN  <= 0;
							UP    <= 1;
							LEFT  <= ~RandX;
							STATE <= S_P_CLEAR;
						end
						else if(fall)
						begin
							RIGHT <= 0;
							DOWN  <= 1;
							UP    <= 0;
							LEFT  <= 0;
							STATE <= S_P_CLEAR;
						end
						else
						begin
							RIGHT <= RandX;
							DOWN  <= RandY;
							UP    <= ~RandY;
							LEFT  <= ~RandX;
							STATE <= S_P_CLEAR;
						end
					end
					else
						STATE <= S_HOLD;
				end
				
				S_P_CLEAR: // Wipes away previous failures
				begin
					if(doneDrawing)
					begin
						if(reset)
						begin
							reset <= 0;
							STATE <= S_P_DRAW;
						end
						else if(RIGHT)
							STATE <= S_P_RIGHT;
						else if(LEFT)
							STATE <= S_P_LEFT;
						else if(DOWN)
							STATE <= S_P_DOWN;
						else if(UP)
							STATE <= S_P_UP;
						else
							STATE <= S_P_DRAW;
					end
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
					if(PorB && birdTurn != 0)
					begin
						birdTurn <= birdTurn - 1;
						if(RIGHT)
							STATE <= S_P_RIGHT;
						else if(LEFT)
							STATE <= S_P_LEFT;
						else if(DOWN)
							STATE <= S_P_DOWN;
						else
							STATE <= S_P_UP;
					end
				
					else if(doneDrawing)
					begin
						PorB <= ~PorB;
						
						if(PorB)
						begin
							birdTurn <= round;
							RIGHT <= KEY[0];
							DOWN  <= KEY[1];
							UP    <= KEY[2];
							LEFT  <= KEY[3];
							STATE <= S_P_CLEAR;
						end
						
						else
							STATE <= S_P_IS_SHOT;
					end
					else
						STATE <= S_P_DRAW;
				end
				
				S_P_IS_SHOT:
				begin
					if(leave)
					begin
						fly <= 0;
						fall <= 0;
					end
					else if(isShot)
						fall <= 1;
					else if(escape)
						fly <= 1;
					if(delayedClk)
						STATE <= S_PREHOLD;
					else
						STATE <= S_HOLD;
				end
				
				default:
				begin
					STATE <= S_PREHOLD;
					reset <= 0;
					PorB  <= 0;
					fly   <= 0;
					fall  <= 0;
					birdTurn <= round;
				end
			endcase
		end
	end
endmodule