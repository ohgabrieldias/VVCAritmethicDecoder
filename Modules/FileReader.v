module FileReader(
    input clk,
    input request,
    output reg [8:0] data,
    output reg data_ready
);
    integer file, r;
    reg [8:0] temp_data; // 9 bits para armazenar os dados lidos

    initial begin
        // Abre o arquivo no modo leitura binária
        file = $fopen("D:/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/AritmethicDecoder/data.bin", "rb");
        if (file == 0) begin
            $display("Erro ao abrir o arquivo.");
            $finish;
        end
        data_ready = 0;
        data = 9'b0;
    end

    always @(posedge request) begin
        if (request) begin
            // Lê 2 bytes do arquivo binário (16 bits)
            r = $fread(temp_data, file);
            if (r > 0) begin
                data <= temp_data;    // Atribui o valor lido
                data_ready <= 1;      // Indica que os dados estão prontos
            end else begin
                data_ready <= 0;      // Indica que não há mais dados
            end
        end
    end
endmodule