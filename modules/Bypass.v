module DecodeBinEP(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in,
    input n_bin,
    output wire [1:0] bin_out,   
    output wire [16:0] m_value_two_out,                
    output wire [15:0] m_value_out  
);

    wire [16:0] value_shifted;
    wire [16:0] range_shifted;

    wire [15:0] saida_subtrator1;
    wire [15:0] saida_subtrator2;

    wire [15:0] saida_mux1;
    wire [15:0] saida_mux2;

    wire saida_comp1;
    wire saida_comp2;

    assign bin_out = n_bin ? {saida_comp1, saida_comp2} : {1'b0, saida_comp1};

    // assign bin_out = {1'b0, saida_comp1};

    // Instanciação de módulos
    shifter_left  shifter (
        .data_in(m_value_in),
        .shift_amount(1),
        .data_out(value_shifted)
    );

    shifter_left #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(17)) shifter2 (
        .data_in(m_range),
        .shift_amount(7),
        .data_out(range_shifted)
    );

    comparador comp_bit1 (
        .a(value_shifted),
        .b(range_shifted),
        .out_comp(saida_comp1)
    );

    unsigned_subtractor subtrator (
        .a(value_shifted),
        .b(range_shifted),
        .result(saida_subtrator1)
    );

    mux2to1 muxValue1 (
        .a(saida_subtrator1),
        .b(value_shifted),
        .sel(saida_comp1),
        .y(saida_mux1)
    );

//##################### Segundo Bin
   shifter_left  shifter3 (
        .data_in(saida_mux1),
        .shift_amount(1),
        .data_out(m_value_two_out)
    );

    // shifter_left #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(17)) shifter2 (
    //     .data_in(m_range),
    //     .shift_amount(7),
    //     .data_out(range_shifted)
    // );

    comparador comp_bit2 (
        .a(new_m_value_in),
        .b(range_shifted),
        .out_comp(saida_comp2)
    );

    unsigned_subtractor subtrator2 (
        .a(new_m_value_in),
        .b(range_shifted),
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

    // // Lógica combinacional
    // always @* begin

    //     // bin_out = bin_out;
    //     m_value_out = saida_mux1;
    // end
endmodule