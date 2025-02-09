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
    assign q = (state[7]) ? ({8'b0, state} ^ 16'h00FF) : {8'b0, state};

    assign q_shifted = q >> 2;

    assign range_shifted = range >> 5;

    assign mult_result = q_shifted * {7'b0, range_shifted};  // Promovendo range_shifted para 16 bits

    assign add_result = mult_result >> 1;

    assign lps = add_result[7:0] + 4;

endmodule