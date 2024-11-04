module right_shift_3(
    input wire [7:0] in,
    output wire [4:0] out
);
    assign out = in >> 3;
endmodule