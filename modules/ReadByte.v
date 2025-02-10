module readByte(
    input [7:0] bitstream,
    input [15:0] m_value_bin,
    input [16:0] m_value_binEP,
    input signed [3:0] bitsNeeded_sel,
    input signed [3:0] bitsNeeded,
    input flag,

    output reg [15:0] m_value_binRE_out,     //revisar!!!!!!!
    output reg [16:0] m_value_binEP_out
);

    reg [16:0] adderDataBinEP0_out; 

    reg [15:0] shifter_out;           // Saída atualizada para m_value

    always @* begin

        adderDataBinEP0_out = m_value_binEP + bitstream;
 
        shifter_out = bitstream << bitsNeeded;

        m_value_binEP_out = (flag && (bitsNeeded_sel == -4'd1)) ? adderDataBinEP0_out : m_value_binEP;
        m_value_binRE_out = m_value_bin + shifter_out;

    end
endmodule