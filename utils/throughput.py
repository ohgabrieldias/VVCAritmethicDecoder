# Nome dos arquivos
input_file = 'VVCSoftware_VTM/bin/PartySceneDec-QP37.txt'  # Altere para o nome do seu arquivo de entrada
output_file = 'VVCAritmethicDecoder/DataProcessed/controleStructPartySceneDec-QP37.txt'

# Função para processar o arquivo
def process_file(input_file, output_file):
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        # Escrever o cabeçalho da tabela
        outfile.write(f"{'Tipo':<10} | {'Soma':<10} | {'Ciclos':<14} | {'Ciclos':<14}\n")
        outfile.write(f"{'':<10} | {'':<10} | {'(AD_2xEP_1xRE)':<11} | {'(AD_4xEP_1xRE)':<11}\n")
        outfile.write(f"{'-'*10} | {'-'*10} | {'-'*14} | {'-'*14}\n")

        current_word = None
        current_sum = 0
        total_sum = 0  # Para acumular a soma total
        total_cycles_2 = 0  # Para acumular os ciclos (AD_2xEP_1xRE)
        total_cycles_4 = 0  # Para acumular os ciclos (AD_4xEP_1xRE)
        total_bypass = 0  # Contador de bins Bypass
        total_regular = 0  # Contador de bins Regulares

        for line in infile:
            # Dividir a linha em partes
            parts = line.strip().split()
            if len(parts) != 3:
                continue  # Ignorar linhas inválidas

            _, word, number = parts
            number = int(number)

            # Verificar se a palavra mudou
            if word != current_word:
                if current_word is not None:
                    # Determinar o rótulo e calcular ciclos
                    if current_word == "decodeBinEP":
                        label = "Bypass"
                        cycles_2 = (current_sum + 1) // 2  # Dois bypass por ciclo
                        cycles_4 = (current_sum + 3) // 4  # Quatro bypass por ciclo
                        total_bypass += current_sum
                    else:
                        label = "Regular"
                        cycles_2 = current_sum
                        cycles_4 = current_sum
                        total_regular += current_sum
                    
                    # Acumular totais
                    total_sum += current_sum
                    total_cycles_2 += cycles_2
                    total_cycles_4 += cycles_4
                    
                    # Gravar a soma acumulada e ciclos no arquivo de saída
                    outfile.write(f"{label:<10} | {current_sum:<10} | {cycles_2:<14} | {cycles_4:<14}\n")

                # Reiniciar os contadores
                current_word = word
                current_sum = number
            else:
                # Somar o número à soma acumulada
                current_sum += number

        # Gravar a última soma acumulada
        if current_word is not None:
            if current_word == "decodeBinEP":
                label = "Bypass"
                cycles_2 = (current_sum + 1) // 2  # Dois bypass por ciclo
                cycles_4 = (current_sum + 3) // 4  # Quatro bypass por ciclo
                total_bypass += current_sum
            else:
                label = "Regular"
                cycles_2 = current_sum
                cycles_4 = current_sum
                total_regular += current_sum
            
            # Acumular totais
            total_sum += current_sum
            total_cycles_2 += cycles_2
            total_cycles_4 += cycles_4
            
            outfile.write(f"{label:<10} | {current_sum:<10} | {cycles_2:<14} | {cycles_4:<14}\n")

        # Calcular vazões
        throughput_2 = total_sum / total_cycles_2 if total_cycles_2 > 0 else 0
        throughput_4 = total_sum / total_cycles_4 if total_cycles_4 > 0 else 0

        # Calcular porcentagens de Bypass e Regulares
        bypass_percentage = (total_bypass / total_sum * 100) if total_sum > 0 else 0
        regular_percentage = (total_regular / total_sum * 100) if total_sum > 0 else 0

        # Gravar os totais, vazões e porcentagens
        outfile.write(f"{'-'*10} | {'-'*10} | {'-'*14} | {'-'*14}\n")
        outfile.write(f"{'Total':<10} | {total_sum:<10} | {total_cycles_2:<14} | {total_cycles_4:<14}\n")
        outfile.write(f"{'Vazão':<10} | {'':<10} | {throughput_2:<14.2f} | {throughput_4:<14.2f}\n")
        outfile.write(f"{'%'+'Bypass':<10} | {'':<10} | {bypass_percentage:<14.2f}% | {'':<14}\n")
        outfile.write(f"{'%'+'Regular':<10} | {'':<10} | {regular_percentage:<14.2f}% | {'':<14}\n")

# Executar a função
process_file(input_file, output_file)
