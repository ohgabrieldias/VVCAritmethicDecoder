module adder_32_8 (
    input wire [31:0] a,      // Entrada de 32 bits
    input wire [7:0] b,       // Entrada de 8 bits
    output wire [31:0] result    // Saída de 32 bits
);

    // Extensão de sinal do valor de 8 bits para 32 bits e soma
    assign result = a + {{24{b[7]}}, b};

endmodule
