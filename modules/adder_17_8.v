module adder_17_8 (
    input wire [16:0] a,       // Entrada de 17 bits
    input wire [7:0] b,        // Entrada de 8 bits
    output wire [16:0] result  // Saída de 17 bits
);

    // Extensão de zero para o valor de 8 bits para 17 bits e soma
    assign result = a + {9'b0, b};

endmodule
