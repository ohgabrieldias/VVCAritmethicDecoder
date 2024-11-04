module subtractor_range(
    input wire [8:0] in_a,    // Entrada de 9 bits
    input wire [7:0] in_b,    // Entrada de 8 bits
    output wire [8:0] out     // Saída de 9 bits
);

    // Expande `in_b` para 9 bits, concatenando um 0 no bit mais significativo
    assign out = in_a - {1'b0, in_b};

endmodule
