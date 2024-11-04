module right_shift_1(
    input wire [15:0] in,
    output wire [15:0] out
);
    assign out = in >> 1;
endmodule