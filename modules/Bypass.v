module DecodeBinEP #(parameter BIN_WIDTH = 3)(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in0,
    input [16:0] new_m_value_in1,
    input [16:0] new_m_value_in2,
    input [1:0] n_bin,                  // bits a serem decodificados por ciclo
    output wire [16:0] m_value0_out,
    output wire [16:0] m_value1_out, 
    output wire [16:0] m_value2_out,
    output reg [BIN_WIDTH - 1:0] bin_out,
    output reg [15:0] m_value_out  
);

    reg [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    wire [15:0] m_value1;
    wire [15:0] m_value2;
    wire [15:0] m_value3;

    wire bin_out1;
    wire bin_out2;
    wire bin_out3;

    // Instanciação de módulos

    // ##################### Primeiro Bin

    Decode_1xEP decode1 (
        .scaledRange(scaledRange),
        .m_value_in(m_value_in),
        .new_m_value_in(new_m_value_in0),
        .value_shifted_out(m_value0_out),
        .m_value_out(m_value1),
        .bin_out(bin_out1)
    );

    //##################### Segundo Bin
    Decode_1xEP decode2 (
        .scaledRange(scaledRange),
        .m_value_in(m_value1),
        .new_m_value_in(new_m_value_in1),
        .value_shifted_out(m_value1_out),
        .m_value_out(m_value2),
        .bin_out(bin_out2)
    );
    
    //##################### Terceiro Bin
    Decode_1xEP decode3 (
        .scaledRange(scaledRange),
        .m_value_in(m_value2),
        .new_m_value_in(new_m_value_in2),
        .value_shifted_out(m_value2_out),
        .m_value_out(m_value3),
        .bin_out(bin_out3)
    );

    always @(*) begin

        scaledRange = m_range << 7;

        case (n_bin)
            2'b00: m_value_out = m_value1;
            2'b01: m_value_out = m_value2;
            2'b10: m_value_out = m_value3;
        endcase

        case (n_bin)
            2'b00: bin_out = {3'b00, bin_out1};
            2'b01: bin_out = {2'b0, bin_out2, bin_out1};
            2'b10: bin_out = {bin_out3, bin_out2, bin_out1};
        endcase
    end
endmodule