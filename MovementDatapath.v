module MovementDatapath(clk, reset_n, control, Xout, Yout, Colour, plot, enable, PorB, isShot, XBhold, YBhold, XPhold, YPhold, fly, fall, leave);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input       PorB;
	input 		isShot;
	input 		fly;
	input			fall;
	
	output reg [7:0] Xout = 50;
	output reg [6:0] Yout = 50;
	output reg [23:0] Colour = CROSSHAIR_COLOUR;
	output reg       plot   = 0;
	output reg       enable = 0;
	output reg		  leave = 0;
	
	reg       reset = 0;
	output reg [7:0] XPhold = 50;
	output reg [6:0] YPhold = 50;
	output reg [7:0] XBhold = 100;
	output reg signed [7:0] YBhold = 121;
	reg [1:0] drawCounter = 2'b00;
	reg [4:0] XBDraw = 5'b00000;
	reg [3:0] YBDraw = 4'b0000;
	
	localparam S_PREHOLD = 4'b0100,
				  S_HOLD    = 4'b0000,
				  S_P_CLEAR = 4'b0001,
				  S_P_LEFT  = 4'b0011,
				  S_P_RIGHT = 4'b0010,
				  S_P_DOWN  = 4'b0110,
				  S_P_UP    = 4'b0111,
				  S_P_DRAW  = 4'b0101;
			
	localparam HITBOX_X = 4'b1110,
				  HITBOX_Y = 4'b1001;
				  
				  
	localparam CROSSHAIR_RED    = 255,
				  CROSSHAIR_GREEN  = 0,
				  CROSSHAIR_BLUE   = 0,
				  BIRDBODY_RED     = 255,
				  BIRDBODY_GREEN   = 255,
				  BIRDBODY_BLUE    = 255,
				  BIRDBEAK_RED     = 230,
				  BIRDBEAK_GREEN   = 222,
				  BIRDBEAK_BLUE    = 0,
				  CROSSHAIR_COLOUR = (CROSSHAIR_RED*65536) + (CROSSHAIR_GREEN*256) + CROSSHAIR_BLUE,
				  BIRDBODY_COLOUR = (BIRDBODY_RED*65536) + (BIRDBODY_GREEN*256) + BIRDBODY_BLUE,
				  BIRDBEAK_COLOUR = (BIRDBEAK_RED*65536) + (BIRDBEAK_GREEN*256) + BIRDBEAK_BLUE,
				  BLACK_COLOUR     = 0;
	
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			reset <= 1;
			enable <= 0;
			drawCounter <= 2'b00;
			XBDraw  <= 2'b00;
			YBDraw  <= 2'b00;
			leave <= 0;
		end
		
		else
		begin
			case(control)
				S_P_CLEAR:
				begin
					Colour <= BLACK_COLOUR;
				end
			
				S_P_LEFT: 
				begin
					if(PorB && XBhold > 0)
					begin
						leave <= 0;
						XBhold <= XBhold - 1;
					end
					else if(~PorB && XPhold > 2)
						XPhold <= XPhold - 1;
				end
				
				S_P_RIGHT: 
				begin
					if(PorB && XBhold < 160 - (HITBOX_X - 1)) // Max width
					begin
						leave <= 0;
						XBhold <= XBhold + 1;
					end
					else if(~PorB && XPhold < 158)
						XPhold <= XPhold + 1;
				end
				
				S_P_DOWN:
				begin
					if(PorB && YBhold < 120 - (HITBOX_Y - 1)) // Max height
					begin
						leave <= 0;
						YBhold <= YBhold + 1;
					end
					else if(PorB && fall)
						YBhold <= YBhold + 1;
					else if(~PorB && YPhold < 117)
						YPhold <= YPhold + 1;
				end
				
				S_P_UP: // UP
				begin
					if(PorB && YBhold > 0)
					begin
						leave <= 0;
						YBhold <= YBhold - 1;
					end
					else if(PorB && fly)
						YBhold <= YBhold - 1;
					else if(~PorB && YPhold > 0)
						YPhold <= YPhold - 1;
				end
				
				S_P_DRAW: // Draw
				begin
					if(PorB && fly && (YBhold + 10 == 0))
					begin
						leave <= 1;
						XBhold <= 80;
						YBhold <= 121;
						Colour <= BIRDBODY_COLOUR;
					end
					else if (PorB && fall && (YBhold > 120))
					begin
						leave <= 1;
						XBhold <= 80;
						YBhold <= 121;
						Colour <= BIRDBODY_COLOUR;
					end
					else if (PorB)
						Colour <= BIRDBODY_COLOUR;
					else
						Colour <= CROSSHAIR_COLOUR;
				end
			endcase
			
			if(~PorB && (control == S_P_CLEAR || control == S_P_DRAW))
			begin
				enable <= 0;
				plot <= 1;
				if(drawCounter == 2'b00)
				begin
					Xout <= XPhold + 1;
					Yout <= YPhold;
				end
				
				else if(drawCounter == 2'b01)
				begin
					Xout <= XPhold;
					Yout <= YPhold + 1;
				end
				
				else if(drawCounter == 2'b10)
				begin
					Xout <= XPhold + 2;
					Yout <= YPhold + 1;
				end
				
				else if(drawCounter == 2'b11)
				begin
					Xout <= XPhold + 1;
					Yout <= YPhold + 2;
					enable <= 1;
				
					if(reset && control == S_P_CLEAR)
					begin
						XPhold  <= 50;
						YPhold  <= 50;
						reset <= 0;
					end
				end
				
				else
					plot <= 0;
					
				drawCounter <= drawCounter + 1;
			end
			
			else if(PorB && (control == S_P_CLEAR || control == S_P_DRAW)) // Bird
			begin
				enable <= 0;
				plot <= 1;
				
				Xout <= XBhold + XBDraw; 
				Yout <= YBhold + YBDraw;
				
				if(XBDraw == HITBOX_X)
				begin
					if(YBDraw == HITBOX_Y)
					begin
						enable <= 1;
							
						if(reset && control == S_P_CLEAR)
						begin
							XBhold  <= 80;
							YBhold  <= 60;
							reset <= 0;
						end
					end
					
					YBDraw <= YBDraw + 1;
				end
				
				XBDraw <= XBDraw + 1;
				
				if (control == S_P_DRAW) // Pick C
				begin
					if ((YBDraw == 1 || YBDraw == 2) && (XBDraw == 0 || XBDraw == 1 || XBDraw == 2))
						Colour <= BIRDBEAK_COLOUR;
					else if ((YBDraw == 6) && (XBDraw == 12 || XBDraw == 11))
						Colour <= BIRDBEAK_COLOUR;
					else if (YBDraw <= 3  && (XBDraw > 2 && XBDraw <= 5))
						Colour <= BIRDBODY_COLOUR;
					else if ((YBDraw > 2 && YBDraw <= 6) && (XBDraw > 6 && XBDraw <= 12))
						Colour <= BIRDBODY_COLOUR;
					else if ((YBDraw > 2 && YBDraw <= 5) && (XBDraw > 3 && XBDraw <= 13))
						Colour <= BIRDBODY_COLOUR;
					else if (YBDraw == 6 && (XBDraw == 5 || XBDraw == 6))
						Colour <= BIRDBODY_COLOUR;
					else if (YBDraw == 7 && (XBDraw > 6 && XBDraw <= 9))
						Colour <= BIRDBODY_COLOUR;
					else if (YBDraw == 8 && (XBDraw > 6 && XBDraw <= 8))
						Colour <= BIRDBODY_COLOUR;
					else
						Colour <= BLACK_COLOUR;
				end
				
			end
			else
			begin
				plot <= 0;
			end
		end
	end
endmodule
