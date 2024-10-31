module mux2to1 #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,       // Primeiro valor de entrada, 32 bits
    input [WIDTH-1:0] b,   // Segundo valor de entrada, 32 bits
    input wire sel,        // Sinal de seleção
    output wire [WIDTH-1:0] y          // Saída
);
    // Lógica do MUX: se sel é 0, y recebe b; se sel é 1, y recebe a
    assign y = sel ? a : b;
endmodule
