def process_and_write_binary(input_file, output_file):
    with open(input_file, 'r') as file, open(output_file, 'wb') as bin_file:
        for line in file:
            parts = line.split()
            if len(parts) == 3:
                # Converter cada parte da linha para int
                left_value = int(parts[0]) & 0xFF       # Primeiro byte (8 bits)
                middle_value = int(parts[1]) & 0x01     # Apenas o bit mais significativo do segundo byte
                right_value = int(parts[2]) & 0x7F      # 7 bits restantes do segundo byte
                
                # Construir o segundo byte: MSB é middle_value e os 7 bits seguintes são right_value
                second_byte = (middle_value << 7) | right_value
                
                # Escrever os dois bytes no arquivo binário
                bin_file.write(bytes([left_value, second_byte]))


def read_and_display_binary(output_file):
    with open(output_file, 'rb') as bin_file:
        # Ler os primeiros 20 bytes
        bytes_to_read = 20
        byte_values = bin_file.read(bytes_to_read)
        
        # Converter os bytes lidos em valores decimais
        decimal_values = [b for b in byte_values]
        
        # Exibir os valores decimais
        print("Os primeiros 20 bytes em decimal:")
        for index, value in enumerate(decimal_values):
            print(f"Byte {index + 1}: {value}")

# Nome do arquivo de entrada e saída binária
input_file = 'VVCAritmethicDecoder/DataProcessed/controleStructData3.txt'    # Altere para o nome do seu arquivo de entrada
output_file = 'VVCAritmethicDecoder/DataProcessed/control3.bin'     # Nome do arquivo de saída binária

# Processar o arquivo e salvar o resultado em formato binário
process_and_write_binary(input_file, output_file)
# Ler o arquivo binário e exibir os primeiros 20 bytes em decimal
read_and_display_binary(output_file)
print("Arquivo processado e salvo em formato binário com sucesso.")
