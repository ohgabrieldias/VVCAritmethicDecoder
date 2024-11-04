module adder_16_8 (
    input wire [15:0] a,       // Entrada de 16 bits
    input wire [7:0] b,        // Entrada de 8 bits
    output wire [15:0] result  // Saída de 16 bits
);

    // Extensão de zero para o valor de 8 bits para 16 bits e soma
    assign result = a + {8'b0, b}; // Extende 'b' para 16 bits antes de somar

endmodule