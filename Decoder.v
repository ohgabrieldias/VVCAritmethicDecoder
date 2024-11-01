module Decoder(
    input clk,               // Clock
    input reset,             // Reset assíncrono
    input bypass,            // Flag para selecionar o módulo de saída
    input [7:0] data,        // Byte solicitado
    input n_bin,             // Número de bins a serem decodificados
    output reg [1:0] bin,               // Saída do bit decodificado do BinDecoderBase
    output reg [6:0] clock_cycle_count, // Contador de ciclos de clock
    output wire request_byte         // Sinal para incrementar a requisição
);

    reg signed [3:0] m_bitsNeeded;  // Bits necessários para leitura de byte (int3)
    reg [8:0] m_range;              // Intervalo global (uint32)
    reg [15:0] m_value;              // Valor global para decodificação (uint32)

    wire [1:0] bin_out_binEP; // Saída do módulo BinDecoderBase
    
    wire [15:0] m_value_out_binEP;           // Saída atualizada para m_value
    wire [15:0] m_value_out;           // Saída atualizada para m_value

    wire [3:0] m_bitsNeeded_out; 

    wire [15:0] saida_adderData;           // Saída atualizada para m_value

    wire signed [3:0] saida_adder1;
   
    adder #(4) adder1 (
        .a(m_bitsNeeded),
        .b(4'd1),
        .result(saida_adder1)
    );

    comparadorS comp_bit1 (
        .a(saida_adder1),
        .b(4'd0),
        .out_comp(request_byte)
    );

    adder_16_8 adderData (
        .a(m_value_out_binEP),
        .b(data),
        .result(saida_adderData)
    );

    mux2to1 muxValue (
        .a(saida_adderData),
        .b(m_value_out_binEP),
        .sel(request_byte),
        .y(m_value_out)
    );

      mux2to1 muxBits (
        .a(-4'd8),
        .b(saida_adder1),
        .sel(request_byte),
        .y(m_bitsNeeded_out)
    );

    DecodeBinEP decodeBinEP (
        .m_range(m_range),
        .m_value_in(m_value),
        .m_value_out(m_value_out_binEP),
        .bin_out(bin_out_binEP),
        .n_bin(n_bin)
    );

    always @bypass begin
        clock_cycle_count <= 0;
    end

    // Inicializações específicas no reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m_range <= 9'd289;          // Inicializa m_range com 289
            m_bitsNeeded <= -4'd8;      // Inicializa m_bitsNeeded com -8
            m_value <= 16'd36049;        // Inicializa m_value com 36049
            clock_cycle_count <= 0;        // Reseta o contador de ciclos de clock
            bin <= 1'b1;                // Inicializa bin como 1

        end else begin
            // Atualizações apenas quando não estiver em bypass
            if (~bypass) begin
                m_bitsNeeded <= m_bitsNeeded_out; // Atualiza com o novo valor
                m_value <= m_value_out_binEP;           // Atualiza com o novo valor
                bin <= bin_out_binEP;
                //request_byte <= request_byte;
            end
            clock_cycle_count <= clock_cycle_count + 1; // Incrementa o contador a cada ciclo de clock
        end
    end
endmodule
