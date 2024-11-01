module unsigned_subtractor
#(parameter WIDTH=17)
(
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,

	output wire [WIDTH:0] result
);

	assign result = a - b;
endmodule