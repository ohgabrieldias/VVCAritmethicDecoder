module DecodeBinEP #(parameter BIN_WIDTH = 4)(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in0,
    input [1:0] n_bin,                  // bits a serem decodificados por ciclo
    output wire [16:0] m_value0_out,         
    output reg [BIN_WIDTH - 1:0] bin_out,
    output reg [15:0] m_value_out  
);

    reg [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    wire [15:0] m_value1;

    wire bin_out1;

    // Instanciação de módulos

    // ##################### Primeiro Bin

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