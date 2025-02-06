module DecodeBinEP #(parameter WIDTH = 4)(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in0,
    input [16:0] new_m_value_in1,
    input [16:0] new_m_value_in2,
    input [16:0] new_m_value_in3,
    input [1:0] n_bin,                  // bits a serem decodificados
    output wire [WIDTH - 1:0] bin_out,
    output wire [16:0] m_value0_out,
    output wire [16:0] m_value1_out, 
    output wire [16:0] m_value2_out,
    output wire [16:0] m_value3_out,           
    output wire [15:0] m_value_out  
);

    wire [16:0] value_shifted;  // precisa ser 17 bits para não perder informação na hora do compador
    wire [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    wire [15:0] saida_subtrator1;
    wire [15:0] saida_subtrator2;
    wire [15:0] saida_subtrator3;
    wire [15:0] saida_subtrator4;

    wire [15:0] saida_mux1;
    wire [15:0] saida_mux2;
    wire [15:0] saida_mux3;
    wire [15:0] saida_mux4;

    wire saida_comp1;
    wire saida_comp2;
    wire saida_comp3;
    wire saida_comp4;

    assign bin_out = (n_bin == 2'b00) ? {3'b000, saida_comp1} :
        (n_bin == 2'b01) ? {2'b00, saida_comp2, saida_comp1} :
        (n_bin == 2'b10) ? {1'b0, saida_comp3, saida_comp2, saida_comp1} :
        {saida_comp4, saida_comp3, saida_comp2, saida_comp1};

    // Instanciação de módulos
    lefth_shifter  value1_1s (
        .data_in(m_value_in),
        .shift_amount(3'd1),
        .data_out(m_value0_out)
    );

    lefth_shifter #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(16)) range_7s (
        .data_in(m_range),
        .shift_amount(3'd7),
        .data_out(scaledRange)
    );

    comparator_16_17bit comp_bit1 (
        .a(new_m_value_in0),
        .b(scaledRange),
        .out_comp(saida_comp1)
    );

    u_sub_17_16 subtrator (
        .a(new_m_value_in0),
        .b(scaledRange),
        .result(saida_subtrator1)
    );

    mux2to1_16_17_16bit muxValue1 (
        .a(saida_subtrator1),
        .b(new_m_value_in0),
        .sel(saida_comp1),
        .y(saida_mux1)
    );

//##################### Segundo Bin
   lefth_shifter  value2_1s (
        .data_in(saida_mux1),
        .shift_amount(3'd1),
        .data_out(m_value1_out)
    );

    comparator_16_17bit comp_bit2 (
        .a(new_m_value_in1),
        .b(scaledRange),
        .out_comp(saida_comp2)
    );

    u_sub_17_16 subtrator2 (
        .a(new_m_value_in1),
        .b(scaledRange),
        .result(saida_subtrator2)
    );

    mux2to1_16_17_16bit muxValue2 (
        .a(saida_subtrator2),
        .b(new_m_value_in1),
        .sel(saida_comp2),
        .y(saida_mux2)
    );

// ##################### Terceiro Bin
    lefth_shifter  value3_1s (
        .data_in(saida_mux2),
        .shift_amount(3'd1),
        .data_out(m_value2_out)
    );

    comparator_16_17bit comp_bit3 (
        .a(new_m_value_in2),
        .b(scaledRange),
        .out_comp(saida_comp3)
    );

    u_sub_17_16 subtrator3 (
        .a(new_m_value_in2),
        .b(scaledRange),
        .result(saida_subtrator3)
    );

    mux2to1_16_17_16bit muxValue3 (
        .a(saida_subtrator3),
        .b(new_m_value_in2),
        .sel(saida_comp3),
        .y(saida_mux3)
    );

// ##################### Quarto Bin
    lefth_shifter  value4_1s (
        .data_in(saida_mux3),
        .shift_amount(3'd1),
        .data_out(m_value3_out)
    );

    comparator_16_17bit comp_bit4 (
        .a(new_m_value_in3),
        .b(scaledRange),
        .out_comp(saida_comp4)
    );

    u_sub_17_16 subtrator4 (
        .a(new_m_value_in3),
        .b(scaledRange),
        .result(saida_subtrator4)
    );

    mux2to1_16_17_16bit muxValue4 (
        .a(saida_subtrator4),
        .b(new_m_value_in3),
        .sel(saida_comp4),
        .y(saida_mux4)
    );

//######################
    // mux2to1 #(4) muxValuenBin (
    //     .a(saida_mux2),
    //     .b(saida_mux1), // caso 0
    //     .sel(n_bin),
    //     .y(m_value_out)
    // );

    assign m_value_out = (n_bin == 2'b00) ? saida_mux1 :
        (n_bin == 2'b01) ? saida_mux2 :
        (n_bin == 2'b10) ? saida_mux3 : saida_mux4;

//######################
endmodule