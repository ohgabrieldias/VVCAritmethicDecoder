module DecodeBin (
    input [31:0] m_range,        // Faixa de probabilidade atual
    input [31:0] m_value,        // Valor atual
    input signed [3:0] m_bitsNeeded_in,
    input [7:0] pState_in,       // Intervalo LPS
    input [7:0] read_byte,                 // Dado lido

    output wire request_byte,         // Sinal para incrementar a requisição
    output reg decoded_bin,     // Bit decodificado de saída
    output reg [31:0] m_range_out, // Novo valor de m_range após a decodificação
    output reg [31:0] m_value_out, // Novo valor de m_value após a decodificação
    output reg signed [3:0] m_bitsNeeded_out // Novo valor de m_bitsNeeded após a decodificação
);
    // Variáveis internas
    reg bin;
    reg [15:0] scaledRange;
    reg signed [3:0] m_bitsNeeded;
    reg [31:0] range;

    reg [15:0] pState;
    reg [7:0] ivlLpsRange;  // Variável intermediária para o cálculo final
    reg [7:0] numBits;

    // Renormalization table with 32 entries
    RenormTableROM ROM (
        .addr(addr),         // Conectando o endereço de entrada ao sinal addr
        .data_out(data)      // Conectando a saída da ROM ao sinal data
    );

    assign request_byte = (m_bitsNeeded + 1 >= 0) ? 1'b1 : 1'b0;

    always @(*) begin
        // Verifica o bit mais significativo de q e aplica a operação XOR se necessário

        bin = pState_in >> 7;
        pState = pState_in;
        range = m_range;
        

        if (pState & 8'h80) begin
            pState = pState ^ 8'hFF;
        end

        ivlLpsRange = ((pState >> 2) * (range >> 5) >> 1) + 4;

        // Atualiza o intervalo removendo o LPS
        m_range_out = m_range - ivlLpsRange;
        scaledRange = m_range_out << 7; // Escala o novo m_range

        // Verifica o caminho MPS ou LPS
        if (m_value < scaledRange) begin
            // Caminho MPS
            decoded_bin = bin;
            
            // Checa a renormalização
            if (m_range_out < 32'd256) begin
                numBits = 1; // Calcula o número de bits necessários
                m_range_out = m_range_out << numBits;    // Renormaliza m_range
                m_value_out = (m_value << numBits);      // Renormaliza m_value
                m_bitsNeeded = m_bitsNeeded_in + numBits; // Atualiza m_bitsNeeded

                if (m_bitsNeeded + 1 >= 0) begin
                    m_value_out = read_byte << m_bitsNeeded_in;
                    m_bitsNeeded = -8; // Atualiza m_bitsNeeded
                end
            end else begin
                m_value_out = m_value; // Sem renormalização necessária
            end
        end else begin
            // Caminho LPS
            decoded_bin = ~bin;
            numBits = m_RenormTable_32[ivlLpsRange >> 3]; // Calcula o número de bits necessários
            // Atualiza m_value e m_range para o LPS
            m_value_out = (m_value - scaledRange) << numBits;
            m_range_out = ivlLpsRange << numBits;          // Ajusta m_range para o intervalo LPS

            if (m_bitsNeeded + 1 >= 0) begin
                m_value_out = read_byte << m_bitsNeeded_in;
                m_bitsNeeded = -8; // Atualiza m_bitsNeeded
            end

            m_bitsNeeded_out = m_bitsNeeded;
        end
    end
endmodule