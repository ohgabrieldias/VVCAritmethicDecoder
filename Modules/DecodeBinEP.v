module DecodeBinEP(
    input signed [3:0] m_bitsNeeded, // Bits necessários, global
    input [31:0] m_range,             // Intervalo global
    input [31:0] m_value,             // Valor global para decodificação
    output reg bin,                   // Resultado decodificado
    input enable,                     // Sinal de habilitação
    output reg signed [3:0] new_bitsNeeded,  // Novo valor para bitsNeeded
    output reg [31:0] new_range,      // Novo valor para range
    output reg [31:0] new_value,              // Byte lido
    input [7:0] data,                 // Dado lido
    output wire request_byte         // Sinal para incrementar a requisição
);

    // Declarações internas
    reg [7:0] byteLido;               // Armazena o byte lido
    reg [31:0] scaledRange;           // Intervalo escalado

    assign request_byte = (new_bitsNeeded + 1 >= 0) ? 1'b1 : 1'b0;

    // Lógica combinacional
    always @* begin
        // Condições iniciais
        bin = 0;                        // Inicializa bin como 0
        new_bitsNeeded = m_bitsNeeded;  // Inicializa new_bitsNeeded
        new_range = m_range;            // Inicializa new_range
        new_value = m_value;            // Inicializa new_value
        scaledRange = m_range << 7;     // Escalando o intervalo

        if (enable) begin
            // Duplicação de m_value
            new_value = new_value << 1; // Desloca new_value para a esquerda

            // Verificação de incremento de m_bitsNeeded e leitura de byte
            if (new_bitsNeeded + 1 >= 0) begin
                byteLido = data; // Função para ler byte do fluxo

                // Atualização de new_value e new_bitsNeeded
                new_value = new_value + byteLido;
                new_bitsNeeded = -8; // Essa linha deve ser tratada de outra forma
                // assign request_byte = 0; // Desativa a requisição
            end else begin
                new_bitsNeeded = new_bitsNeeded + 1; // Essa linha deve ser tratada de outra forma
            end

            // Ajuste de bin com base em new_value
            if (new_value >= scaledRange) begin
                new_value = new_value - scaledRange;
                bin = 1;
            end else begin
                bin = 0;
            end
        end
    end
endmodule