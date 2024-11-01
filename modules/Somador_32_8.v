module adder_16_8 (
    input wire [15:0] a,      // Entrada de 15 bits
    input wire [7:0] b,       // Entrada de 8 bits
    output wire [15:0] result // Saída de 15 bits
);

    // Extensão de sinal do valor de 8 bits para 15 bits e soma
    assign result = a + {{8{b[7]}}, b};

endmodule