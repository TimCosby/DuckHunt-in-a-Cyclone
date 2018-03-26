module FiringDatapath(clk, reset_n, control, RemainingShots, XPlayer, YPlayer, XBird, YBird, isShot);
	input       clk;
	input       reset_n;
	input [2:0] control;
	input [7:0] XPlayer;
	input [6:0] YPlayer;
	input [7:0] XBird;
	input [6:0] YBird;
	
	output reg [1:0] RemainingShots = 2'b11;
	output reg       isShot = 1'b0;
	
	localparam S_RELOAD = 2'b00,
				  S_HOLD   = 2'b01,
				  S_SHOT   = 2'b11;
		
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			RemainingShots <= 2'b11;
			isShot <= 0;
		end
		
		else
		begin
			case(control)
				S_SHOT: 
				begin
					if(RemainingShots > 0)
					begin
						RemainingShots <= RemainingShots - 1;
						
						if(((XPlayer >= XBird && XPlayer <= XBird + 3) || (XPlayer + 2 >= XBird && XPlayer + 2 <= XBird + 3)) &&
						   ((YPlayer >= YBird && YPlayer <= YBird + 3) || (YPlayer + 2 >= YBird && YPlayer + 2 <= YBird + 3)))
							isShot <= 1;
							// If Player's hitbox is 3x3 and Bird's 4x4
					end
				end
			endcase
		end
	end
endmodule
