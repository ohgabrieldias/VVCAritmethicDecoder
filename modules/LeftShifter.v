module shifter_left #(parameter WIDTH = 8) (
    input wire [WIDTH-1:0] data_in,       // Entrada de dados
    input wire [2:0] shift_amount,         // Quantidade de deslocamento (3 bits para 0-7)
    output wire [WIDTH-1:0] data_out       // Saída de dados deslocada
);

    assign data_out = data_in << shift_amount;
endmodule