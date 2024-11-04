module compador_16_17bit #(parameter WIDTH = 16)(
    input [WIDTH:0] a,       // Primeiro valor de entrada, 17 bits
    input [WIDTH -1:0] b,   // Segundo valor de entrada, 16 bits
    output out_comp               // Saída: 1 se m_value >= scaledRange
);

    // Atribuição direta da comparação
    assign out_comp = (a >= b);

endmodule