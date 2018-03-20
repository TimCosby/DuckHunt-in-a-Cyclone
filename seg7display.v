module seg7display(HEX, SW);
    input [3:0] SW;
    output [6:0] HEX;
	 
	 assign c0 = SW[0];
	 assign c1 = SW[1];
	 assign c2 = SW[2];
	 assign c3 = SW[3];
	 
	 // Decides if segment 0 lights up
	 assign HEX[0] = ((~c1 & c0 & ~c3 & ~c2) | (~c1 & ~c0 & ~c3 & c2) | (~c1 & c0 & c3 & c2) | (c1 & c0 & c3 & ~c2));
	 assign HEX[1] = ~((~c3 & ~c2) | (c0 & c1 & ~c3) | (~c0 & ~c1 & ~c3) | (c0 & ~c1 & c3) | (~c0 & ~c2 & c3));
	 assign HEX[2] = ~((~c1 & c0) | (c3 & ~c2) | (~c1 & ~c3) | (c0 & ~c3) | (~c3 & c2));
	 assign HEX[3] = ((~c3 & c2 & ~c1 & ~c0) | (~c2 & ~c1 & c0) | (c2 & c1 & c0) | (c3 & ~c2 & c1 & ~c0));
	 assign HEX[4] = ((c0 & ~c3) | (~c1 & c2 & ~c3) | (c0 & ~c1 & ~c2));
	 assign HEX[5] = ((c3 & c2 & ~c1 & c0) | (~c3 & ~c2 & c0) | (~c3 & ~c2 & c1) | (~c3 & c1 & c0));
	 assign HEX[6] = ((~c3 & ~c2 & ~c1) | (c3 & c2 & ~c1 & ~c0) | (~c3 & c2 & c1 & c0));
endmodule