module FileReader_tb;

    // Sinais do testbench
    reg clk;
    reg request;
    wire [8:0] data;
    wire data_ready;
    reg [8:0] data_block [0:9];
    integer i; // Index variable for the loop

    // Instanciação do módulo FileReader
    FileReader uut (
        .clk(clk),
        .request(request),
        .data(data),
        .data_ready(data_ready)
    );

    // Geração do sinal de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // T período de clock de 10 unidades de tempo
    end

    // Processo para testar a leitura
    initial begin
        // Espera por um tempo para estabilizar
        #10;

        // Inicializa o request e data_block
        request = 0;
        for (i = 0; i < 10; i = i + 1) begin
            // Faz a solicitação de leitura
            request = 1;
            #10; // Espera um ciclo de clock
            request = 0; // Desativa o request
            
            // Espera para que os dados estejam prontos
            #10;

            // Verifica se os dados estão prontos e armazena
            if (data_ready) begin
                data_block[i] = data; // Armazena o dado lido
                $display("Leitura %0d: Dado lido: %b (Decimal: %0d)", i, data, data);
            end
        end

        // Finaliza a simulação após as leituras
        #10;
        $finish;
    end

endmodule
