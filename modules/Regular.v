module DecodeBin #(parameter BIN_WIDTH = 3)(
    input wire [8:0] m_range_in,       // Faixa de probabilidade atual
    input wire [15:0] m_value_in,      // Valor atual
    input wire [7:0] pState_in,        // Estado do modelo de probabilidade

    output reg [BIN_WIDTH - 1:0] bin_out,  // Bit decodificado de saída
    output reg lps,               // Flag para selecionar o caminho MPS ou LPS
    output reg mps_renorm,            // Flag para indicar normalização no caminho MPS
    output reg [2:0] numBits_out,      // Número de bits necessários para renormalização
    output reg [8:0] m_range_out,      // Novo valor de m_range após a decodificação
    output reg [15:0] m_value_out      // Novo valor de m_value após a decodificação
);

    // Variáveis internas
    wire [7:0] ivlLpsRange; // Saída do módulo getLPS
    wire [4:0] romIndex;    // Índice da ROM (5 bits)
    wire [2:0] renormTableData; // Saída da ROM

    reg [15:0] scaledRange; // Intervalo escalado
    reg [2:0] numBits;      // Número de bits para renormalização

    // Instância da ROM de renormalização
    RenormTableROM ROM (
        .addr(romIndex), 
        .data_out(renormTableData)
    );

    // Instância do módulo getLPS
    getLPS getLPS (
        .state(pState_in),
        .range(m_range_in),
        .lps(ivlLpsRange)
    );

    // Definição do índice da ROM
    assign romIndex = ivlLpsRange >> 3;

    always @(*) begin
        // Inicializa variáveis
        numBits = 1;
        mps_renorm = 1;     // renorm desativado
        lps = 0;        // MPS
        scaledRange = (m_range_in - ivlLpsRange) << 7;
        bin_out = pState_in >> 7; // Obtém MPS inicial
        m_range_out = m_range_in - ivlLpsRange;
        
        if (m_value_in >= scaledRange) begin
            // Caminho LPS
            numBits = renormTableData; // Número de bits da ROM
            m_value_out = (m_value_in - scaledRange) << numBits;
            m_range_out = ivlLpsRange << numBits;
            bin_out = ~bin_out; // Inversão do bit menos significativo
            lps = 1;
        end
        else begin
            // Caminho MPS
            m_value_out = m_value_in;

            if (m_range_out < 256) begin
                mps_renorm = 0;
                numBits = 1; // Normalização fixa para MPS
                m_range_out = m_range_out << numBits;
                m_value_out = m_value_in << numBits;
            end
        end

        numBits_out = numBits;
    end
endmodule
