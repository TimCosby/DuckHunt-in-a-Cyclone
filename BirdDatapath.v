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
	
	reg [7:0] Xhold = 80;
	reg [6:0] Yhold = 60;
	reg [1:0] XDraw = 2'b00;
	reg [1:0] YDraw = 2'b00;
	
	reg reset = 0;
	
	
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
				  S_NEW = 4'b1010;
				  
	localparam HITBOX_LEN = 1'd4;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			XDraw  <= 2'b00;
			YDraw  <= 2'b00;
			Colour <= 3'b111;
			flying <= 0;
			reset <= 1;
		end
		
		else
		begin
			case(control)
				S_NEW:
				begin
					Xhold  <= 80;
					Yhold  <= 60;
					XDraw  <= 2'b00;
					YDraw  <= 2'b00;
					Colour <= 3'b111;
				end
			
				S_B_CLEAR:
				begin
					Colour <= 3'b000;
				end
			
				S_B_UP_RIGHT: 
				begin
					if(Xin < 160 - (HITBOX_LEN - 1))
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
						
					if(Yin > 0)
						Yhold <= Yin - 1;
					else
						Yhold <= Yin;
				end
				
				S_B_UP_LEFT: 
				begin					
					if(Xin > 0)
						Xhold <= Xin - 1;
					else
						Xhold <= Xin;
						
					if(Yin > 0)
						Yhold <= Yin - 1;
					else
						Yhold <= Yin;
				end
				
				S_B_DOWN_RIGHT:
				begin
					if(Xin < 160 - (HITBOX_LEN - 1))
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
				
					if(Yin < 120 - (HITBOX_LEN - 1))
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				S_B_DOWN_LEFT:
				begin
					if(Xin > 0)
						Xhold <= Xin - 1;
					else
						Xhold <= Xin;
						
					if(Yin < 120 - (HITBOX_LEN - 1))
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				S_B_DRAW: // Draw
				begin
					Colour <= 3'b111;
				end
				
				S_B_SHOT: // Shot
				begin
					if(Yin > -4)
					begin
						Yhold <= Yin - 1;
						flying <= 1;
					end
					else
					begin
						flying <= 0;
					end
				end
				
				S_B_ESCAPE: // Escape
				begin
				if(Yin < 120)
					begin
						Yhold <= Yin + 1;
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
						enable <= 1;
							
						if(reset && control == S_B_CLEAR)
						begin
							Xhold  <= 80;
							Yhold  <= 60;
							reset <= 0;
						end
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