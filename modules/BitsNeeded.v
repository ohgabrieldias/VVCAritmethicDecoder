module bitsNeeded(
    input signed [3:0] m_bitsNeeded,
    input [2:0] numBits, // bits para deslocamento do bitstream
    input [1:0] nBin_in,  // bits a serem decodificados
    input bypass,
    input mps_lps,
    input mps_renorm,
    output wire request_byte,
    output wire signed [3:0] bitsNeededRB_out,
    output wire signed [3:0] bitsNeeded_out
);
    wire [2:0] muxDecrement_out;
    wire [2:0] muxSumIndex_Out;
    wire signed [3:0] saida_adder1;
    wire signed [3:0] muxbitsNeeded1_out;
    wire signed [3:0] muxbitsNeeded2_out;
    wire signed [3:0] valueToBeReset;
    wire selmuxbitsNeeded2;
    wire comp_out;

    assign request_byte = (~bypass & ~selmuxbitsNeeded2) ? 0 : comp_out;
    assign valueToBeReset = saida_adder1 - 8;

    assign muxDecrement_out = (nBin_in == 2'b00) ? 3'd1 :
        (nBin_in == 2'b01) ? 3'd2 :
        (nBin_in == 2'b10) ? 3'd3 : 3'd4;

    assign muxSumIndex_Out = bypass ? muxDecrement_out : numBits;
   
    assign saida_adder1 = m_bitsNeeded + muxSumIndex_Out;
    assign bitsNeededRB_out = saida_adder1;

    assign comp_out = (saida_adder1 >= 0);
    assign muxbitsNeeded1_out = comp_out ? valueToBeReset : saida_adder1;
    assign selmuxbitsNeeded2 = (~mps_lps & ~mps_renorm) | mps_lps;  // inverte pq mps_lps e mps_renorm estao invertidos

    assign muxbitsNeeded2_out = selmuxbitsNeeded2 ? muxbitsNeeded1_out : m_bitsNeeded;
    assign bitsNeeded_out = bypass ? muxbitsNeeded1_out : muxbitsNeeded2_out;
    
endmodule