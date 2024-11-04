module getLPS(
    input wire [7:0] state,
    input wire [8:0] range,  // Atualizado para 9 bits
    output wire [7:0] lps
);

    wire [15:0] q;
    wire [15:0] q_shifted;
    wire [8:0] range_shifted;  // Atualizado para 9 bits
    wire [15:0] mult_result;
    wire [15:0] add_result;

    // Instanciação dos módulos
    state_xor u_state_xor (
        .state(state),
        .q(q)
    );

    right_shift_2 u_right_shift_2 (
        .in(q),
        .out(q_shifted)
    );

    right_shift_5 u_right_shift_5 (
        .in(range),
        .out(range_shifted)
    );

    multiply u_multiply (
        .a(q_shifted),
        .b({7'b0, range_shifted}),  // Ajuste para promover range_shifted para 16 bits
        .result(mult_result)
    );

    right_shift_1 u_right_shift_1 (
        .in(mult_result),
        .out(add_result)
    );

    add_4 u_add_4 (
        .in(add_result[7:0]),  // Seleciona os 8 bits inferiores para manter o tamanho final em 8 bits
        .out(lps)
    );

endmodule