module bitsNeeded(
    input signed [3:0] m_bitsNeeded,
    input [2:0] numBits, // Bits para deslocamento do bitstream
    input [1:0] nBin_in, // Bits a serem decodificados
    input bypass,
    input lps,
    input mps_renorm,
    output reg request_byte,
    output reg signed [3:0] bitsNeededRB_out,
    output reg signed [3:0] bitsNeeded_out
);
    reg [2:0] muxDecrement_out;
    reg [2:0] muxSumIndex_Out;
    reg signed [3:0] saida_adder1;
    reg signed [3:0] muxbitsNeeded1_out;
    reg signed [3:0] muxbitsNeeded2_out;
    reg signed [3:0] valueToBeReset;
    reg selmuxbitsNeeded2;
    reg comp_out;

    always @* begin
        // Define decremento com base em nBin_in
        case (nBin_in)
            2'b00: muxDecrement_out = 3'd1;
            2'b01: muxDecrement_out = 3'd2;
            2'b10: muxDecrement_out = 3'd3;
            default: muxDecrement_out = 3'd3;
        endcase

        // Seleção do valor de soma
        muxSumIndex_Out = bypass ? muxDecrement_out : numBits;

        // Soma de bitsNeeded com o índice apropriado
        saida_adder1 = m_bitsNeeded + muxSumIndex_Out;
        bitsNeededRB_out = saida_adder1;

        // Comparação para resetar o valor se necessário
        comp_out = (saida_adder1 >= 0);
        valueToBeReset = saida_adder1 - 8;

        // Multiplexador para bitsNeeded1_out
        muxbitsNeeded1_out = comp_out ? valueToBeReset : saida_adder1;

        // Seleção do muxbitsNeeded2_out
        selmuxbitsNeeded2 = (~lps & ~mps_renorm) | lps;
        muxbitsNeeded2_out = selmuxbitsNeeded2 ? muxbitsNeeded1_out : m_bitsNeeded;

        // Definição da saída
        bitsNeeded_out = bypass ? muxbitsNeeded1_out : muxbitsNeeded2_out;

        // Definição de request_byte
        request_byte = (~bypass & ~selmuxbitsNeeded2) ? 0 : comp_out;
    end

endmodule