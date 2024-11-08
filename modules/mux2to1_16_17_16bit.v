module mux2to1_16_17_16bit(
    input [15:0] a,
    input [16:0] b,
    input wire sel,
    output wire [15:0] y
);
    // Lógica do MUX: se sel é 0, y recebe b; se sel é 1, y recebe a
    assign y = sel ? a : b;
endmodule
