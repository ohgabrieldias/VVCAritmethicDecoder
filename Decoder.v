`timescale 1ns / 1ps

module Decoder(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    output bin               // Saída do bit decodificado do BinDecoderBase
);

    // Declarando os sinais como registradores globais com os tamanhos corretos
    reg signed [3:0] m_bitsNeeded;  // Bits necessários para leitura de byte (int3)
    reg [31:0] m_range;              // Intervalo global (uint32)
    reg [31:0] m_value;              // Valor global para decodificação (uint32)

    // Instanciação do módulo BinDecoderBase com os sinais globais
    wire bin_out; // Saída do módulo BinDecoderBase

    wire [3:0] new_bitsNeeded;       // Saída atualizada para m_bitsNeeded
    wire [31:0] new_range;           // Saída atualizada para m_range
    wire [31:0] new_value;           // Saída atualizada para m_value

    wire request_byte;          // Sinal para incrementar a requisição

    reg [7:0] byteLido = 8'b0;       // Byte lido do arquivo
    reg flag_bypass = 0;
    
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
        .m_bitsNeeded(m_bitsNeeded),
        .m_range(m_range),
        .m_value(m_value),
        .new_bitsNeeded(new_bitsNeeded),
        .new_range(new_range),
        .new_value(new_value),
        .bin(bin_out),
        .enable(~bypass),
        .request_byte(request_byte),
        .data(byteLido)
    );

    assign bin = bin_out; // Conectar a saída do decodificador binário à saída do Decoder


    always @data begin
        if (request_byte) begin
            byteLido = data[7:0];
            flag_bypass = data[8];
        end
    end

    // Inicializações específicas no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_range <= 32'd289;          // Inicializa m_range com 289
            m_bitsNeeded <= -4'd8;      // Inicializa m_bitsNeeded com -8
            m_value <= 32'd36049;        // Inicializa m_value com 36049
        end else begin
            // Atualizações apenas quando não estiver em bypass
            if (~bypass) begin
                m_bitsNeeded <= new_bitsNeeded; // Atualiza com o novo valor
                m_range <= new_range;           // Atualiza com o novo valor
                m_value <= new_value;           // Atualiza com o novo valor
            end
        end
    end
endmodule
