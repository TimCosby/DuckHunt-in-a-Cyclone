module BirdDatapath(clk, reset_n, control, Xin, Xout, Yin, Yout, Colour, plot, enable, flying);
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
	output flying;
	
	reg[7:0] Xold = 80;
	reg[6:0] Yold = 90;
	reg[7:0] Xhold = 80;
	reg[6:0] Yhold = 90;
	reg[7:0] Xout = 80;
	reg[6:0] Yout = 90;
	reg[2:0] Colour = 3'b111;
	reg plot = 0;
	reg enable = 0;
	reg flying = 0;
	
	reg[1:0] XDraw = 2'b00;
	reg[1:0] YDraw = 2'b00;
	
	always @ (posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			Xold <= Xin;
			Yold <= Yin;
			Xout <= 80;
			Yout <= 90;
			Colour <= 3'b111;
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

					Colour <= 3'b111;
				end
				
				4'b0111: // Shot
				begin
					if(enable && Yin < 120)
					begin
						Yhold <= Yin + 1;
						flying <= 1;
					end
					else
						flying <= 0;
					if(enable && flying)
					begin
						enable <= 0;
						XDraw <= 2'b00;
						YDraw <= 2'b00;
						Yold <= Yhold;
					end

					Colour <= 3'b111;
				end
				
				4'b1000: // Escape
				begin
					if(enable && Yin > 0)
					begin
						Yhold <= Yin - 1;
						flying <= 1;
					end
					else
						flying <= 0;
					if(enable && flying)
					begin
						enable <= 0;
						XDraw <= 2'b00;
						YDraw <= 2'b00;
						Yold <= Yhold;
					end

					Colour <= 3'b111;
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
