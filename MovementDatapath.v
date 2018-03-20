module MovementDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable);
	input clk;
	input reset_n;
	input[3:0] control;
	input[7:0] Xin;
	input[6:0] Yin;
	
	output[7:0] Xout;
	output[6:0] Yout;
	output[2:0] Colour;
	output plot;
	output enable;
	
	reg[7:0] Xold = 50;
	reg[6:0] Yold = 50;
	reg[7:0] Xhold = 50;
	reg[6:0] Yhold = 50;
	reg[7:0] Xout = 50;
	reg[6:0] Yout = 50;
	reg[2:0] Colour = 3'b100;
	reg plot = 0;
	reg enable = 0;
	
	reg[1:0] XDraw = 2'b00;
	reg[1:0] YDraw = 2'b00;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			Xold <= Xin;
			Yold <= Yin;
			Xout <= 50;
			Yout <= 50;
			Colour <= 3'b100;
			XDraw <= 2'b00;
			YDraw <= 2'b00;
		end
		
		else
		begin
			case(control)
				4'b0001: // Left
				begin
					if(Xin > 0)
						Xhold <= Xin - 1;
					else
						Xhold <= Xin;
				end
				
				4'b0010: // Right
				begin
					if(Xin < 160) // Max width
						Xhold <= Xin + 1;
					else
						Xhold <= Xin;
				end
				
				4'b0011: // UP
				begin
					if(Yin > 0)
						Yhold <= Yin - 1;
					else
						Yhold <= Yin;
				end
				
				4'b0100: // Down
				begin
					if(Yin < 120) // Max height
						Yhold <= Yin + 1;
					else
						Yhold <= Yin;
				end
				
				4'b0101: // Clear
				begin
					Colour <= 3'b000;
				end
				
				4'b0110: // Draw
				begin
					if(enable)
					begin
						enable <= 0;
						XDraw <= 2'b00;
						YDraw <= 2'b00;
						Xold <= Xhold;
						Yold <= Yhold;
					end

					Colour <= 3'b100;
				end
			endcase
			
			if(control == 4'b0101 || control == 4'b0110)
			begin
				plot <= 1;
				
				Xout <= Xold + XDraw;
				Yout <= Yold + YDraw;
				
				if(XDraw == 2'b11)
				begin
					if(YDraw == 2'b11)
					begin
						enable <= 1;
					end
					
					YDraw <= YDraw + 1;
				end
				
				XDraw <= XDraw + 1;
			end
			
			else
			begin
				enable <= 0;
				XDraw <= 2'b00;
				YDraw <= 2'b00;
				plot <= 0;
			end
		end
	end
endmodule
