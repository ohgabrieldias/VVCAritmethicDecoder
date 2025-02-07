module DecodeBin  #(parameter BIN_WIDTH)(
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

    right_shift_7 #(BIN_WIDTH) getMPS (
        .in(pState_in),
        .out(bin)
    );
    
    getLPS getLPS (
        .state(pState_in),
        .range(m_range_in),
        .lps(ivlLpsRange)
    );

    subtractor_range sub (          // define o Range
        .in_a(m_range_in),
        .in_b(ivlLpsRange),
        .out(range_tmp)
    );

    lefth_shifter #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(16)) shifter (
        .data_in(range_tmp),
        .shift_amount(3'd7),
        .data_out(scaledRange)
    );

    comparator compPath (   // se o valor for >= range, output = 1, 0 significa MPS
        .a(m_value_in),
        .b(scaledRange),
        .out_comp(compPath_out)
    );                          // 0 MPS, 1 LPS

    assign mps_lps = compPath_out;

    assign inv_bin = ~bin;

    comparator #(9) compNumBits (       // se o range for >= 256, output = 1, 0 significa renormalização
        .a(range_tmp),
        .b(9'd256),
        .out_comp(compNumBits_out)
    );
    
    assign mps_renorm = compNumBits_out;
// #### MPS
    lefth_shifter #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(9)) shifter2 (
        .data_in(range_tmp),
        .shift_amount(numBits),
        .data_out(range_mps_renorm)
    );

    lefth_shifter #(.DATA_IN_WIDTH(16), .DATA_OUT_WIDTH(16)) shifter3 (
        .data_in(m_value_in),
        .shift_amount(numBits),
        .data_out(m_value_mps_renorm)
    );

    mux2to1 #(9) renormRangeMux (
        .a(range_tmp),
        .b(range_mps_renorm),
        .sel(compNumBits_out),
        .y(range_mps)
    );

    mux2to1 #(16) renormValueMux (
        .a(m_value_in),
        .b(m_value_mps_renorm),
        .sel(compNumBits_out),
        .y(m_value_mps)
    );

    right_shift_3 getROMIndex (
        .in(ivlLpsRange),
        .out(romIndex)
    );

    mux2to1 #(3) numBitsMux (
        .a(renormTableData),
        .b(3'd1),
        .sel(compPath_out),
        .y(numBits)
    );

    assign numBits_out = numBits;

    mux2to1 #(BIN_WIDTH) binMux (
        .a(inv_bin),
        .b(bin),
        .sel(compPath_out),
        .y(bin_out)
    );

// #### LPS
    u_subtractor #(16) subValue (
        .a(m_value_in),
        .b(scaledRange),
        .result(m_value_tmp)
    );

    lefth_shifter #(.DATA_IN_WIDTH(16), .DATA_OUT_WIDTH(16)) shifter4 (
        .data_in(m_value_tmp),
        .shift_amount(numBits),
        .data_out(m_value_lps)
    );

    lefth_shifter #(.DATA_IN_WIDTH(8), .DATA_OUT_WIDTH(9)) shifter5 (
        .data_in(ivlLpsRange),    // REVISAR - DEVERIA SER ILPSRANGE (ESTAVA RANGE_TMP)
        .shift_amount(numBits),
        .data_out(range_lps)
    );

    mux2to1 muxValueOut (
        .a(m_value_lps),
        .b(m_value_mps),
        .sel(compPath_out),
        .y(m_value_out)
    );

    mux2to1 #(9) muxRangeOut (
        .a(range_lps),
        .b(range_mps),
        .sel(compPath_out),
        .y(m_range_out)
    );
endmodule