/*
	SW9 = RESET - ON HIGH
   PLOTS ON LOW
*/

module main(
		CLOCK_50,						//	On Board 50 MHz
      KEY,
      SW,
		LEDR,
		HEX0,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input	    	 CLOCK_50;				//	50 MHz
	input  [9:0] SW;
	input  [3:0] KEY;

	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output		 VGA_CLK;   				//	VGA Clock
	output		 VGA_HS;					//	VGA H_SYNC
	output		 VGA_VS;					//	VGA V_SYNC
	output		 VGA_BLANK_N;				//	VGA BLANK
	output	 	 VGA_SYNC_N;				//	VGA SYNC
	output [9:0] VGA_R;   				//	VGA Red[9:0]
	output [9:0] VGA_G;	 				//	VGA Green[9:0]
	output [9:0] VGA_B;   				//	VGA Blue[9:0]

	reg  [9:0] birds       = 10'b1111111111; 
	reg  [3:0] birdsAlive  = 0;
	reg  [3:0] birdsDead   = 0;
	reg  [13:0] score      = 0;
	reg gameOver = 0;
	
	wire [7:0] X;
	wire [6:0] Y;
	wire resetn;
	wire clk;
	wire [23:0] colour;
	wire [7:0] XPlayer;
	wire [7:0] XBird;
	wire [6:0] YPlayer;
	wire [6:0] YBird;
	wire [3:0] ControlMovement;
	wire [3:0] ControlBird;
	wire [2:0] ControlFiring;
	wire [1:0] RemainingShots;	
	wire       writeEn;
	wire       DelaySignal;
	wire       isShot;
	wire       PorB;
	wire       gunShot;
	wire 		  escape;
	wire [3:0] scoreTens;
	wire [3:0] scoreHundreds;
	wire [3:0] scoreThousands;
	
	assign resetn    = ~SW[9];
	assign clk       = CLOCK_50;
	assign gunShot   = SW[0];
	assign scoreOnes = score % 10;
	assign scoreTens = (score / 10) % 10;
	assign scoreHundreds = (score / 100) % 10;
	assign scoreThousands = (score / 1000) % 10;
	
	assign LEDR = birds;
	
	always @ (negedge resetn, posedge leave)
	begin
		if(~resetn)
		begin
			birds      <= 10'b1111111111;
			birdsAlive <= 0;
			birdsDead  <= 0;
			gameOver <= 0;
		end
		else if(leave)
		begin
			if(escape)
			begin
				birdsDead <= birdsDead + 1;
				if(score > 0)
					score <= score - 10;
			end
			else if(isShot)
			begin
				birds[birdsAlive + birdsDead] = 0;
				birdsAlive <= birdsAlive + 1;
				score <= score + 50;
			end
				
			if(birdsAlive + birdsDead == 9)
			begin
				if(birdsAlive >= birdsDead)
				begin
					birds      <= 10'b1111111111;
					birdsAlive <= 0;
					birdsDead  <= 0;
				end
			
				else
					gameOver <= 1;
			end
		end	
	end
	
	
   RateDivider Pmove(
					.clk(clk && ~gameOver), 
					.reset_n(resetn), 
					.enable(DelaySignal)
	);
	
	MovementFSM mfsm0( // Takes 14 ticks at most
					.clk(clk),
					.reset_n(resetn),
					.KEY(KEY),
					.STATE(ControlMovement),
					.doneDrawing(nextState),
					.delayedClk(DelaySignal),
					.isShot(isShot), 
					.outOfAmmo(~|RemainingShots), 
					.PorB(PorB), 
					.RandX(KEY[0]), 
					.RandY(KEY[1]),
					.escape(escape),
					.fly(fly), 
					.fall(fall), 
					.leave(leave),
					.rng(rng)
	);
	
	MovementDatapath mdp0(
							.clk(clk), 
							.reset_n(resetn), 
							.control(ControlMovement), 
							.Xout(X), 
							.Yout(Y), 
							.Colour(colour), 
							.plot(writeEn),
							.enable(nextState),
							.PorB(PorB),
							.isShot(isShot),
							.XBhold(XBird),
							.YBhold(YBird),
							.XPhold(XPlayer),
							.YPhold(YPlayer),
							.fly(fly), 
							.fall(fall), 
							.leave(leave)
	);
	
	FiringFSM ffsm0(
					.clk(DelaySignal), 
					.reset_n(resetn),
					.gunShot(gunShot), 
					.STATE(ControlFiring),
					.leave(leave)
	);
	
	FiringDatapath fdp0(
						.clk(DelaySignal), 
						.reset_n(resetn),
						.control(ControlFiring), 
						.RemainingShots(RemainingShots),
						.XBird(XBird),
						.YBird(YBird),
						.XPlayer(XPlayer),
						.YPlayer(YPlayer),
						.isShot(isShot),
						.escape(escape),
						.fly(fly),
						.fall(fall),
						.leave(leave)
	);
	
	seg7display s0(
				.HEX(HEX0),
				.SW({2'b00, RemainingShots})
	);
	
	seg7display s2(
				.HEX(HEX2),
				.SW(0)
	);
	
	seg7display s3(
				.HEX(HEX3),
				.SW(scoreTens)
	);
	
	seg7display s4(
				.HEX(HEX4),
				.SW(scoreHundreds)
	);

	seg7display s5(
				.HEX(HEX5),
				.SW(scoreThousands)
	);
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour),
			.x(X),
			.y(Y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule