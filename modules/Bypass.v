module DecodeBinEP(
    input [31:0] m_range,       
    input [31:0] m_value_in,
    input n_bin,
    output reg bin_out,                   
    output reg [31:0] m_value_out  
);

    wire [31:0] shifter_out1;
    wire [31:0] shifter_out2;
    wire [31:0] saida_subtrator;
    wire [31:0] saida_mux1;

    wire bin_out1;
    wire [31:0] muxValuenBin;

    // Instanciação de módulos
    shifter_left #(32) shifter (
        .data_in(m_value_in),
        .shift_amount(1),
        .data_out(shifter_out1)
    );

    shifter_left #(32) shifter2 (
        .data_in(m_range),
        .shift_amount(7),
        .data_out(shifter_out2)
    );

    comparador comp_bit1 (
        .a(shifter_out1),
        .b(shifter_out2),
        .out_comp(bin_out1)
    );

    unsigned_subtractor subtrator (
        .a(shifter_out1),
        .b(shifter_out2),
        .result(saida_subtrator)
    );

    mux2to1 muxValue (
        .a(saida_subtrator),
        .b(shifter_out1),
        .sel(bin_out1),
        .y(saida_mux1)
    );

//######################
    mux2to1 muxValuenBin (
        .a(saida_subtrator),
        .b(saida_mux1), // caso 0
        .sel(n_bin),
        .y(muxValuenBin)
    );

    mux2to1 muxBinnBin (
        .a(saida_subtrator),
        .b(bin_out1), // caso 0
        .sel(n_bin),
        .y(muxValuenBin)
    );

//######################

    // Lógica combinacional
    always @* begin

        bin_out = bin_out1;
        m_value_out = saida_mux1;
    end
endmodule