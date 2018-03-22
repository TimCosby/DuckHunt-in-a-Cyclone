module BirdDatapath(clk, reset_n, control, Xin, Xout, Xplayer, Yin, Yout, Yplayer, Colour, plot, enable, flying, firing, shot);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input [7:0] Xin;
	input [6:0] Yin;
	input [7:0] Xplayer;
	input [6:0] Yplayer;
	input firing;
	
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] Colour;
	output reg       plot   = 0;
	output reg       enable = 0;
	output reg 		  flying = 0;
	output reg		  shot = 0;
	
	reg [7:0] Xhold = 90;
	reg [6:0] Yhold = 80;
	reg [1:0] XDraw = 2'b00;
	reg [1:0] YDraw = 2'b00;
	
	
	localparam S_PREHOLD = 4'b0100,
				  S_HOLD    = 4'b0000,
				  S_B_CLEAR = 4'b0001,
				  S_B_UP_RIGHT  = 4'b0011,
				  S_B_UP_LEFT = 4'b0010,
				  S_B_DOWN_RIGHT  = 4'b0110,
				  S_B_DOWN_LEFT    = 4'b0111,
				  S_B_DRAW  = 4'b0101,
				  S_B_SHOT = 4'b1000,
				  S_B_ESCAPE = 4'b1001;
				  
	localparam HITBOX_LEN = 1'd4;
	
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
			
				S_B_UP_RIGHT: 
				begin
					if(Xin < 160)
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
					if(Xin < 160)
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
				
					if(Yin < 120)
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
						
					if(Yin < 120)
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				S_B_DRAW: // Draw
				begin
					if (Xhold <= Xplayer && Xhold + (HITBOX_LEN - 1) >= Xplayer &&  Yhold <= Yplayer && Yhold + (HITBOX_LEN - 1) >= Yplayer && firing)
						shot <= 1;
					Colour <= 3'b111;
				end
				
				S_B_SHOT: // Shot
				begin
					if(Yin > 0)
					begin
						Yhold <= Yin - 1;
						flying <= 1;
					end
					else
					begin
						flying <= 0;
						shot <= 0;
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