module Control(clk, reset_n, GO, KEY, Xin, Yin, Xout, Yout, Colour);
	input clk;
	input reset_n;
	input GO;
	input[3:0] KEY;
	input[7:0] Xin;
	input[6:0] Yin;
	
	output[7:0] Xout;
	output[6:0] Yout;
	output[2:0] Colour;
	
	wire LEFT = ~KEY[3];
	wire RIGHT = ~KEY[0];
	wire UP = ~KEY[2];
	wire DOWN = ~KEY[1];
	
	reg[7:0] interX;
	reg[6:0] interY;
	reg[7:0] Xout = 50;
	reg[6:0] Yout = 50;
	reg[2:0] Colour = 3'b000;
	reg[2:0] STATE = 3'b000;
	reg No_Repeat = 1;
	
	localparam S_HOLD = 3'b000,
				  S_CLEAN = 3'b001,
				  S_GET_POS = 3'b010,
				  S_SET_POS = 3'b011;
				  
	always @(posedge clk, negedge reset_n)
	begin
		if(~reset_n)
		begin
			Xout <= 50;
			Yout <= 50;
			Colour <= 3'b000;
			STATE <= 3'b000;
		end
		
		else if(GO && No_Repeat)
		begin
			case(STATE)
				S_HOLD:
				begin
					if(No_Repeat)
					begin
						No_Repeat <= 0;
						STATE <= S_GET_POS;
					end
				end
				
				S_GET_POS:
				begin				
					if(RIGHT == 1 && Xin < 160)
						interX <= Xin + 1;
					else if(LEFT == 1 && Xin > 0)
						interX <= Xin - 1;
					else
						interX <= Xin;
				
					if(UP == 1 && Yin > 0)
						interY <= Yin - 1;
					else if(DOWN == 1 && Yin < 120)
						interY <= Yin + 1;
					else
						interY <= Yin;
					
					if(interX != Xin || interY != Yin)
						STATE <= S_CLEAN;
					else
						STATE <= S_HOLD;
				end
				
				S_CLEAN:
				begin
					Colour <= 3'b000;
					STATE <= S_SET_POS;
				end
				
				S_SET_POS:
				begin
					Colour <= 3'b100;
					
					Xout <= interX;
					Yout <= interY;
					
					STATE <= S_HOLD;
				end
			endcase
		end
		
		else if(!GO)
			No_Repeat <= 1;
	end
endmodule
