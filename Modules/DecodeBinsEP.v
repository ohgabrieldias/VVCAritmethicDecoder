module DecodeBinsEP (
  input [31:0] m_value_in,
  input [31:0] m_range,
  input signed [3:0] m_bitsNeeded_in,  // Entrada com sinal
  input [31:0] numBins,
  input [7:0] read_byte,                // Byte lido externamente (simula m_bitstream->readByte())
  output reg [31:0] bins_out,
  output reg [31:0] m_value_out,
  output reg signed [3:0] m_bitsNeeded_out  // Saída com sinal
);

  reg [31:0] m_value;
  reg [31:0] bins;
  reg [31:0] remBins;
  reg [31:0] scaledRange;
  reg signed [3:0] m_bitsNeeded;  // Variável interna com sinal
  integer i;

  always @(*) begin
    // Inicializações das variáveis de saída e internas
    m_value = m_value_in;
    bins = 0;
    remBins = numBins;
    m_bitsNeeded = m_bitsNeeded_in;

    // Verificação do intervalo
    if (m_range == 256) begin
      bins_out = 0;  // chama decodeAlignedBinsEP() ********************
    end else begin
      // Loop para processar em blocos de 8 bins
      while (remBins > 8) begin
        m_value = (m_value << 8) + (read_byte << (8 + m_bitsNeeded));
        scaledRange = m_range << 15;

        // Processa 8 bits individualmente
        for (i = 0; i < 8; i = i + 1) begin
          bins = bins << 1;
          scaledRange = scaledRange >> 1;
          if (m_value >= scaledRange) begin
            bins = bins + 1;
            m_value = m_value - scaledRange;
          end
        end
        remBins = remBins - 8;
      end

      // Processamento dos bits restantes
      m_bitsNeeded = m_bitsNeeded + remBins;
      m_value = m_value << remBins;

      if (m_bitsNeeded >= 0) begin
        m_value = m_value + (read_byte << m_bitsNeeded);
        m_bitsNeeded = m_bitsNeeded - 8;
      end

      scaledRange = m_range << (remBins + 7);

      // Processamento bit a bit dos bins restantes
      for (i = 0; i < remBins; i = i + 1) begin
        bins = bins << 1;
        scaledRange = scaledRange >> 1;
        if (m_value >= scaledRange) begin
          bins = bins + 1;
          m_value = m_value - scaledRange;
        end
      end

      // Atribuição do valor final dos bins e estado
      bins_out = bins;
      m_value_out = m_value;
      m_bitsNeeded_out = m_bitsNeeded;
    end
  end
endmodule