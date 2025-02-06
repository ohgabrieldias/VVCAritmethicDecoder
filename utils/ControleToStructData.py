# Função para ler o arquivo e processar os dados
def process_file(filename):
    result = []
    decode_bin_ep_sum = 0
    last_left_value = None  # Para armazenar o valor à esquerda de `decodeBinEP` consecutivo
    with open(filename, 'r') as file:
        for line in file:
            parts = line.split()
            if len(parts) == 3:
                left_value, operation, value = parts[0], parts[1], int(parts[2])
                
                # Se for decodeBinEP, acumula o valor e armazena o valor à esquerda
                if operation == "decodeBinEP":
                    decode_bin_ep_sum += value
                    last_left_value = left_value
                else:
                    # Se mudar para decodeBin, armazena a soma acumulada de decodeBinEP, se houver
                    if decode_bin_ep_sum > 0:
                        result.append(f"{last_left_value} 1 {decode_bin_ep_sum}")
                        decode_bin_ep_sum = 0
                    # Armazena a linha de decodeBin, substituindo por 0 e mantendo o valor à esquerda
                    result.append(f"{left_value} 0 {value}")
        
        # Armazena o último valor somado de decodeBinEP, se houver
        if decode_bin_ep_sum > 0:
            result.append(f"{last_left_value} 1 {decode_bin_ep_sum}")
    
    return result

# Escrever o resultado processado em um novo arquivo
def write_output(result, output_file):
    with open(output_file, 'w') as file:
        for line in result:
            file.write(line + '\n')

# Nome do arquivo de entrada e saída
input_file = 'VVCSoftware_VTM/bin/PartySceneDec-QP37.txt' # Altere para o nome do seu arquivo de entrada
output_file = 'VVCAritmethicDecoder/DataProcessed/controleStructPartySceneDec-QP37.txt'    # Nome do arquivo de saída

# Processar o arquivo e salvar o resultado
result = process_file(input_file)
write_output(result, output_file)
print("Arquivo processado com sucesso. Resultado salvo em", output_file)