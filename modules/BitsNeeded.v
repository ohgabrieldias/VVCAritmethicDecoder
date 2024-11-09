module bitsNeeded(
    input signed [3:0] m_bitsNeeded,
    input [2:0] numBits,
    input nBin_in,
    input bypass,
    input mps_lps,
    input mps_renorm,
    output wire request_byte,
    output wire selOrderSum,
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
    assign selOrderSum = m_bitsNeeded[0];
    assign valueToBeReset = saida_adder1 - 8;

    mux2to1 #(3) muxDecrement (
        .a(3'd2),
        .b(3'd1),
        .sel(nBin_in),
        .y(muxDecrement_out)
    );

    mux2to1 #(3) muxSumIndex (
        .a(muxDecrement_out),
        .b(numBits),
        .sel(bypass),
        .y(muxSumIndex_Out)
    );

    add_4_3bit adder1 (
        .a(m_bitsNeeded),
        .b(muxSumIndex_Out),
        .result(saida_adder1)
    );

    assign bitsNeededRB_out = saida_adder1;

    s_comparator comp_bit1 (
        .a(saida_adder1),
        .b(4'd0),
        .out_comp(comp_out)
    );

    mux2to1 #(4) muxbitsNeeded1 (
        .a(valueToBeReset),
        .b(saida_adder1),
        .sel(comp_out),
        .y(muxbitsNeeded1_out)
    );

    assign selmuxbitsNeeded2 = (~mps_lps & ~mps_renorm) | mps_lps;  // inverte pq mps_lps e mps_renorm estao invertidos

    mux2to1 #(4) muxbitsNeeded2 (
        .a(muxbitsNeeded1_out),
        .b(m_bitsNeeded),
        .sel(selmuxbitsNeeded2),
        .y(muxbitsNeeded2_out)
    );

    mux2to1 #(4) muxbitsNeededOut (
        .a(muxbitsNeeded1_out),
        .b(muxbitsNeeded2_out),
        .sel(bypass),
        .y(bitsNeeded_out)
    );
    
endmodule