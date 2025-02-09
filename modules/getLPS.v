module getLPS(
    input wire [7:0] state,
    input wire [8:0] range,  // Atualizado para 9 bits
    output reg [7:0] lps
);

    reg [15:0] q;
    reg [15:0] q_shifted;
    reg [8:0] range_shifted;
    reg [15:0] mult_result;
    reg [15:0] add_result;

    always @(*) begin
        // Lógica para q
        if (state[7]) 
            q = {8'b0, state} ^ 16'h00FF;
        else 
            q = {8'b0, state};

        // Shift Right de 2 bits
        q_shifted = q >> 2;

        // Shift Right de 5 bits
        range_shifted = range >> 5;

        // Multiplicação com promoção para 16 bits
        mult_result = q_shifted * {7'b0, range_shifted};

        // Shift Right de 1 bit
        add_result = mult_result >> 1;

        // Soma final
        lps = add_result[7:0] + 4;
    end

endmodule
