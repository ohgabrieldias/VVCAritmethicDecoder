module Decoder #(parameter BIN_WIDTH = 1)(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    input [7:0] pState_in,   // Estado do codificador

    input [15:0] m_value_binRE_in,
    input [16:0] m_value_binEP0_in,

    output wire [BIN_WIDTH - 1:0] bin,   // Saída do bit decodificado do BinDecoderBase
    output wire [15:0] m_value_binRE_out,     //revisar!!!!!!!
    output wire [16:0] m_value_binEP0_out,

    output wire [2:0] numBits,                 // Deslocamento do bitstream obtido pelo ROM
    output wire mps_renorm,
    output wire lps
);

// ######################## REGISTERS ########################
    reg [8:0] m_range;              // Intervalo global (uint32)
    reg [15:0] m_value;              // Valor global para decodificação (uint32)

// ######################## WIRES ############################
    wire [BIN_WIDTH - 1:0] bin_out_binEP;
    wire [BIN_WIDTH - 1:0] bin_out_bin;
    
    wire [15:0] m_value_out_binEP;           // Saída intermediaria shiftada << 1
    wire [15:0] m_value_out;              // Saída atualizada para m_value
    
    wire [8:0] m_range_out_bin;              // Saída atualizada para m_range
    wire [8:0] m_range_out;              // Saída atualizada para m_range     

// ######################## INSTANCES ########################
    DecodeBinEP #(BIN_WIDTH) decodeBinEP (
        .m_range(m_range),
        .m_value_in(m_value),
        .new_m_value_in0(m_value_binEP0_in),
        .m_value_out(m_value_out_binEP),
        .m_value0_out(m_value_binEP0_out),
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
        .m_value_out(m_value_binRE_out)
    );

    assign m_value_out = bypass ? m_value_out_binEP : m_value_binRE_in;
    assign bin = bypass ? bin_out_binEP : bin_out_bin;
    assign m_range_out = bypass ? m_range : m_range_out_bin;

    // Inicializações específicas no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_range <= 9'd510;          // Inicializa m_range com 510
            m_value <= 16'd36049;       // Inicializa m_value com 36049
        end else begin
            // Atualizações gerais
            m_value <= m_value_out;
            
            // Atualiza m_range apenas se não estiver em bypass
            if (!bypass) begin
                m_range <= m_range_out;
            end
        end
    end
endmodule
