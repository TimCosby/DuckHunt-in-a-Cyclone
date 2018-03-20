module BirdDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable, flying);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input [7:0] Xin;
	input [6:0] Yin;
	
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] Colour;
	output reg       plot   = 0;
	output reg       enable = 0;
	output reg 		  flying = 0;
	
	reg [7:0] Xhold = 90;
	reg [6:0] Yhold = 80;
	reg [1:0] XDraw = 2'b00;
	reg [1:0] YDraw = 2'b00;
	
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
			Xhold  <= Xin;
			Yhold  <= Yin;
			Xout   <= 90;
			Yout   <= 80;
			XDraw  <= 2'b00;
			YDraw  <= 2'b00;
			Colour <= 3'b111;
		end
		
		else
		begin
			case(control)
				S_B_CLEAR:
				begin
					Colour <= 3'b000;
				end
			
				S_B_LEFT: 
				begin
					if(Xin > 0)
						Xhold <= Xin - 1;
					else
						Xhold <= Xin;
				end
				
				S_B_RIGHT: 
				begin
					if(Xin < 160) // Max width
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
				end
				
				S_B_DOWN:
				begin
					if(Yin < 120) // Max height
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				S_B_UP: // UP
				begin
					if(Yin > 0)
						Yhold <= Yin - 1;
					else
						Yhold <= Yin;
				end
				
				S_B_DRAW: // Draw
				begin
					Colour <= 3'b111;
				end
				
				S_B_SHOT: // Shot
				begin
					if(Yin < 120)
					begin
						Yhold <= Yin + 1;
						flying <= 1;
					end
					else
						flying <= 0;
				end
				
				S_B_ESCAPE: // Escape
				begin
					if(Yin > 0)
					begin
						Yhold <= Yin - 1;
						flying <= 1;
					end
					else
						flying <= 0;
				end
			endcase
			
			if(control == S_B_CLEAR || control == S_B_DRAW)
			begin
				plot <= 1; // Allows VGA to display the current pixel
				
				Xout <= Xhold + XDraw; // Sets the current x pixel @ current draw + increment
				Yout <= Yhold + YDraw; // y pixel
				
				if(XDraw == 2'b11)
				begin
					if(YDraw == 2'b11)
					begin
						enable <= 1; // Tell the FSM that we are done drawing.
						// (Don't plot <= 0 here because the last pixel still needs to be drawn first)
					end
					
					YDraw <= YDraw + 1; // Increase y increment
				end
				
				XDraw <= XDraw + 1; // Increase x increment
			end
			
			else
			begin
				enable <= 0;
				plot   <= 0;
			end
		end
	end
endmodule