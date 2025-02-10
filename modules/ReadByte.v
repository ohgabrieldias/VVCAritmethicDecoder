module readByte(
    input [7:0] bitstream,
    input [15:0] m_value_bin,
    input [16:0] m_value_binEP0,
    input [16:0] m_value_binEP1,
    input signed [3:0] bitsNeeded_sel,
    input signed [3:0] bitsNeeded,
    input flag,

    output reg [15:0] m_value_binRE_out,     //revisar!!!!!!!
    output reg [16:0] m_value_binEP0_out,
    output reg [16:0] m_value_binEP1_out
);

    reg [16:0] adderDataBinEP0_out; 
    reg [16:0] adderDataBinEP1_out;           // Saída atualizada para m_value

    reg [15:0] shifter_out;           // Saída atualizada para m_value

    always @* begin

        adderDataBinEP0_out = m_value_binEP0 + bitstream;
        adderDataBinEP1_out = m_value_binEP1 + bitstream;
        shifter_out = bitstream << bitsNeeded;

        m_value_binEP0_out = (flag && (bitsNeeded_sel == -4'd1)) ? adderDataBinEP0_out : m_value_binEP0;
        m_value_binEP1_out = (flag && (bitsNeeded_sel == -4'd2)) ? adderDataBinEP1_out : m_value_binEP1;
         m_value_binRE_out = m_value_bin + shifter_out;

    end
endmodule