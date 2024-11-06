module FileReader(
    input clk,
    input request,
    output reg [7:0] data,      // Saída com apenas 8 bits
    output reg data_ready
);
    integer file, r;
    reg [7:0] temp_data;        // 8 bits para armazenar cada byte lido

    initial begin
        // Abre o arquivo no modo leitura binária
        file = $fopen("D:/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCAritmethicDecoder/DataProcessed/bytes.bin", "rb");
        if (file == 0) begin
            $display("Erro ao abrir o arquivo.");
            $finish;
        end
        
        // Realiza a leitura inicial
        r = $fread(temp_data, file);
        if (r > 0) begin
            data = temp_data;    // Atribui o byte lido à saída `data`
            data_ready = 1;      // Indica que os dados estão prontos
        end else begin
            data_ready = 0;      // Indica que não há dados disponíveis
        end
    end

    always @(posedge clk) begin
        // Realiza uma nova leitura somente se `request` estiver ativo e `data_ready` estiver alto
        if (request && data_ready) begin
            r = $fread(temp_data, file);
            if (r > 0) begin
                data <= temp_data;  // Atribui o byte lido à saída `data`
                data_ready <= 1;    // Mantém `data_ready` ativo se há mais dados
            end else begin
                data_ready <= 0;    // Indica que não há mais dados
                $fclose(file);      // Fecha o arquivo ao final da leitura
            end
        end
    end
endmodule

