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

    output wire [15:0] m_value_bin_out,     //revisar!!!!!!!
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

    assign adderDataBinEP0_out = m_value_binEP0 + bitstream;
    assign adderDataBinEP1_out = m_value_binEP1 + bitstream;
    assign adderDataBinEP2_out = m_value_binEP2 + bitstream;
    assign adderDataBinEP3_out = m_value_binEP3 + bitstream;

    assign m_value_binEP0_out = (flag && (bitsNeeded_sel == -4'd1)) ? adderDataBinEP0_out : m_value_binEP0;
    assign m_value_binEP1_out = (flag && (bitsNeeded_sel == -4'd2)) ? adderDataBinEP1_out : m_value_binEP1;
    assign m_value_binEP2_out = (flag && (bitsNeeded_sel == -4'd3)) ? adderDataBinEP2_out : m_value_binEP2;
    assign m_value_binEP3_out = (flag && (bitsNeeded_sel == -4'd4)) ? adderDataBinEP3_out : m_value_binEP3;

    assign shifter_out = bitstream << bitsNeeded;
    assign m_value_bin_out = m_value_bin + shifter_out;

endmodule