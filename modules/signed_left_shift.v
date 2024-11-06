module signed_left_shift (
    input [7:0] value_in,            // valor a ser deslocado
    input signed [3:0] shift_amount, // valor signed de 4 bits
    output [15:0] value_out          // valor deslocado
);

    // Convertemos o valor signed para positivo usando um operador ternário para manter a lógica combinacional
    wire [3:0] abs_shift = (shift_amount < 0) ? -shift_amount : shift_amount;

    // Aplicamos o shift à esquerda usando o valor absoluto como quantidade de deslocamento
    assign value_out = value_in << abs_shift;

endmodule
