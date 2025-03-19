`timescale 1ns / 1ps

module tb_control #(parameter BIN_WIDTH = 3);
    reg clk;            // Clock signal
    reg [7:0] byte;     // Byte read from file
    reg [7:0] pState;   // Decoder state
    reg [6:0] numBins;  // Number of bins to decode
    reg [6:0] count;    // Clock cycle counter
    reg [32:0] count_line;
    reg bypass_flag;    // MSB of bypass_flag
    reg reset;          // Reset signal
    wire [BIN_WIDTH - 1:0] bin_out; // Output of the BinDecoderBase module
    reg request_byte;  // Signal to increment the request
    integer file;       // File handle for input
    integer output_file; // File handle for output
    integer r;          // Variable for file read
    integer i;
    wire [7:0] bitstream;
    wire data_ready;
    reg signed [3:0] m_bitsNeeded = -4'd8;
    reg [1:0] n_bin;          // Defines how many bins are decoded per cycle
    reg signed [3:0] index_uptd, old_index;


    // wire para atualizacao de m_value
    reg [15:0] ofst_binRE_updtd;
    reg [16:0] ofst_binEP0_updtd;
    reg [16:0] ofst_binEP1_updtd;
    reg [16:0] ofst_binEP2_updtd;      

    reg [15:0] in_binRE;
    reg [16:0] in_binEP0, in_binEP1, in_binEP2;

    wire [15:0] out_binRE;
    wire [16:0] out_binEP0, out_binEP1, out_binEP2;
    wire [2:0] numBits;
    wire mps_renorm, lps;

    // Instantiate the Decoder module
    Decoder #(BIN_WIDTH) DECODER (
        .clk(clk),
        .reset(reset),
        .bypass(bypass_flag),
        .bin(bin_out),
        .n_bin(n_bin),
        .pState_in(pState),
        .numBits(numBits),
        .m_value_binRE_in(in_binRE),
        .m_value_binEP0_in(in_binEP0),
        .m_value_binEP1_in(in_binEP1),
        .m_value_binEP2_in(in_binEP2),
        .m_value_binRE_out(out_binRE),
        .m_value_binEP0_out(out_binEP0),
        .m_value_binEP1_out(out_binEP1),
        .m_value_binEP2_out(out_binEP2),
        .mps_renorm(mps_renorm),
        .lps(lps)
    );

    // Instantiate the FileReader module
    FileReader READER (
        .clk(clk),
        .request(request_byte),
        .data(bitstream),
        .data_ready(data_ready)
    );

    // Clock signal generation
    initial begin
        count_line = 0;
        count = 0;
        clk = 0;
        bypass_flag = 0;
        request_byte = 0;

        index_uptd = 0;

        m_bitsNeeded = -4'd8;
        old_index = 0;
        ofst_binRE_updtd = 0;
        ofst_binEP0_updtd = 0;
        ofst_binEP1_updtd = 0;
        ofst_binEP2_updtd = 0;

        in_binRE = 0;
        in_binEP0 = 0;
        in_binEP1 = 0;
        in_binEP2 = 0;
        n_bin = 99;
        forever #5 clk = ~clk; // Clock with a period of 10 time units
    end

    always @(*) begin
        if (numBins - count <= BIN_WIDTH) begin
            n_bin = (numBins - count) - 1; // Processa o que falta (1, 2, 3 ou 4)
        end else begin
            n_bin = BIN_WIDTH - 1; // Processa 4 bins (capacidade máxima)
        end

        ofst_binEP0_updtd = out_binEP0 + bitstream;
        ofst_binEP1_updtd = out_binEP1 + bitstream;
        ofst_binEP2_updtd = out_binEP2 + bitstream;
        ofst_binRE_updtd = out_binRE + (bitstream << numBits);

        in_binRE = request_byte ? ofst_binRE_updtd : out_binRE;

        if (!request_byte) begin
            in_binEP0 = out_binEP0;
            in_binEP1 = out_binEP1;
            in_binEP2 = out_binEP2;
        end
    end

    always @(request_byte) begin
        if (request_byte) begin
            $display("verificando necessidade de atualizacao de m_value bn=%d", old_index);
            if (old_index == -4'd1) begin
                in_binEP0 = ofst_binEP0_updtd;
                in_binEP1 = out_binEP1;
                in_binEP2 = out_binEP2;
                $display("in_binEP0 somado com bitstream = %d", in_binEP0);
            end
            if (old_index == -4'd2) begin
                in_binEP0 = out_binEP2;
                in_binEP1 = ofst_binEP1_updtd;
                in_binEP2 = out_binEP2;

                $display("in_binEP1 somado com bitstream = %d", in_binEP1);
            end
            if (old_index == -4'd3) begin
                in_binEP0 = out_binEP2;
                in_binEP1 = out_binEP2;
                in_binEP2 = ofst_binEP2_updtd;
                $display("in_binEP2 somado com bitstream = %d", in_binEP2);
            end
        end
    end

    initial begin
        reset = 1;
        n_bin = 1;
       
        #7; 
        reset = 0;

        // Open the binary input file
        file = $fopen("C:/Users/ohgh0/Desktop/VVCAritmethicDecoder/DataProcessed/control3.bin", "rb");
        if (file == 0) begin
            $display("Error opening the file!");
            $finish;
        end

        // Open the text output file
        output_file = $fopen("C:/Users/ohgh0/Desktop/VVCAritmethicDecoder/Val/output.txt", "w");
        if (output_file == 0) begin
            $display("Error opening the output file!");
            $finish;
        end

        // File reading loop
        while (!$feof(file)) begin
            // Read the first byte and store in pState
            r = $fread(byte, file);
            if (r != 1) begin
                $display("Error reading the byte!");
                $finish;
            end
            pState = byte;
            count_line = count_line + 1;

            // Read the second byte
            r = $fread(byte, file);
            if (r != 1) begin
                $display("Error reading the second byte!");
                $finish;
            end
            
            // Separate bypass_flag and data
            bypass_flag = byte[7];
            numBins = byte[6:0];

            // Espera até que o número de bins decodificados seja igual a numBins
            while (count < numBins) begin
                @(posedge clk);
                old_index = index_uptd;
                index_uptd = m_bitsNeeded + n_bin + 1;

                if (index_uptd >= 0) begin    // reseta o contador
                    request_byte = 1;
                    m_bitsNeeded = index_uptd - 8;
                end else begin
                    request_byte = 0;
                    m_bitsNeeded = index_uptd;
                end
                
                if (bypass_flag) begin
                    count = count + n_bin + 1;
                    // $display("Modo bypass com byte par: contador incrementado por %d, contador atual = %d",n_bin + 1, count);
                end else begin
                    // Modo regular, incrementa por 1
                    count = count + 1;
                    // $display("Modo regular: contador incrementado por 1, contador atual = %d", count);
                end

                if (n_bin == 0) begin
                    // Grava apenas o LSB (bit 0)
                    $fwrite(output_file, "%b\n", bin_out[0]);
                    // $display("Gravando LSB = %b de bin_out", bin_out[0]);
                end else begin
                    // Grava os bits de acordo com o valor de n_bin
                    for (i = 0; i <= n_bin; i = i + 1) begin
                        $fwrite(output_file, "%b\n", bin_out[i]);
                        // $display("Gravando bin_out[%d] = %b", i, bin_out[i]);
                    end
                end
            end

            // Zerar o contador quando atingir numBins
            if (count >= numBins) begin
                count = 0;
                // $display("Contador zerado apos alcancar numBins.");
            end
        end

        // Close the files
        $fclose(file);
        $fclose(output_file);
        $display("File reading completed.");
        $finish;
    end
endmodule
