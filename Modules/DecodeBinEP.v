module DecodeBinEP(
    input signed [3:0] m_bitsNeeded_in,
    input [31:0] m_range,       
    input [31:0] m_value_in,
    output reg bin_out,                   
    output reg signed [3:0] m_bitsNeeded_out,
    output reg [31:0] m_value_out,
    input [7:0] read_byte,                 // Dado lido
    output wire request_byte         // Sinal para incrementar a requisição
);

    // Declarações internas
    reg bin;
    reg [7:0] byteLido;               // Armazena o byte lido
    reg [31:0] m_value;
    reg [31:0] scaledRange;
    reg signed [3:0] m_bitsNeeded;

    assign request_byte = (m_bitsNeeded + 1 >= 0) ? 1'b1 : 1'b0;

    // Lógica combinacional
    always @* begin
        // Condições iniciais
        bin_out = 0;                        // Inicializa bin como 0
        m_bitsNeeded = m_bitsNeeded_in;  // Inicializa m_bitsNeeded_out
        m_value = m_value_in;            // Inicializa m_value
        scaledRange = m_range << 7;     // Escalando o intervalo

        // Duplicação de m_value
        m_value = m_value << 1; // Desloca m_value para a esquerda

        // Verificação de incremento de m_bitsNeeded e leitura de byte
        if (m_bitsNeeded + 1 >= 0) begin
            // Atualização de m_value e m_bitsNeeded_out
            m_value = m_value + read_byte;
            m_bitsNeeded = -8; // Essa linha deve ser tratada de outra forma
        end else begin
            m_bitsNeeded = m_bitsNeeded + 1; // Essa linha deve ser tratada de outra forma
        end

        // Ajuste de bin com base em m_value
        if (m_value >= scaledRange) begin
            m_value = m_value - scaledRange;
            bin = 1;
        end else begin
            bin = 0;
        end

        bin_out = bin;
        m_value_out = m_value;
        m_bitsNeeded_out = m_bitsNeeded;
    end
endmodule