module MovementDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input [7:0] Xin;
	input [6:0] Yin;
	
	output reg [7:0] Xout = 50;
	output reg [6:0] Yout = 50;
	output reg [2:0] Colour = 3'b100;
	output reg       plot   = 0;
	output reg       enable = 0;
	
	reg       reset;
	reg [7:0] Xhold;
	reg [6:0] Yhold;
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
					if(Xin > 0)
						Xhold <= Xhold - 1;
					else
						Xhold <= Xhold;
				end
				
				S_P_RIGHT: 
				begin
					if(Xin < 158) // Max width
						Xhold <= Xhold + 1;
					else
						Xhold <= Xhold;
				end
				
				S_P_DOWN:
				begin
					if(Yin < 117) // Max height
						Yhold <= Yhold + 1;
					else
						Yhold <= Yhold;
				end
				
				S_P_UP: // UP
				begin
					if(Yin > 0)
						Yhold <= Yhold - 1;
					else
						Yhold <= Yhold;
				end
				
				S_P_DRAW: // Draw
				begin
					Colour <= 3'b100;
				end
			endcase
			
			if(control == S_P_CLEAR || control == S_P_DRAW)
			begin
				enable <= 0;
				plot <= 1;
				if(drawCounter == 2'b00)
				begin
					Xout <= Xhold + 1;
					Yout <= Yhold;
				end
				
				else if(drawCounter == 2'b01)
				begin
					Xout <= Xhold;
					Yout <= Yhold + 1;
				end
				
				else if(drawCounter == 2'b10)
				begin
					Xout <= Xhold + 2;
					Yout <= Yhold + 1;
				end
				
				else if(drawCounter == 2'b11)
				begin
					Xout <= Xhold + 1;
					Yout <= Yhold + 2;
					enable <= 1;
				
					if(reset && control == S_P_CLEAR)
					begin
						Xhold  <= 50;
						Yhold  <= 50;
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
