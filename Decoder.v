module Decoder #(parameter BIN_WIDTH = 1)(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    input [7:0] data,        // Byte solicitado
    input [7:0] pState_in,   // Estado do codificador
    
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
    
    wire [16:0] readByte0_out;

    wire [3:0] m_bitsNeeded_out;
    wire [3:0] m_bitsNeededRB_out;

    wire [8:0] m_range_out_bin;              // Saída atualizada para m_range
    wire [8:0] m_range_out;              // Saída atualizada para m_range

    wire lps, mps_renorm;
    wire [2:0] numBits;   // Deslocamento do bitstream obtido pelo ROM      

// ######################## INSTANCES ########################
    
    bitsNeeded bitsNeeded (
        .m_bitsNeeded(m_bitsNeeded),
        .numBits(numBits),
        .bypass(bypass),
        .lps(lps),
        .mps_renorm(mps_renorm),
        .request_byte(request_byte),
        .bitsNeeded_out(m_bitsNeeded_out),
        .bitsNeededRB_out(m_bitsNeededRB_out)
    );

    readByte readByte (
        .bitstream(data),
        .m_value_bin(m_value_out_bin),
        .m_value_binEP(m_value_shifted0),
        .bitsNeeded(m_bitsNeededRB_out),
        .flag(request_byte),
        .bitsNeeded_sel(m_bitsNeeded),
        .m_value_binRE_out(m_value_out_tmp),
        .m_value_binEP_out(readByte0_out)
    );

    DecodeBinEP #(BIN_WIDTH) decodeBinEP (
        .m_range(m_range),
        .m_value_in(m_value),
        .new_m_value_in0(readByte0_out),
        .m_value_out(m_value_out_binEP),
        .m_value0_out(m_value_shifted0),
        .bin_out(bin_out_binEP)
    );

    DecodeBin #(BIN_WIDTH) decodeBin (
        .m_range_in(m_range),
        .m_value_in(m_value),
        .pState_in(pState_in),
        .bin_out(bin_out_bin),
        .lps(lps),
        .mps_renorm(mps_renorm),
        .numBits_out(numBits),
        .m_range_out(m_range_out_bin),
        .m_value_out(m_value_out_bin)
    );

    assign muxValueOutBin_out = request_byte ? m_value_out_tmp : m_value_out_bin;
    assign m_value_out = bypass ? m_value_out_binEP : muxValueOutBin_out;
    assign bin = bypass ? bin_out_binEP : bin_out_bin;
    assign m_range_out = bypass ? m_range : m_range_out_bin;

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
