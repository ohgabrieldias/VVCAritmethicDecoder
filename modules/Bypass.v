module DecodeBinEP(
    input [8:0] m_range,       
    input [15:0] m_value_in,
    input n_bin,
    output wire [1:0] bin_out,                   
    output reg [15:0] m_value_out  
);

    wire [16:0] shifter_out1;
    wire [16:0] shifter_out2;
    wire [15:0] saida_subtrator;
    wire [15:0] saida_mux1;

    // wire [1:0] bin_out;
    wire saida_comp1;
    wire [15:0] saida_muxValuenBin;
    wire [15:0] saida_muxValuenBin2;

    // assign result = {flag ? bit1 : 1'b0, saida_comp1};
    assign bin_out = {1'b0, saida_comp1};

    // Instanciação de módulos
    shifter_left  shifter (
        .data_in(m_value_in),
        .shift_amount(1),
        .data_out(shifter_out1)
    );

    shifter_left #(.DATA_IN_WIDTH(9), .DATA_OUT_WIDTH(17)) shifter2 (
        .data_in(m_range),
        .shift_amount(7),
        .data_out(shifter_out2)
    );

    comparador comp_bit1 (
        .a(shifter_out1),
        .b(shifter_out2),
        .out_comp(saida_comp1)
    );

    unsigned_subtractor subtrator (
        .a(shifter_out1),
        .b(shifter_out2),
        .result(saida_subtrator)
    );

    mux2to1 muxValue (
        .a(saida_subtrator),
        .b(shifter_out1),
        .sel(saida_comp1),
        .y(saida_mux1)
    );

//######################
    // mux2to1 muxValuenBin (
    //     .a(saida_subtrator),
    //     .b(saida_mux1), // caso 0
    //     .sel(n_bin),
    //     .y(saida_muxValuenBin)
    // );

    // mux2to1 #(2) muxBinnBin (
    //     .a(saida_subtrator),
    //     .b(bin_out), // caso 0
    //     .sel(n_bin),
    //     .y(saida_muxValuenBin2)
    // );

//######################

    // Lógica combinacional
    always @* begin

        // bin_out = bin_out;
        m_value_out = saida_mux1;
    end
endmodule