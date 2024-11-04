module right_shift_7(
    input wire [7:0] in,
    output wire [1:0] out
);
    assign out = in >> 7;
endmodule
