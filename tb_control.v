`timescale 1ns / 1ps

module tb_control;
    reg clk;            // Sinal de clock
    reg [7:0] byte;    // Byte lido do arquivo
    reg flag;          // MSB da flag
    reg [6:0] data;    // Dados (7 bits restantes)
    reg reset;             // Reset signal
    wire [6:0] uut_output; // Saída do uut
    wire bin_out; // Saída do módulo BinDecoderBase
    integer file;      // Handle do arquivo
    integer r;         // Variável para leitura do arquivo

    Decoder DECODER (
        .clk(clk),
        .reset(reset),
        .bypass(flag),
        .bin(bin_out),
        .clock_cycle_count(uut_output)
    );

    // Geração do sinal de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock com período de 10 unidades de tempo
    end

    initial begin
        reset = 1;
        #12; 
        reset = 0;

        // Abrir o arquivo binário
        file = $fopen("D:/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCAritmethicDecoder/DataProcessed/control.bin", "rb");
        if (file == 0) begin
            $display("Erro ao abrir o arquivo!");
            $finish;
        end

        // Loop de leitura do arquivo
        while (!$feof(file)) begin
            // Ler um byte do arquivo
            r = $fread(byte, file);
            if (r != 1) begin
                $display("Erro ao ler o byte!");
                $finish;
            end

            // Separar a flag e os dados
            flag = byte[7]; // MSB como flag
            data = byte[6:0]; // Restante dos bits

            // Atribuir a flag e os dados em um ciclo de clock
            @(posedge clk);
            // Atribuir flag e data
            // DECODER.bypass <= flag; 
            // DECODER.data <= data; 

            // Esperar enquanto o valor retornado do uut não corresponder
            while (uut_output != data) begin
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
