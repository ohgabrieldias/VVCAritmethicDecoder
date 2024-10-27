def process_file(input_file, output_file):
    # Lista para armazenar os novos valores
    new_values = []

    # Ler o arquivo de texto
    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()  # Remove espaços em branco no início e no final
            if line:  # Verifica se a linha não está vazia
                try:
                    # Dividir a linha em dois valores
                    left, right = map(int, line.split())
                    # Combinar o valor de 8 bits com o de 1 bit
                    new_value = (right << 8) | left  # right como bit mais significativo
                    new_values.append(new_value)
                except ValueError as e:
                    print(f"Erro ao processar a linha: '{line}'. Erro: {e}")

    # Gravar os novos valores em um arquivo binário
    with open(output_file, 'wb') as f:
        for value in new_values:
            f.write(value.to_bytes(2, byteorder='big'))  # 2 bytes por valor

    # Ler os primeiros 10 valores do arquivo binário para validação
    with open(output_file, 'rb') as f:
        print("Primeiros 10 valores do arquivo binário:")
        for _ in range(10):
            bytes_read = f.read(2)  # Ler 2 bytes
            if not bytes_read:
                break
            # Converter os bytes lidos de volta para um número inteiro
            value = int.from_bytes(bytes_read, byteorder='big')
            print(value)

# Definindo os nomes dos arquivos
input_file = 'arquivo.txt'  # Nome do seu arquivo de texto
output_file = 'resultado.bin'  # Nome do arquivo binário de saída

# Chamar a função de processamento
process_file(input_file, output_file)
