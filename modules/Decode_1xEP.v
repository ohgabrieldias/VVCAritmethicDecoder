module Decode_1xEP(
    input wire [15:0] scaledRange,       
    input wire [15:0] m_value_in,
    input wire [16:0] new_m_value_in,
    
    output reg [16:0] value_shifted_out,
    output reg [15:0] m_value_out, 
    output reg bin_out
);

    always @(*) begin
        // Comparação
        bin_out = (new_m_value_in >= scaledRange);

        // Subtração
        if (bin_out)
            m_value_out = new_m_value_in - scaledRange;
        else
            m_value_out = new_m_value_in;

        // Shift Left
        value_shifted_out = m_value_in << 1;
    end

endmodule
