import os
import subprocess

# Caminho base dos arquivos
base_path = "/home/dias/TCCII/analysis"
vtm_dir = "/home/dias/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCSoftware_VTM"
decoder_path = f"{vtm_dir}/bin/DecoderAppStatic"

# Sequências e valores de QP
# sequences = ["BQTerrace", "CatRobot", "FourPeople", "PartyScene", "Tango2"]

sequences = [
    "Tango2",               # Class A1
    "FoodMarket4",          # Class A1
    "Campfire",             # Class A1
    "CatRobot",             # Class A2
    "DaylightRoad2",        # Class A2
    "ParkRunning3",         # Class A2
    "MarketPlace",          # Class B
    "RitualDance",          # Class B
    "Cactus",               # Class B
    "BasketballDrive",      # Class B
    "BQTerrace",            # Class B
    "RaceHorsesC",          # Class C
    "BQMall",               # Class C
    "PartyScene",           # Class C
    "BasketballDrill",      # Class C
    "RaceHorses",           # Class D
    "BQSquare",             # Class D
    "BlowingBubbles",       # Class D
    "BasketballPass",       # Class D
    "FourPeople",           # Class E
    "Johnny",               # Class E
    "KristenAndSara",       # Class E
    "BasketballDrillText",  # Class F
    "ChinaSpeed",           # Class F
    "SlideEditing",         # Class F
    "SlideShow"             # Class F
]
qp_values = [22, 27, 32, 37]
# cfg_type = "randomaccess"
cfg_type = "lowdelay"
# cfg_type = "intra"

# Loop para executar o DecoderAppStatic para cada sequência e cada QP
for seq in sequences:
    decoded_dir = os.path.join(base_path, seq, "Decoded", cfg_type)  # Garante que a pasta Decoded existe
    # print("\nDecoder directory:", decoded_dir)
    os.makedirs(decoded_dir, exist_ok=True)  # Garante que a pasta Decoded existe
    
    for qp in qp_values:
        recon_file = os.path.join(base_path, seq, "Encoded", cfg_type, f"ReconFile_{qp}.yuv")
        bitstream_file = os.path.join(base_path, seq, "Encoded", cfg_type, f"BitstreamFile_{qp}.bin")
        output_log = os.path.join(decoded_dir, f"Dec-QP{qp}.txt")
        print(f"Decodificando {seq} QP{qp}...")
        # os.makedirs(os.path.dirname(output_log), exist_ok=True)  # Garante que a subpasta existe
        
        with open(output_log, "w") as log_file:
            subprocess.run([decoder_path, "-o", recon_file, "-b", bitstream_file], stdout=log_file)

print("Decodificação concluída!")

# Gerando os caminhos dinamicamente
input_files = [f"{seq}/Decoded/{cfg_type}/Dec-QP{qp}.txt" for seq in sequences for qp in qp_values]
output_files = [f"{seq}/Throughput/{cfg_type}/QP{qp}.txt" for seq in sequences for qp in qp_values]

report_file = os.path.join(base_path, f"Relatorio_{cfg_type}.txt")
report_data = []

def process_file(input_file, output_file):
    input_path = os.path.join(base_path, input_file)
    output_path = os.path.join(base_path, output_file)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)  # Garante que a subpasta existe
    # print(f"Processando {input_path} -> {output_path}")

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

        report_data.append(f"{regular_percentage:.2f}%\t{bypass_percentage:.2f}%\t{throughput_2:.3f}\t{throughput_3:.3f}\t{throughput_4:.3f}")
# Processar todos os arquivos na lista
for input_file, output_file in zip(input_files, output_files):
    process_file(input_file, output_file)
    print(f"Extraindo vazao: {input_file} -> {output_file}")

with open(report_file, "w") as rep_file:
    rep_file.write(f"{'% Regular':<10} | {'% Bypass':<10} | {'(AD_2xEP_1xRE)':<11} | {'(AD_3xEP_1xRE)':<11} | {'(AD_4xEP_1xRE)':<11}\n")
    rep_file.write("\n".join(line.replace(".", ",") for line in report_data))
