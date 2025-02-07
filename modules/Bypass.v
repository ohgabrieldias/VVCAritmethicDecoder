module DecodeBinEP #(parameter BIN_WIDTH = 4)(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in0,
    input [16:0] new_m_value_in1,
    input [16:0] new_m_value_in2,
    input [16:0] new_m_value_in3,
    input [1:0] n_bin,                  // bits a serem decodificados por ciclo
    output wire [BIN_WIDTH - 1:0] bin_out,
    output wire [16:0] m_value0_out,
    output wire [16:0] m_value1_out, 
    output wire [16:0] m_value2_out,
    output wire [16:0] m_value3_out,           
    output wire [15:0] m_value_out  
);

    wire [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    wire [15:0] m_value1;
    wire [15:0] m_value2;
    wire [15:0] m_value3;
    wire [15:0] m_value4;

    wire bin_out1;
    wire bin_out2;
    wire bin_out3;
    wire bin_out4;

    assign bin_out = (n_bin == 2'b00) ? {3'b000, bin_out1} :
        (n_bin == 2'b01) ? {2'b00, bin_out2, bin_out1} :
        (n_bin == 2'b10) ? {1'b0, bin_out3, bin_out2, bin_out1} :
        {bin_out4, bin_out3, bin_out2, bin_out1};

    // Instanciação de módulos
    lefth_shifter #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(16)) range_7s (
        .data_in(m_range),
        .shift_amount(3'd7),
        .data_out(scaledRange)
    );

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

    //##################### Quarto Bin
    Decode_1xEP decode4 (
        .scaledRange(scaledRange),
        .m_value_in(m_value3),
        .new_m_value_in(new_m_value_in3),
        .value_shifted_out(m_value3_out),
        .m_value_out(m_value4),
        .bin_out(bin_out4)
    );

    assign m_value_out = (n_bin == 2'b00) ? m_value1 :
        (n_bin == 2'b01) ? m_value2 :
        (n_bin == 2'b10) ? m_value3 : m_value4;

//######################
endmodule