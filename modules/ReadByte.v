module readByte(
    input [7:0] bitstream,
    input [15:0] m_value_bin,
    input [16:0] m_value_binEP0,
    input [16:0] m_value_binEP1,
    input selOrderSum,
    input signed [3:0] bitsNeeded,
    input flag,

    output wire [15:0] m_value_bin_out,     //revisar!!!!!!!
    output wire [16:0] m_value_binEP0_out,
    output wire [16:0] m_value_binEP1_out
);

    wire [16:0] adderDataBinEP1_out;           // Saída atualizada para m_value
    wire [16:0] adderDataBinEP0_out; 
    wire [15:0] shifter_out;           // Saída atualizada para m_value

    adder_17_8 adderDataBinEP0 (
        .a(m_value_binEP0),
        .b(bitstream),
        .result(adderDataBinEP0_out)
    );

    mux2to1 #(17) muxValueBinEP0 (
        .a(adderDataBinEP0_out),
        .b(m_value_binEP0),
        .sel((flag & ~selOrderSum)),
        .y(m_value_binEP0_out)
    );

    adder_17_8 adderDataBinEP1 (
        .a(m_value_binEP1),
        .b(bitstream),
        .result(adderDataBinEP1_out)
    );

    mux2to1 #(17) muxValueBinEP1 (
        .a(adderDataBinEP1_out),
        .b(m_value_binEP1),
        .sel((flag & selOrderSum)),
        .y(m_value_binEP1_out)
    );

    signed_left_shift shifterBin (
        .value_in(bitstream),
        .shift_amount(bitsNeeded),
        .value_out(shifter_out)
    );

    adder #(16) adderDataBin (
        .a(m_value_bin),
        .b(shifter_out),
        .result(m_value_bin_out)
    );

endmodule