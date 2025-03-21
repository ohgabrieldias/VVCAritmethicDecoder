module DecodeBinEP #(parameter BIN_WIDTH = 1)(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in0,
    output wire [16:0] m_value0_out,         
    output wire [BIN_WIDTH - 1:0] bin_out,
    output wire [15:0] m_value_out  
);

    reg [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    // Instanciação de módulos

    Decode_1xEP decode1 (
        .scaledRange(scaledRange),
        .m_value_in(m_value_in),
        .new_m_value_in(new_m_value_in0),
        .value_shifted_out(m_value0_out),
        .m_value_out(m_value_out),
        .bin_out(bin_out)
    );

    always @(*) begin
        scaledRange = m_range << 7;
    end
endmodule