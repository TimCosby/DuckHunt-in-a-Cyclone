module MovementFSM(clk, reset_n, KEY, STATE, doneDrawing, delayedClk, isShot, outOfAmmo, PorB, RandX, RandY);
	input clk;
	input reset_n;
	input [3:0] KEY;
	input doneDrawing;
	input delayedClk;
	input isShot;
	input outOfAmmo;
	input RandX;
	input RandY;
	
	output reg [3:0] STATE;
	output reg       PorB;
	
	wire [27:0] q;
	wire bclk;
	wire [7:0] rand;
	wire [1:0] move;
	wire overflow;
	reg inAnimation = 0;
	
	assign bclk = (q == 0) ? 1 : 0;
	assign move = rand[1:0];
	
	RateDividerB RTD0(49999999, q, clk, reset_n, 0, 1);
	lfsr_updown L0(bclk, ~reset_n, ~doneDrawing, 1'b1, rand, overflow);
	
	reg RIGHT;
	reg DOWN;
	reg UP;
	reg LEFT;
	
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
						RIGHT <= move[0];
						DOWN  <= move[1];
						UP    <= ~move[1];
						LEFT  <= ~move[0];
						STATE <= S_P_CLEAR;
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
					if(doneDrawing)
					begin
						PorB <= ~PorB;
						if(PorB)
						begin
							RIGHT <= ~KEY[0];
							DOWN  <= ~KEY[1];
							UP    <= ~KEY[2];
							LEFT  <= ~KEY[3];
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
				end
			endcase
		end
	end
endmodule