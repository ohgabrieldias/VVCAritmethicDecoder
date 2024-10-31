module comparador (
    input [31:0] a,       // Primeiro valor de entrada, 32 bits
    input [31:0] b,   // Segundo valor de entrada, 32 bits
    output out_comp               // Saída: 1 se m_value >= scaledRange
);

    // Atribuição direta da comparação
    assign out_comp = (a >= b);

endmodule
