module MovementDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable);
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
	
	reg [7:0] Xhold = 50;
	reg [6:0] Yhold = 50;
	reg [1:0] XDraw = 2'b00;
	reg [1:0] YDraw = 2'b00;
	
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
			Xhold  <= Xin;
			Yhold  <= Yin;
			Xout   <= 50;
			Yout   <= 50;
			XDraw  <= 2'b00;
			YDraw  <= 2'b00;
			Colour <= 3'b100;
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