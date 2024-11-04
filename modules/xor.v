module state_xor(
    input wire [7:0] state,
    output wire [15:0] q
);
    assign q = (state[7]) ? ({8'b0, state} ^ 16'h00FF) : {8'b0, state};
endmodule
