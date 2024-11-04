module right_shift_2(
    input wire [15:0] in,
    output wire [15:0] out
);
    assign out = in >> 2;
endmodule
