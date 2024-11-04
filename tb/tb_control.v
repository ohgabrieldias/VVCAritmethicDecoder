`timescale 1ns / 1ps

module tb_control;
    reg clk;            // Sinal de clock
    reg [7:0] byte;    // Byte lido do arquivo
    reg [7:0] pState;  // Estado do decodificador
    reg [6:0] numBins;       // Número de bins a serem decodificados
    reg [6:0] count; // Contador de ciclos de clock
    reg bypass_flag;          // MSB da bypass_flag
    reg reset;             // Reset signal
    wire [6:0] uut_output; // Saída do uut
    wire [1:0] bin_out; // Saída do módulo BinDecoderBase
    wire request_byte; // Sinal para incrementar a requisição
    integer file;      // Handle do arquivo
    integer r;         // Variável para leitura do arquivo

    wire [7:0] data_wire;
    wire data_ready;
    reg n_bin;         // define quantos bin serão decodificados por ciclo

    Decoder DECODER (
        .clk(clk),
        .reset(reset),
        .bypass(bypass_flag),
        .bin(bin_out),
        .n_bin(n_bin),
        .data(data_wire),
        .pState_in(pState),
        .request_byte(request_byte)
    );

     // Instanciação do módulo FileReader
    FileReader READER (
        .clk(clk),
        .request(request_byte),
        .data(data_wire),
        .data_ready(data_ready)
    );

    // Geração do sinal de clock
    initial begin
        count = 0;
        clk = 0;
        forever #5 clk = ~clk; // Clock com período de 10 unidades de tempo
    end

    initial begin
        reset = 1;
        n_bin = 0;
        #7; 
        reset = 0;

        // Abrir o arquivo binário
        file = $fopen("D:/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCAritmethicDecoder/DataProcessed/saida.bin", "rb");
        if (file == 0) begin
            $display("Erro ao abrir o arquivo!");
            $finish;
        end

        // Loop de leitura do arquivo
        while (!$feof(file)) begin
            // Ler o primeiro byte do arquivo e armazená-lo em pState
            r = $fread(byte, file);
            if (r != 1) begin
                $display("Erro ao ler o byte!");
                $finish;
            end
            pState = byte; // Salvar o primeiro byte em pState

            // Ler o segundo byte do arquivo
            r = $fread(byte, file);
            if (r != 1) begin
                $display("Erro ao ler o segundo byte!");
                $finish;
            end

            // Separar a bypass_flag e os dados
            bypass_flag = byte[7]; // MSB como bypass_flag
            numBins = byte[6:0];   // Restante dos bits
            n_bin = ~byte[0];    // Define quantos bin serão decodificados por ciclo (0 = 1, 1 = 2)
            count = 0;
            // Atribuir a bypass_flag e os dados em um ciclo de clock
            @(posedge clk);
             count = count + 1;
            // Esperar enquanto o valor retornado do uut não corresponder
            while (count != numBins) begin
                @(posedge clk); // Esperar pelo próximo ciclo de clock
            end

            // Reiniciar o processo (se necessário, adicione lógica aqui)
        end

        // Fechar o arquivo
        $fclose(file);
        $display("Fim da leitura do arquivo.");
        $finish;

    end
endmodule
