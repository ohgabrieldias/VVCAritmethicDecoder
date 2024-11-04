module readByte(
    input [7:0] bitstream,
    input [15:0] m_value_bin,
    input [16:0] m_value_binEP,
    input signed [3:0] bitsNeeded,
    input flag,

    output wire [15:0] m_value_bin_out,     //revisar!!!!!!!
    output wire [16:0] m_value_binEP_out
);

    wire [16:0] adderDataBinEP_out;           // Saída atualizada para m_value
    wire [7:0] shifter_out;           // Saída atualizada para m_value

    adder_17_8 adderDataBinEP (
        .a(m_value_binEP),
        .b(bitstream),
        .result(adderDataBinEP_out)
    );

    mux2to1 #(17) muxValueBinEP (
        .a(adderDataBinEP_out),
        .b(m_value_binEP),
        .sel(flag),
        .y(m_value_binEP_out)
    );

    signed_left_shift shifterBin (
        .value_in(bitstream),
        .shift_amount(bitsNeeded),
        .value_out(shifter_out)
    );

    adder_16_8 adderDataBin ( //revisar
        .a(m_value_bin),
        .b(shifter_out),
        .result(m_value_bin_out)
    );

endmodule