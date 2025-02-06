module right_shift_7#(parameter WIDTH = 4)(
    input wire [7:0] in,
    output wire [WIDTH - 1:0] out
);
    assign out = in >> 7;
endmodule
