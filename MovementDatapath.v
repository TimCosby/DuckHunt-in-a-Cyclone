module MovementDatapath(clk, reset_n, control, Xout, Yout, Colour, plot, enable, PorB);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input       PorB;
	
	output reg [7:0] Xout = 50;
	output reg [6:0] Yout = 50;
	output reg [2:0] Colour = 3'b100;
	output reg       plot   = 0;
	output reg       enable = 0;
	
	reg       reset = 0;
	reg [7:0] XPhold = 50;
	reg [6:0] YPhold = 50;
	reg [7:0] XBhold = 100;
	reg [6:0] YBhold = 100;
	reg [1:0] drawCounter = 2'b00;
	
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
						XBhold <= XBhold - 1;
					else if(~PorB && XPhold > 2)
						XPhold <= XPhold - 1;
				end
				
				S_P_RIGHT: 
				begin
					if(PorB && XBhold < 158) // Max width
						XBhold <= XBhold + 1;
					else if(~PorB && XPhold < 158)
						XPhold <= XPhold + 1;
				end
				
				S_P_DOWN:
				begin
					if(PorB && YBhold < 117) // Max height
						YBhold <= YBhold + 1;
					else if(~PorB && YPhold < 117)
						YPhold <= YPhold + 1;
				end
				
				S_P_UP: // UP
				begin
					if(PorB && YBhold > 0)
						YBhold <= YBhold - 1;
					else if(~PorB && YPhold > 0)
						YPhold <= YPhold - 1;
				end
				
				S_P_DRAW: // Draw
				begin
					if(PorB)
						Colour <= 3'b010;
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
				if(drawCounter == 2'b00)
				begin
					Xout <= XBhold + 1;
					Yout <= YBhold;
				end
				
				else if(drawCounter == 2'b01)
				begin
					Xout <= XBhold;
					Yout <= YBhold + 1;
				end
				
				else if(drawCounter == 2'b10)
				begin
					Xout <= XBhold + 2;
					Yout <= YBhold + 1;
				end
				
				else if(drawCounter == 2'b11)
				begin
					Xout <= XBhold + 1;
					Yout <= YBhold + 2;
					enable <= 1;
				
					if(reset && control == S_P_CLEAR)
					begin
						XBhold  <= 100;
						YBhold  <= 100;
						reset <= 0;
					end
				end
				
				else
					plot <= 0;
					
				drawCounter <= drawCounter + 1;
			end
			
			else
			begin
				plot <= 0;
			end
		end
	end
endmodule
