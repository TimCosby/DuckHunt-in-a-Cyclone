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
	output reg [2:0] Colour = 3'b100;
	output reg       plot   = 0;
	output reg       enable = 0;
	output reg		  leave = 0;
	
	reg       reset = 0;
	output reg [7:0] XPhold = 50;
	output reg [6:0] YPhold = 50;
	output reg [7:0] XBhold = 100;
	output reg signed [7:0] YBhold = 100;
	reg [1:0] drawCounter = 2'b00;
	reg [1:0] XBDraw = 2'b00;
	reg [1:0] YBDraw = 2'b00;
	
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
					Colour <= 3'b000;
				end
			
				S_P_LEFT: 
				begin
					if(PorB && XBhold > 2)
					begin
						leave <= 0;
						XBhold <= XBhold - 1;
					end
					else if(~PorB && XPhold > 2)
						XPhold <= XPhold - 1;
				end
				
				S_P_RIGHT: 
				begin
					if(PorB && XBhold < 158) // Max width
					begin
						leave <= 0;
						XBhold <= XBhold + 1;
					end
					else if(~PorB && XPhold < 158)
						XPhold <= XPhold + 1;
				end
				
				S_P_DOWN:
				begin
					if(PorB && YBhold < 117) // Max height
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
					if(PorB && fly && (YBhold + 4 == 0))
					begin
						leave <= 1;
						XBhold <= 80;
						YBhold <= 60;
						Colour <= 3'b111;
					end
					else if (PorB && fall && (YBhold > 121))
					begin
						leave <= 1;
						XBhold <= 80;
						YBhold <= 60;
						Colour <= 3'b111;
					end
					else if (PorB)
						Colour <= 3'b111;
					else
						Colour <= 3'b100;
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
			
			else if(PorB && (control == S_P_CLEAR || control == S_P_DRAW))
			begin
				enable <= 0;
				plot <= 1;
				
				Xout <= XBhold + XBDraw; 
				Yout <= YBhold + YBDraw;
				
				if(XBDraw == 2'b11)
				begin
					if(YBDraw == 2'b11)
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
				
			end
			else
			begin
				plot <= 0;
			end
		end
	end
endmodule
