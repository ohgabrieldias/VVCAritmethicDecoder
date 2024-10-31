module FileReader(
    input clk,
    input request,
    output reg [7:0] data,      // Saída com apenas 8 bits
    output reg data_ready
);
    integer file, r;
    reg [8:0] temp_data; // 9 bits para armazenar os dados lidos

    initial begin
        // Abre o arquivo no modo leitura binária
        file = $fopen("D:/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCAritmethicDecoder/data.bin", "rb");
        if (file == 0) begin
            $display("Erro ao abrir o arquivo.");
            $finish;
        end
        
        // Realiza a leitura inicial
        r = $fread(temp_data, file);
        if (r > 0) begin
            data = temp_data[7:0];  // Atribui apenas os 8 bits menos significativos
            data_ready = 1;         // Indica que os dados estão prontos
        end else begin
            data_ready = 0;         // Indica que não há dados disponíveis
        end
    end

    always @(posedge clk) begin
        // Realiza uma nova leitura somente se `request` estiver ativo
        if (request && data_ready) begin
            r = $fread(temp_data, file);
            if (r > 0) begin
                data <= temp_data[7:0];  // Atribui apenas os 8 bits menos significativos
            end else begin
                data_ready <= 0;         // Indica que não há mais dados
            end
        end
    end
endmodule
