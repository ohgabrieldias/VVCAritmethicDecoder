module comparadorS (
    input signed [3:0] a,     // Primeiro valor de entrada, 32 bits, tipo signed
    input signed [3:0] b,            // Segundo valor de entrada, 32 bits, tipo unsigned
    output out_comp            // Saída: 1 se a >= b
);

    // Atribuição direta da comparação
    assign out_comp = (a >= b);

endmodule