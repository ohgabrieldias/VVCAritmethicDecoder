module DecodeBin  #(parameter BIN_WIDTH = 4)(
    input [8:0] m_range_in,        // Faixa de probabilidade atual
    input [15:0] m_value_in,        // Valor atual
    input [7:0] pState_in,       // Intervalo LPS

    output wire [BIN_WIDTH - 1:0] bin_out,     // Bit decodificado de saída
    output wire mps_lps,          // Flag para selecionar o caminho MPS ou LPS
    output wire mps_renorm,       // Flag para selecionar o caminho MPS renormalizado
    output wire [2:0] numBits_out,    // Número de bits necessários para decodificação
    output wire [8:0] m_range_out, // Novo valor de m_range após a decodificação
    output wire [15:0] m_value_out // Novo valor de m_value após a decodificação
);
    // Variáveis internas
    wire compPath_out;
    wire [BIN_WIDTH - 1:0] inv_bin;
    wire [BIN_WIDTH - 1:0] bin;

    wire [7:0] ivlLpsRange;  // Variável intermediária para o cálculo final

    wire [15:0] scaledRange;

    wire [8:0] range_mps_renorm;    // Range para renormalização
    wire [15:0] m_value_mps_renorm; // Valor para renormalização

    wire [8:0] range_mps;
    wire [15:0] m_value_mps;

    wire [8:0] range_lps;
    wire [15:0] m_value_lps;

    wire [8:0] range_tmp;
    wire [15:0] m_value_tmp;

    wire compNumBits_out;
    wire [4:0] romIndex;            // 5 bits para endereçar a ROM de 32 posições
    wire [2:0] numBits;             // 3 bits pq os dados da ROM vão de 1 ate 6

    wire [2:0] renormTableData;

    RenormTableROM ROM (
        .addr(romIndex),         // Conectando o endereço de entrada ao sinal addr
        .data_out(renormTableData)      // Conectando a saída da ROM ao sinal data
    );
    
    assign bin = pState_in >> 7;

    getLPS getLPS (
        .state(pState_in),
        .range(m_range_in),
        .lps(ivlLpsRange)
    );

    assign range_tmp = m_range_in - ivlLpsRange;

    assign scaledRange = range_tmp << 7;

    assign compPath_out = (m_value_in >= scaledRange);
    assign mps_lps = compPath_out;
    assign inv_bin = ~bin;

    assign compNumBits_out = (range_tmp >= 256);
    
    assign mps_renorm = compNumBits_out;
// #### MPS
    assign range_mps_renorm = range_tmp << numBits;
    
    assign m_value_mps_renorm = m_value_in << numBits;
    assign range_mps = compNumBits_out ? range_tmp : range_mps_renorm;

    assign m_value_mps = compNumBits_out ? m_value_in : m_value_mps_renorm;

    assign romIndex = ivlLpsRange >> 3;

    assign numBits = compPath_out ? renormTableData : 3'd1;
    assign numBits_out = numBits;

    assign bin_out = compPath_out ? inv_bin : bin;

// #### LPS

    assign m_value_tmp = m_value_in - scaledRange;

    assign m_value_lps = m_value_tmp << numBits;

    assign range_lps = ivlLpsRange << numBits;

    assign m_value_out = compPath_out ? m_value_lps : m_value_mps;

    assign m_range_out = compPath_out ? range_lps : range_mps;
endmodule