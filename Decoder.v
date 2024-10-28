`timescale 1ns / 1ps

module Decoder(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    output reg bin,               // Saída do bit decodificado do BinDecoderBase
    output reg [6:0] clock_cycle_count // Contador de ciclos de clock
);

    reg signed [3:0] m_bitsNeeded;  // Bits necessários para leitura de byte (int3)
    reg [31:0] m_range;              // Intervalo global (uint32)
    reg [31:0] m_value;              // Valor global para decodificação (uint32)

    wire bin_out_binEP; // Saída do módulo BinDecoderBase
    wire [3:0] m_bitsNeeded_out_binEP;       // Saída atualizada para m_bitsNeeded
    wire [31:0] m_value_out_binEP;           // Saída atualizada para m_value

    wire request_byte;          // Sinal para incrementar a requisição
    reg [7:0] byteLido = 8'b0;       // Byte lido do arquivo
    wire [8:0] data;
    wire data_ready;

    // Instanciação do módulo FileReader
    FileReader uut (
        .clk(clk),
        .request(request_byte),
        .data(data),
        .data_ready(data_ready)
    );

    DecodeBinEP decodeBinEP (
        .m_bitsNeeded_in(m_bitsNeeded),
        .m_range(m_range),
        .m_value_in(m_value),
        .m_bitsNeeded_out(m_bitsNeeded_out_binEP),
        .m_value_out(m_value_out_binEP),
        .bin_out(bin_out_binEP),
        .request_byte(request_byte),
        .read_byte(byteLido)
    );

    // assign bin = bin_out_binEP; // Conectar a saída do decodificador binário à saída do Decoder

    always @data begin
        if (request_byte) begin
            byteLido = data[7:0];
        end
    end

    always @bypass begin
        clock_cycle_count <= 0;
    end

    // Inicializações específicas no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_range <= 32'd289;          // Inicializa m_range com 289
            m_bitsNeeded <= -4'd8;      // Inicializa m_bitsNeeded com -8
            m_value <= 32'd36049;        // Inicializa m_value com 36049
            clock_cycle_count <= 0;        // Reseta o contador de ciclos de clock
            bin <= 1'b0;                // Inicializa bin como 0

        end else begin
            // Atualizações apenas quando não estiver em bypass
            if (~bypass) begin
                m_bitsNeeded <= m_bitsNeeded_out_binEP; // Atualiza com o novo valor
                m_value <= m_value_out_binEP;           // Atualiza com o novo valor
                bin <= bin_out_binEP;
            end
            clock_cycle_count <= clock_cycle_count + 1; // Incrementa o contador a cada ciclo de clock
        end
    end
endmodule
