module DecodeBinEP(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in,
    input n_bin,
    output wire [1:0] bin_out,   
    output wire [16:0] m_value_two_out,                
    output wire [15:0] m_value_out  
);

    wire [16:0] value_shifted;      // precisa ser 17 bits para não perder informação na hora do compador
    wire [15:0] scaledRange; // revisar 2^9 << 2^7 = 2^16	

    wire [15:0] saida_subtrator1;
    wire [15:0] saida_subtrator2;

    wire [15:0] saida_mux1;
    wire [15:0] saida_mux2;

    wire saida_comp1;
    wire saida_comp2;

    assign bin_out = n_bin ? {saida_comp1, saida_comp2} : {1'b0, saida_comp1};

    // assign bin_out = {1'b0, saida_comp1};

    // Instanciação de módulos
    lefth_shifter  value1_1s (
        .data_in(m_value_in),
        .shift_amount(3'd1),
        .data_out(value_shifted)
    );

    lefth_shifter #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(16)) range_7s (
        .data_in(m_range),
        .shift_amount(3'd7),
        .data_out(scaledRange)
    );

    compador_16_17bit comp_bit1 (
        .a(value_shifted),
        .b(scaledRange),
        .out_comp(saida_comp1)
    );

    u_sub_17_16 subtrator (
        .a(value_shifted),
        .b(scaledRange),
        .result(saida_subtrator1)
    );

    mux2to1 muxValue1 (
        .a(saida_subtrator1),
        .b(value_shifted),
        .sel(saida_comp1),
        .y(saida_mux1)
    );

//##################### Segundo Bin
   lefth_shifter  value2_1s (
        .data_in(saida_mux1),
        .shift_amount(3'd1),
        .data_out(m_value_two_out)
    );

    compador_16_17bit comp_bit2 (
        .a(new_m_value_in),
        .b(scaledRange),
        .out_comp(saida_comp2)
    );

    u_sub_17_16 subtrator2 (
        .a(new_m_value_in),
        .b(scaledRange),
        .result(saida_subtrator2)
    );

    mux2to1 muxValue2 (
        .a(saida_subtrator2),
        .b(new_m_value_in),
        .sel(saida_comp2),
        .y(saida_mux2)
    );

//######################
    mux2to1 muxValuenBin (
        .a(saida_mux2),
        .b(saida_mux1), // caso 0
        .sel(n_bin),
        .y(m_value_out)
    );

//######################
endmodule