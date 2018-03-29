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
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output		 VGA_CLK;   				//	VGA Clock
	output		 VGA_HS;					//	VGA H_SYNC
	output		 VGA_VS;					//	VGA V_SYNC
	output		 VGA_BLANK_N;				//	VGA BLANK
	output	 	 VGA_SYNC_N;				//	VGA SYNC
	output [9:0] VGA_R;   				//	VGA Red[9:0]
	output [9:0] VGA_G;	 				//	VGA Green[9:0]
	output [9:0] VGA_B;   				//	VGA Blue[9:0]

	wire [7:0] X;
	wire [6:0] Y;
	wire resetn;
	wire clk;
	wire [2:0] colour;
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
		
	assign resetn  = ~SW[9];
	assign clk     = CLOCK_50;
	assign gunShot = SW[0];
	
	assign LEDR[3:0] = ControlMovement;
	assign LEDR[5:4] = ControlFiring;
	assign LEDR[9] = isShot;
	
   RateDivider Pmove(
					.clk(clk), 
					.reset_n(resetn), 
					.enable(DelaySignal)
	);
		
	assign LEDR[7] = ControlMovement == 4'b1000;
	assign LEDR[8] = ControlMovement == 4'b1001;
	
	wire [3:0] score;
	reg [3:0] writeScore = 0;
	ram32x4 sc(.address(5'b00001),
					  .clock(clk),
					  .data(writeScore),
					  .wren(gunShot || ~resetn),
					  .q(score)
						);
						
	always @ (posedge clk, negedge resetn)
	begin
		if (~resetn)
			writeScore <= 0;
		else if (isShot)
			writeScore <= writeScore + 1;
		else if (RemainingShots == 0)
			writeScore <= writeScore - 1;
	end
	
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
					.RandY(KEY[1])
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
							.YPhold(YPlayer)
	);
	
	FiringFSM ffsm0(
					.clk(DelaySignal), 
					.reset_n(resetn),
					.gunShot(gunShot), 
					.STATE(ControlFiring)
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
						.isShot(isShot)
	);
	
	seg7display s0(
				.HEX(HEX0),
				.SW({2'b00, RemainingShots})
	);
	
	seg7display s1(
				.HEX(HEX2),
				.SW(score)
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
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black	.mif";
endmodule