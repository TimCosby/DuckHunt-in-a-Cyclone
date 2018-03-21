module MovementDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable);
	input       clk;
	input       reset_n;
	input [3:0] control;
	input [7:0] Xin;
	input [6:0] Yin;
	
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] Colour = 3'b100;
	output reg       plot   = 0;
	output reg       enable = 0;
	
	reg [7:0] Xhold;
	reg [6:0] Yhold;
	reg [3:0] drawCounter = 4'b0000;
	
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
			Xhold  <= 50;
			Yhold  <= 50;
			Colour <= 3'b100;
		end
		
		else
		begin
			enable <= 0;
			
			case(control)
				S_P_CLEAR:
				begin
					Colour <= 3'b000;
				end
			
				S_P_LEFT: 
				begin
					if(Xin > 0)
						Xhold <= Xin - 1;
					else
						Xhold <= Xin;
				end
				
				S_P_RIGHT: 
				begin
					if(Xin < 160) // Max width
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
				end
				
				S_P_DOWN:
				begin
					if(Yin < 120) // Max height
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				S_P_UP: // UP
				begin
					if(Yin > 0)
						Yhold <= Yin - 1;
					else
						Yhold <= Yin;
				end
				
				S_P_DRAW: // Draw
				begin
					Colour <= 3'b100;
				end
			endcase
			
			if(control == S_P_CLEAR || control == S_P_DRAW)
			begin
				plot <= 1; // Allows VGA to display the current pixel
				
				Xout <= Xhold + drawCounter[1:0]; // Sets the current x pixel @ current draw + increment
				Yout <= Yhold + drawCounter[3:2]; // y pixel
				
				if(drawCounter == 4'b1111)
				begin
					enable <= 1; // Tell the FSM that we are done drawing.
					// (Don't plot <= 0 here because the last pixel still needs to be drawn first)
				end
				
				drawCounter <= drawCounter + 1; // Increase x increment
			end
			
			else
			begin
				plot   <= 0;
			end
		end
	end
endmodule