def comparar_arquivos(arquivo1, arquivo2):
    with open(arquivo1, 'r') as f1, open(arquivo2, 'r') as f2:
        linha_num = 1
        while True:
            linha1 = f1.readline().strip()
            linha2 = f2.readline().strip()

            # Parar se não houver mais linhas no segundo arquivo
            if not linha2:
                if linha1:  # Verifica se o primeiro arquivo ainda tem mais linhas
                    print("Arquivo 1 possui linhas adicionais após o final de", arquivo2)
                break

            # Comparar as linhas
            if linha1 != linha2:
                print(f"Diferença encontrada na linha {linha_num}:")
                print(f"VTM: {linha1}")
                print(f"BYM: {linha2}")
                return

            linha_num += 1

        print("Nenhuma diferença encontrada nas linhas verificadas até o fim de", arquivo2)

# Exemplo de uso:
comparar_arquivos('VVCSoftware_VTM/bin/binsOut1000.txt', 'VVCAritmethicDecoder/Val/output.txt')
