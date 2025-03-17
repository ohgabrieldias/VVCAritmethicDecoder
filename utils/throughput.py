import os

# Caminho base onde estão os arquivos
base_path_in = "/home/dias/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCSoftware_VTM/bin"
base_path_out = "/home/dias/Área de trabalho/VVCAritmethicDecoder/DataProcessed/Throughput/"

# Sequências e valores de QP disponíveis
sequences = ["BQTerrace", "CatRobot", "FourPeople", "PartyScene", "Tango2"]
qp_values = [22, 27, 32, 37]

# Gerando os caminhos dinamicamente
input_files = [f"{seq}/Decoded/Dec-QP{qp}.txt" for seq in sequences for qp in qp_values]
output_files = [f"{seq}/QPw{qp}.txt" for seq in sequences for qp in qp_values]

def process_file(input_file, output_file):
    input_path = os.path.join(base_path_in, input_file)
    output_path = os.path.join(base_path_out, output_file)

    with open(input_path, "r") as infile, open(output_path, "w") as outfile:
        # Cabeçalhos da tabela
        outfile.write(f"{'Tipo':<10} | {'Soma':<10} | {'Ciclos':<14} | {'Ciclos':<14} | {'Ciclos':<14}\n")
        outfile.write(f"{'':<10} | {'':<10} | {'(AD_2xEP_1xRE)':<11} | {'(AD_3xEP_1xRE)':<11} | {'(AD_4xEP_1xRE)':<11}\n")
        outfile.write(f"{'-'*10} | {'-'*10} | {'-'*14} | {'-'*14} | {'-'*14}\n")

        current_word = None
        current_sum = 0
        total_sum = 0  
        total_cycles_2 = 0  
        total_cycles_3 = 0  
        total_cycles_4 = 0  
        total_bypass = 0  
        total_regular = 0  

        for line in infile:
            parts = line.strip().split()
            if len(parts) != 3:
                continue  

            _, word, number = parts
            number = int(number)

            if word != current_word:
                if current_word is not None:
                    if current_word == "decodeBinEP":
                        label = "Bypass"
                        cycles_2 = (current_sum + 1) // 2  
                        cycles_3 = (current_sum + 2) // 3  
                        cycles_4 = (current_sum + 3) // 4  
                        total_bypass += current_sum
                    else:
                        label = "Regular"
                        cycles_2 = current_sum
                        cycles_3 = current_sum
                        cycles_4 = current_sum
                        total_regular += current_sum
                    
                    total_sum += current_sum
                    total_cycles_2 += cycles_2
                    total_cycles_3 += cycles_3
                    total_cycles_4 += cycles_4
                    
                    outfile.write(f"{label:<10} | {current_sum:<10} | {cycles_2:<14} | {cycles_3:<14} | {cycles_4:<14}\n")

                current_word = word
                current_sum = number
            else:
                current_sum += number

        if current_word is not None:
            if current_word == "decodeBinEP":
                label = "Bypass"
                cycles_2 = (current_sum + 1) // 2  
                cycles_3 = (current_sum + 2) // 3  
                cycles_4 = (current_sum + 3) // 4  
                total_bypass += current_sum
            else:
                label = "Regular"
                cycles_2 = current_sum
                cycles_3 = current_sum
                cycles_4 = current_sum
                total_regular += current_sum
            
            total_sum += current_sum
            total_cycles_2 += cycles_2
            total_cycles_3 += cycles_3
            total_cycles_4 += cycles_4
            
            outfile.write(f"{label:<10} | {current_sum:<10} | {cycles_2:<14} | {cycles_3:<14} | {cycles_4:<14}\n")

        throughput_2 = total_sum / total_cycles_2 if total_cycles_2 > 0 else 0
        throughput_3 = total_sum / total_cycles_3 if total_cycles_3 > 0 else 0
        throughput_4 = total_sum / total_cycles_4 if total_cycles_4 > 0 else 0

        bypass_percentage = (total_bypass / total_sum * 100) if total_sum > 0 else 0
        regular_percentage = (total_regular / total_sum * 100) if total_sum > 0 else 0

        outfile.write(f"{'-'*10} | {'-'*10} | {'-'*14} | {'-'*14} | {'-'*14}\n")
        outfile.write(f"{'Total':<10} | {total_sum:<10} | {total_cycles_2:<14} | {total_cycles_3:<14} | {total_cycles_4:<14}\n")
        outfile.write(f"{'Vazão':<10} | {'':<10} | {throughput_2:<14.3f} | {throughput_3:<14.3f} | {throughput_4:<14.3f}\n")
        outfile.write(f"{'%'+'Bypass':<10} | {'':<10} | {bypass_percentage:<14.2f}% | {'':<14}\n")
        outfile.write(f"{'%'+'Regular':<10} | {'':<10} | {regular_percentage:<14.2f}% | {'':<14}\n")

# Processar todos os arquivos na lista
for input_file, output_file in zip(input_files, output_files):
    process_file(input_file, output_file)
    print(f"Processado: {input_file} -> {output_file}")
