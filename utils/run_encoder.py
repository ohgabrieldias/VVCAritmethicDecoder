import subprocess
import os
import time

vtm_dir = "/home/dias/Dropbox/GraduacaoEC/Cadeiras/2024.2/TCC-I/VVC/VVCSoftware_VTM"
base_path = "/home/dias/TCCII/analysis"
encoder_path = f"{vtm_dir}/bin/EncoderAppStatic"
# Lista das sequências de vídeo
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

# Arquivo de configuração genérico para o encoder
# cfg_type = "lowdelay"
cfg_type = "randomaccess"
# cfg_type = "intra"
persequence_cfg = f"{vtm_dir}/cfg/encoder_{cfg_type}_vtm.cfg"

# Valores de QP a serem testados
qp_values = [22,27, 32, 37]

def modify_cfg(cfg_path, qp, seq):
    """ Modifica os valores de QP, BitstreamFile e ReconFile no arquivo de configuração """
    bitstream_template = f"{base_path}/{seq}/Encoded/{cfg_type}/BitstreamFile_{qp}.bin"
    reconfile_template = f"{base_path}/{seq}/Encoded/{cfg_type}/ReconFile_{qp}.yuv"

    with open(cfg_path, "r") as file:
        lines = file.readlines()

    with open(cfg_path, "w") as file:
        for line in lines:
            if line.strip().startswith("QP"):
                file.write(f"QP                            : {qp}          # Quantization parameter(0-51)\n")
            elif line.strip().startswith("BitstreamFile"):
                file.write(f"BitstreamFile                 : {bitstream_template}\n")
            elif line.strip().startswith("ReconFile"):
                file.write(f"ReconFile                     : {reconfile_template}\n")
            else:
                file.write(line)

# Loop sobre cada sequência de vídeo
for seq in sequences:
    cfg_file = f"{vtm_dir}/cfg/per-sequence/{seq}.cfg"

    command = f"{encoder_path} -c {cfg_file} -c {persequence_cfg}"

    for qp in qp_values:
        print(f"\n>> Configurando {seq} com QP={qp} e modificando arquivos de saída...\n")

        encoded_dir = os.path.join(base_path, seq, "Encoded", cfg_type) # Garante que a pasta Encoded existe
        os.makedirs(encoded_dir, exist_ok=True)

        modify_cfg(persequence_cfg, qp, seq)

        print("Iniciando a execução do encoder...\n")

        # Executa o encoder
        start_time = time.time()
        process = subprocess.run(command, shell=True)
        end_time = time.time()

        # salva em arquivo txt o tempo de execução
        print(f"\n>> Execução de {seq} com QP={qp} concluída em {end_time - start_time:.2f} segundos.\n")

print("\n>> Todas as execuções foram concluídas!")
