def processar_dados(arquivo_entrada, arquivo_saida):
    with open(arquivo_entrada, 'r') as f:
        linhas = f.readlines()
    
    dados_binarios = bytearray()

    for linha in linhas:
        numero, flag = map(int, linha.strip().split())
        
        # Certifique-se de que `numero` esteja dentro de 7 bits e `flag` seja 0 ou 1
        if not (0 <= numero < 128) or not (flag in (0, 1)):
            raise ValueError(f"Dado inválido: {numero} {flag}")

        # Construa o byte: (flag << 7) | numero
        byte = (flag << 7) | numero
        dados_binarios.append(byte)
    
    # Salve o resultado em um arquivo binário
    with open(arquivo_saida, 'wb') as f:
        f.write(dados_binarios)
    
    # Leitura e exibição dos 10 primeiros valores para validação (sem a flag)
    with open(arquivo_saida, 'rb') as f:
        primeiros_10_bytes = list(f.read(10))
        
        # Remover a flag (bit mais significativo) de cada byte usando a máscara 0x7F
        valores_sem_flag = [byte & 0x7F for byte in primeiros_10_bytes]
        
        print("Primeiros 10 valores no arquivo binário (sem a flag):", valores_sem_flag)

# Exemplo de uso
processar_dados('DataExtracted/controle.txt', 'DataProcessed/control.bin')
