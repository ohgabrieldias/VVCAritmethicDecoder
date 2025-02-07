module Decode_1xEP(
    input [15:0] scaledRange,       
    input [15:0] m_value_in,
    input [16:0] new_m_value_in,
    output wire [16:0] value_shifted_out,
    output wire [15:0] m_value_out, 
    output wire bin_out
);

wire [15:0] saida_subtrator1;
wire [15:0] saida_mux1;
wire saida_comp1;

comparator_16_17bit comp_bit1 (
    .a(new_m_value_in),
    .b(scaledRange),
    .out_comp(saida_comp1)
);

u_sub_17_16 subtrator (
    .a(new_m_value_in),
    .b(scaledRange),
    .result(saida_subtrator1)
);

lefth_shifter  value1_1s (
    .data_in(m_value_in),
    .shift_amount(3'd1),
    .data_out(value_shifted_out)
);

mux2to1_16_17_16bit muxValue1 (
    .a(saida_subtrator1),
    .b(new_m_value_in),
    .sel(saida_comp1),
    .y(saida_mux1)
);

assign m_value_out = saida_mux1;
assign bin_out = saida_comp1;

endmodule