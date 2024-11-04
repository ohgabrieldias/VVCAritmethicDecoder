module u_sub_17_16 (
	input [16:0] a,
	input [15:0] b,

	output wire [15:0] result
);

	assign result = a - b;
endmodule