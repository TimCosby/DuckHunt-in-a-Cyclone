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
	
	wire resetn;
	wire clk;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] X;
	wire [6:0] Y;
	wire [3:0] ControlMovement;
	wire [2:0] ControlFiring;
	wire [1:0] RemainingShots;	
	wire writeEn;
	wire DelaySignal;
	wire GunShot;
	
	assign resetn  = ~SW[9];
	assign clk     = CLOCK_50;
	assign gunShot = SW[0];
	
	assign LEDR[0] = DelaySignal;
	//assign LEDR[4:1] = ControlMovement;
	assign LEDR[1] = KEY[0];
	assign LEDR[2] = KEY[1];
	assign LEDR[3] = KEY[2];
	assign LEDR[4] = KEY[3];
	assign LEDR[6:5] = RemainingShots;
	assign LEDR[9:7] = ControlFiring;
	
   RateDivider rd(
					.clk(clk), 
					.reset_n(resetn), 
					.enable(DelaySignal)
	);
	
	MovementFSM mfsm0(
					.clk(clk),
					.reset_n(resetn),
					.KEY(KEY),
					.STATE(ControlMovement),
					.doneDrawing(nextState),
					.delayedClk(DelaySignal)
	);
	
	MovementDatapath mdp0(
							.clk(clk), 
							.reset_n(resetn), 
							.control(ControlMovement), 
							.Xin(X), 
							.Xout(X), 
							.Yin(Y), 
							.Yout(Y), 
							.Colour(colour), 
							.plot(writeEn),
							.enable(nextState)
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
						.RemainingShots(RemainingShots)
	);
	
	seg7display(
				.HEX(HEX0),
				.SW({2'b00, RemainingShots})
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
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule