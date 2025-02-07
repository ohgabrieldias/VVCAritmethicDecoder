module Decoder #(parameter BIN_WIDTH = 4)(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    input [7:0] data,        // Byte solicitado
    input [7:0] pState_in,   // Estado do codificador
    input [1:0] n_bin,             // Número de bins a serem decodificados por ciclo
    output wire [BIN_WIDTH - 1:0] bin,   // Saída do bit decodificado do BinDecoderBase
    output wire request_byte         // Sinal para incrementar a requisição
);

// ######################## REGISTERS ########################
    reg signed [3:0] m_bitsNeeded;  // Bits necessários para leitura de byte (int3)
    reg [8:0] m_range;              // Intervalo global (uint32)
    reg [15:0] m_value;              // Valor global para decodificação (uint32)

// ######################## WIRES ############################
    wire [BIN_WIDTH - 1:0] bin_out_binEP;
    wire [BIN_WIDTH - 1:0] bin_out_bin;
    
    wire [15:0] m_value_out_bin;              // Saída atualizada para m_value
    wire [15:0] m_value_out_binEP;           // Saída intermediaria shiftada << 1
    wire [15:0] m_value_out_tmp;              // Saída atualizada para m_value
    wire [15:0] muxValueOutBin_out;              // Saída atualizada para m_value

    wire [15:0] m_value_out;              // Saída atualizada para m_value

    wire [16:0] m_value_shifted0;
    wire [16:0] m_value_shifted1;           // Saída intermediaria shiftada << 1
    wire [16:0] m_value_shifted2;
    wire [16:0] m_value_shifted3;
    
    wire [16:0] readByte0_out;
    wire [16:0] readByte1_out;           // Saída atualizada para m_value
    wire [16:0] readByte2_out;
    wire [16:0] readByte3_out;

    wire [3:0] m_bitsNeeded_out;
    wire [3:0] m_bitsNeededRB_out;

    wire [8:0] m_range_out_bin;              // Saída atualizada para m_range
    wire [8:0] m_range_out;              // Saída atualizada para m_range

    wire mps_lps, mps_renorm;
    wire [2:0] numBits;   // Deslocamento do bitstream obtido pelo ROM      

// ######################## INSTANCES ########################
    
    bitsNeeded bitsNeeded (
        .m_bitsNeeded(m_bitsNeeded),
        .numBits(numBits),
        .bypass(bypass),
        .nBin_in(n_bin),
        .mps_lps(mps_lps),
        .mps_renorm(mps_renorm),
        .request_byte(request_byte),
        .bitsNeeded_out(m_bitsNeeded_out),
        .bitsNeededRB_out(m_bitsNeededRB_out)
    );

    readByte readByte (
        .bitstream(data),
        .m_value_bin(m_value_out_bin),
        .m_value_binEP0(m_value_shifted0),
        .m_value_binEP1(m_value_shifted1),
        .m_value_binEP2(m_value_shifted2),
        .m_value_binEP3(m_value_shifted3),
        .bitsNeeded(m_bitsNeededRB_out),
        .flag(request_byte),
        .bitsNeeded_sel(m_bitsNeeded),
        .m_value_bin_out(m_value_out_tmp),
        .m_value_binEP0_out(readByte0_out),
        .m_value_binEP1_out(readByte1_out),
        .m_value_binEP2_out(readByte2_out),
        .m_value_binEP3_out(readByte3_out)
    );

    DecodeBinEP #(BIN_WIDTH) decodeBinEP (
        .m_range(m_range),
        .m_value_in(m_value),
        .new_m_value_in0(readByte0_out),
        .new_m_value_in1(readByte1_out),
        .new_m_value_in2(readByte2_out),
        .new_m_value_in3(readByte3_out),
        .m_value_out(m_value_out_binEP),
        .m_value0_out(m_value_shifted0),
        .m_value1_out(m_value_shifted1),
        .m_value2_out(m_value_shifted2),
        .m_value3_out(m_value_shifted3),
        .bin_out(bin_out_binEP),
        .n_bin(n_bin)
    );

    DecodeBin #(BIN_WIDTH) decodeBin (
        .m_range_in(m_range),
        .m_value_in(m_value),
        .pState_in(pState_in),
        .bin_out(bin_out_bin),
        .mps_lps(mps_lps),
        .mps_renorm(mps_renorm),
        .numBits_out(numBits),
        .m_range_out(m_range_out_bin),
        .m_value_out(m_value_out_bin)
    );

    mux2to1 #(16) muxValueOutBin (
        .a(m_value_out_tmp),
        .b(m_value_out_bin),
        .sel(request_byte),
        .y(muxValueOutBin_out)
    );

    mux2to1 #(16) muxValueOut (
        .a(m_value_out_binEP),
        .b(muxValueOutBin_out),
        .sel(bypass),
        .y(m_value_out)
    );

    mux2to1 #(BIN_WIDTH) muxBinOut (
        .a(bin_out_binEP),
        .b(bin_out_bin),
        .sel(bypass),
        .y(bin)
    );

    mux2to1 #(9) muxRangeOut (
        .a(m_range),
        .b(m_range_out_bin),
        .sel(bypass),
        .y(m_range_out)
    );

    // Inicializações específicas no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_range <= 9'd510;          // Inicializa m_range com 510
            m_bitsNeeded <= -4'd8;      // Inicializa m_bitsNeeded com -8
            m_value <= 16'd36049;       // Inicializa m_value com 36049
        end else begin
            // Atualizações gerais
            m_bitsNeeded <= m_bitsNeeded_out;
            m_value <= m_value_out;
            
            // Atualiza m_range apenas se não estiver em bypass
            if (!bypass) begin
                m_range <= m_range_out;
            end
        end
    end
endmodule
