module Decoder(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    input [7:0] data,        // Byte solicitado
    input [7:0] pState_in,   // Estado do codificador
    input n_bin,             // Número de bins a serem decodificados
    output reg [1:0] bin,               // Saída do bit decodificado do BinDecoderBase
    output wire request_byte         // Sinal para incrementar a requisição
);

// ######################## REGISTERS ########################
    reg signed [3:0] m_bitsNeeded;  // Bits necessários para leitura de byte (int3)
    reg [8:0] m_range;              // Intervalo global (uint32)
    reg [15:0] m_value;              // Valor global para decodificação (uint32)
// ######################## WIRES ############################
    wire [1:0] bin_out_binEP;
    wire [1:0] bin_out_bin;
    wire [1:0] bin_out;
    
    wire [15:0] m_value_out_bin;              // Saída atualizada para m_value
    wire [15:0] m_value_out_binEP;           // Saída intermediaria shiftada << 1
    wire [15:0] m_value_out_tmp;              // Saída atualizada para m_value
    wire [15:0] muxValueOutBin_out;              // Saída atualizada para m_value

    wire [15:0] m_value_out;              // Saída atualizada para m_value

    wire [16:0] m_value_two;           // Saída intermediaria shiftada << 1
    wire [16:0] new_m_value_two;           // Saída atualizada para m_value

    wire [3:0] m_bitsNeeded_out; 

    wire [8:0] m_range_out_bin;              // Saída atualizada para m_range
    wire [8:0] m_range_out;              // Saída atualizada para m_range
// ######################## INSTANCES ########################
    wire mps_lps, mps_renorm;
    wire [2:0] numBits;

    bitsNeeded bitsNeeded (
        .m_bitsNeeded(m_bitsNeeded),
        .numBits(numBits),
        .bypass(bypass),
        .mps_lps(mps_lps),
        .mps_renorm(mps_renorm),
        .request_byte(request_byte),
        .bitsNeeded_out(m_bitsNeeded_out)
    );

    readByte readByte (
        .bitstream(data),
        .m_value_bin(m_value_out_bin),
        .m_value_binEP(m_value_two),
        .bitsNeeded(m_bitsNeeded_out),
        .flag(request_byte),
        .m_value_bin_out(m_value_out_tmp),
        .m_value_binEP_out(new_m_value_two)
    );

    DecodeBinEP decodeBinEP (
        .m_range(m_range),
        .m_value_in(m_value),
        .new_m_value_in(new_m_value_two),
        .m_value_out(m_value_out_binEP),
        .m_value_two_out(m_value_two),
        .bin_out(bin_out_binEP),
        .n_bin(n_bin)
    );

    DecodeBin decodeBin (
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

    mux2to1 #(2) muxBinOut (
        .a(bin_out_binEP),
        .b(bin_out_bin),
        .sel(bypass),
        .y(bin_out)
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
            m_range <= 9'd510;          // Inicializa m_range com 289
            m_bitsNeeded <= -4'd8;      // Inicializa m_bitsNeeded com -8
            m_value <= 16'd36049;        // Inicializa m_value com 36049
            bin <= 1'b1;                // Inicializa bin como 1

        end else begin
            // Atualizações apenas quando não estiver em bypass
            if (bypass) begin
                m_bitsNeeded <= m_bitsNeeded_out; // Atualiza com o novo valor
                m_value <= m_value_out;           // Atualiza com o novo valor
                bin <= bin_out;                
            end else begin
                m_bitsNeeded <= m_bitsNeeded_out; // Atualiza com o novo valor
                m_value <= m_value_out;           // Atualiza com o novo valor
                m_range <= m_range_out;           // Atualiza com o novo valor
                bin <= bin_out;                   // Atualiza com o novo valor
            end
            
        end
    end
endmodule
