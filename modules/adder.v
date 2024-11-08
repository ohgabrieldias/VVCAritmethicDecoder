module adder#(parameter WIDTH=16)
(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,

	output wire signed [WIDTH-1:0] result
);

	assign result = a + b;
endmodule