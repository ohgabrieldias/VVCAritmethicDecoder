module add_4_3bit(
	input [3:0] a,
	input [2:0] b,

	output wire signed [3:0] result
);

	assign result = a + b;
endmodule