module FiringDatapath(clk, reset_n, control, RemainingShots, XBird, YBird, XPlayer, YPlayer, isShot, escape, fly, fall, leave);
	input       clk;
	input       reset_n;
	input [2:0] control;
	input [7:0] XPlayer;
	input [7:0] XBird;
	input [6:0] YPlayer;
	input [7:0] YBird;
	input 		fly;
	input 		fall;
	input       leave;
	
	output reg isShot = 0;
	output reg escape = 0;
	output reg [1:0] RemainingShots = 2'b11;
	
	localparam S_RELOAD = 2'b00,
				  S_HOLD   = 2'b01,
				  S_SHOT   = 2'b11;
				  
	localparam HITBOX_X = 4'b1110,
				  HITBOX_Y = 4'b1001;
		
	always @ (posedge clk, negedge reset_n, posedge leave)
	begin
		if(~reset_n || leave)
		begin
			RemainingShots <= 2'b11;
			isShot <= 0;
			escape <= 0;
		end
		
		else
		begin
			case(control)				
				S_SHOT: 
				begin
					if(RemainingShots > 0)
					begin
						RemainingShots <= RemainingShots - 1;
						
						if(((XPlayer >= XBird && XPlayer <= XBird + (HITBOX_X - 1)) || (XPlayer + 2 >= XBird && XPlayer + 2 <= XBird + (HITBOX_X - 1))) &&
						   ((YPlayer >= YBird && YPlayer <= YBird + (HITBOX_Y - 1)) || (YPlayer + 2 >= YBird && YPlayer + 2 <= YBird + (HITBOX_Y - 1))) && 
							~fly && ~fall)
							isShot <= 1;
							// If Player's hitbox is 3x3 and Bird's 4x4
					end
				end
				
				S_RELOAD:
				begin
					if(RemainingShots == 0 && ~isShot)
					begin
						escape <= 1;
					end
				end
			endcase
		end
	end
endmodule
