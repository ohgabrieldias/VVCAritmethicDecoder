module RenormTableROM (
    input wire [4:0] addr,       // 5 bits para acessar 32 posições (0 a 31)
    output reg [2:0] data_out    // Saída de 3 bits para armazenar o valor lido
);

    // Bloco combinacional que define data_out com base em addr
    always @(*) begin
        case (addr)
            5'd0:  data_out = 3'd6;
            5'd1:  data_out = 3'd5;
            5'd2:  data_out = 3'd4;
            5'd3:  data_out = 3'd4;
            5'd4:  data_out = 3'd3;
            5'd5:  data_out = 3'd3;
            5'd6:  data_out = 3'd3;
            5'd7:  data_out = 3'd3;
            5'd8:  data_out = 3'd2;
            5'd9:  data_out = 3'd2;
            5'd10: data_out = 3'd2;
            5'd11: data_out = 3'd2;
            5'd12: data_out = 3'd2;
            5'd13: data_out = 3'd2;
            5'd14: data_out = 3'd2;
            5'd15: data_out = 3'd2;
            5'd16: data_out = 3'd1;
            5'd17: data_out = 3'd1;
            5'd18: data_out = 3'd1;
            5'd19: data_out = 3'd1;
            5'd20: data_out = 3'd1;
            5'd21: data_out = 3'd1;
            5'd22: data_out = 3'd1;
            5'd23: data_out = 3'd1;
            5'd24: data_out = 3'd1;
            5'd25: data_out = 3'd1;
            5'd26: data_out = 3'd1;
            5'd27: data_out = 3'd1;
            5'd28: data_out = 3'd1;
            5'd29: data_out = 3'd1;
            5'd30: data_out = 3'd1;
            5'd31: data_out = 3'd1;
            default: data_out = 3'd0;  // Valor padrão para segurança
        endcase
    end

endmodule