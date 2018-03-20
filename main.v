/*
	SW9 = RESET - ON HIGH
   PLOTS ON LOW
*/

module main(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
		  HEX0,
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

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output  [9:0] LEDR;
	output  [6:0] HEX0;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] Colour;
	wire [7:0] X;
	wire [6:0] Y;
	wire writeEn;
	wire [3:0] ControlMovement;
	wire [2:0] ControlFiring;
	wire [1:0] RemainingShots;
	
	wire DelaySignal;
	wire MovementSignal;
	
	assign resetn = ~SW[9];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(Colour),
			.x(X),
			.y(Y),
			.plot(MovementSignal),
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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
   RateDivider rd(
					.clk(CLOCK_50), 
					.reset_n(resetn), 
					.enable(DelaySignal)
	);
	
	assign LEDR[0] = DelaySignal;
	assign LEDR[4:1] = ControlMovement;
	assign LEDR[6:5] = RemainingShots;
	assign LEDR[9:7] = ControlFiring;
	
	MovementFSM mfsm0(
					.clk(CLOCK_50),
					.reset_n(resetn),
					.KEY(KEY),
					.STATE(ControlMovement),
					.enableDraw(nextState),
					.enable(DelaySignal)
	);
	
	MovementDatapath mdp0(
							.clk(CLOCK_50), 
							.reset_n(resetn), 
							.control(ControlMovement), 
							.Xin(X), 
							.Xout(X), 
							.Yin(Y), 
							.Yout(Y), 
							.Colour(Colour), 
							.plot(MovementSignal),
							.enable(nextState)
	);
	
	
	FiringFSM ffsm0(
					.clk(CLOCK_50), 
					.reset_n(resetn), 
					.enable(SW[0]), 
					.STATE(ControlFiring)
	);
	
	FiringDatapath fdp0(
						.clk(CLOCK_50), 
						.reset_n(resetn), 
						.control(ControlFiring), 
						.RemainingShots(RemainingShots)
	);
	
	seg7display(
				.HEX(HEX0),
				.SW({2'b00, RemainingShots})
	);
	
endmodule
