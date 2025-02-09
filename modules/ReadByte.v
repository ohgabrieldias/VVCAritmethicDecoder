module readByte(
    input [7:0] bitstream,
    input [15:0] m_value_bin,
    input [16:0] m_value_binEP0,
    input [16:0] m_value_binEP1,
    input [16:0] m_value_binEP2,
    input [16:0] m_value_binEP3,
    input signed [3:0] bitsNeeded_sel,
    input signed [3:0] bitsNeeded,
    input flag,

    output wire [15:0] m_value_binRE_out,     //revisar!!!!!!!
    output wire [16:0] m_value_binEP0_out,
    output wire [16:0] m_value_binEP1_out,
    output wire [16:0] m_value_binEP2_out,
    output wire [16:0] m_value_binEP3_out
);

    wire [16:0] adderDataBinEP1_out;           // Saída atualizada para m_value
    wire [16:0] adderDataBinEP0_out; 
    wire [16:0] adderDataBinEP2_out;
    wire [16:0] adderDataBinEP3_out;

    wire [15:0] shifter_out;           // Saída atualizada para m_value

    adder_17_8 adderDataBinEP0 (
        .a(m_value_binEP0),
        .b(bitstream),
        .result(adderDataBinEP0_out)
    );

    // mux2to1 #(17) muxValueBinEP0 (
    //     .a(adderDataBinEP0_out),
    //     .b(m_value_binEP0),
    //     .sel((flag & selOrderSum)),
    //     .y(m_value_binEP0_out)
    // );

    

    adder_17_8 adderDataBinEP1 (
        .a(m_value_binEP1),
        .b(bitstream),
        .result(adderDataBinEP1_out)
    );

    adder_17_8 adderDataBinEP2 (
        .a(m_value_binEP2),
        .b(bitstream),
        .result(adderDataBinEP2_out)
    );

    adder_17_8 adderDataBinEP3 (
        .a(m_value_binEP3),
        .b(bitstream),
        .result(adderDataBinEP3_out)
    );

    assign m_value_binEP0_out = (flag && (bitsNeeded_sel == -4'd1)) ? adderDataBinEP0_out : m_value_binEP0;
    assign m_value_binEP1_out = (flag && (bitsNeeded_sel == -4'd2)) ? adderDataBinEP1_out : m_value_binEP1;
    assign m_value_binEP2_out = (flag && (bitsNeeded_sel == -4'd3)) ? adderDataBinEP2_out : m_value_binEP2;
    assign m_value_binEP3_out = (flag && (bitsNeeded_sel == -4'd4)) ? adderDataBinEP3_out : m_value_binEP3;

    // mux2to1 #(17) muxValueBinEP1 (
    //     .a(adderDataBinEP1_out),
    //     .b(m_value_binEP1),
    //     .sel((flag & ~selOrderSum)),
    //     .y(m_value_binEP1_out)
    // );

    signed_left_shift shifterBin (
        .value_in(bitstream),
        .shift_amount(bitsNeeded),
        .value_out(shifter_out)
    );

    adder #(16) adderDataBin (
        .a(m_value_bin),
        .b(shifter_out),
        .result(m_value_binRE_out)
    );

endmodule