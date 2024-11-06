def convert_txt_to_binary(input_file, output_file):
    first_ten_values = []  # Lista para armazenar os primeiros 10 valores

    with open(input_file, 'r') as txt_file, open(output_file, 'wb') as bin_file:
        for line in txt_file:
            try:
                # Converte cada linha em um número inteiro
                number = int(line.strip())
                # Verifica se o número está no intervalo de um byte
                if 0 <= number <= 255:
                    # Escreve o número como um byte no arquivo binário
                    bin_file.write(number.to_bytes(1, byteorder='big'))
                    # Armazena os primeiros 10 valores
                    if len(first_ten_values) < 10:
                        first_ten_values.append(number)
                else:
                    print(f"Valor fora do intervalo de um byte: {number}")
            except ValueError:
                print(f"Linha inválida: {line.strip()}")

    # Exibe os primeiros 10 valores para validação
    print("Primeiros 10 valores em decimal:", first_ten_values)

# Exemplo de uso
convert_txt_to_binary('VVCAritmethicDecoder/DataExtracted/bytesExtracted.txt', 'VVCAritmethicDecoder/DataProcessed/bytes.bin')
