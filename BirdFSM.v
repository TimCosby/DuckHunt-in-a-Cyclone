module BirdFSM(clk, reset_n, STATE, doneDrawing, delayedClk, shot, outOfAmmo, flying);
	input clk;
	input reset_n;
	input doneDrawing;
	input delayedClk;
	input shot;
	input outOfAmmo;
	input flying;
	
	output reg [3:0] STATE = S_B_DRAW;
	
	wire [27:0] q;
	wire bclk;
	wire [7:0] rand;
	wire [1:0] move;
	wire overflow;
	reg inAnimation;
	
	assign bclk = (q == 0) ? 1 : 0;
	assign move = rand[1:0];
	
	RateDividerB RTD0(49999999, q, clk, reset_n, 0, 1);
	lfsr_updown L0(bclk, ~reset_n, ~doneDrawing, 1'b1, rand, overflow);
	
	wire UP_RIGHT = 2'b00;
	wire UP_LEFT = 2'b01;
	wire DOWN_RIGHT = 2'b10;
	wire DOWN_LEFT = 2'b11;
	
	localparam S_PREHOLD = 4'b0100,
				  S_HOLD    = 4'b0000,
				  S_B_CLEAR = 4'b0001,
				  S_B_UP_RIGHT  = 4'b0011,
				  S_B_UP_LEFT = 4'b0010,
				  S_B_DOWN_RIGHT  = 4'b0110,
				  S_B_DOWN_LEFT    = 4'b0111,
				  S_B_DRAW  = 4'b0101,
				  S_B_SHOT = 4'b1000,
				  S_B_ESCAPE = 4'b1001,
				  S_RESET = 4'b1010;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			STATE <= S_PREHOLD;
		end
		
		else
		begin
			case(STATE)
				S_RESET: // Resets the birds position after it leaves the screen
				begin
					inAnimation <= 0;
					STATE <= S_PREHOLD;
				end
			
				S_PREHOLD:
				begin
					if(~delayedClk) // Until off tick
						STATE <= S_HOLD;
					else
						STATE <= S_PREHOLD;
				end
				
				S_B_SHOT:
				begin
					if(~flying)
						STATE <= S_RESET;
					else
						STATE <= S_PREHOLD;
				end
				
				S_B_ESCAPE:
				begin
					if(~flying)
						STATE <= S_RESET;
					else
						STATE <= S_PREHOLD;
				end
				
				S_HOLD:
				begin
					if(delayedClk) // Until on tick
						STATE <= S_B_CLEAR;
					else
						STATE <= S_HOLD;
				end
				
				S_B_CLEAR: // Wipes away previous failures
				begin
					if(doneDrawing)
						if (flying) // Check to see if bird is falling/flying away
							STATE <= S_B_DRAW;
						else if(move == UP_RIGHT)
							STATE <= S_B_UP_RIGHT;
						else if (move == UP_LEFT)
							STATE <= S_B_UP_LEFT;
						else if (move == DOWN_RIGHT)
							STATE <= S_B_DOWN_RIGHT;
						else if (move == DOWN_LEFT)
							STATE <= S_B_DOWN_LEFT;
					else
						STATE <= S_B_CLEAR;
				end
				
				S_B_UP_RIGHT:
					STATE <= S_B_DRAW;
				
				S_B_UP_LEFT:
					STATE <= S_B_DRAW;
				
				S_B_DOWN_RIGHT:
					STATE <= S_B_DRAW;
				
				S_B_DOWN_LEFT:
					STATE <= S_B_DRAW;
				
				S_B_DRAW:
				begin
					if(doneDrawing)
						if(delayedClk && (shot || inAnimation))
						begin
							inAnimation <= 1;
							STATE <= S_B_SHOT;
						end
						else if(delayedClk && (outOfAmmo || inAnimation))
						begin
							inAnimation <= 1;
							STATE <= S_B_ESCAPE;
						end
						else if(delayedClk)
							STATE <= S_PREHOLD;
						else
							STATE <= S_HOLD;
					else
						STATE <= S_B_DRAW;
				end
			endcase
		end
	end
endmodule

module RateDividerB(d, q, clock, reset_n, par_load, enable);
	input [27:0] d;
	input clock;
	input reset_n;
	input par_load, enable;
	
	output q;
	
	reg [27:0] q;

	always @(posedge clock)
	begin
		if (reset_n == 1'b0)
			q <= 0;
		else if (par_load == 1'b1)
			q <= d;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= d;
				else
					q <= q - 1;
			end
	end
endmodule
