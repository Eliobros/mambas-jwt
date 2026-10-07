# index.ms
# Biblioteca Oficial de Autenticação JWT para MambaScript
# Localizado em modulos_mambas/mambas-jwt/index.ms

importar cripto de "criptografia"
importar mat de "matematica"

funcao paraBase64Url(textoBase64):
    variavel limpo = textoBase64.substituir("=", "").substituir("+", "-").substituir("/", "_")
    retorna limpo
fim

# funcao para gerar o token
funcao assinar(payload, segredo, opcoes):
    variavel header = {
        "alg": "HS256",
        "typ": "JWT"
    }

    se opcoes.expiraEm != nulo:
        # Pega o tempo atual em segundos
        variavel timestampSegundos = mat.arredondar(hoje("Africa/Maputo").timestamp() / 1000)
        payload.exp = timestampSegundos + opcoes.expiraEm
    fim

    variavel headerBase64 = paraBase64Url(cripto.paraBase64(texto_json(header)))
    variavel payloadBase64 = paraBase64Url(cripto.paraBase64(texto_json(payload)))

    variavel dadosParaAssinar = headerBase64 + "." + payloadBase64
    variavel assinaturaRaw = cripto.hmacSha256(dadosParaAssinar, segredo)
    variavel assinaturaBase64 = paraBase64Url(assinaturaRaw)

    retorna dadosParaAssinar + "." + assinaturaBase64
fim

# funcao para validar os tokens
funcao validar(tokenCompleto, segredo):
    variavel partes = tokenCompleto.dividir(".")

    se partes.length != 3:
        retorna {"ok": falso, "erro": "Token mal formado"}
    fim

    variavel headerBase64 = partes[0]
    variavel payloadBase64 = partes[1]
    variavel assinaturaRecebida = partes[2]
    
    variavel dadosParaVerificar = headerBase64 + "." + payloadBase64
    variavel assinaturaCorretaRaw = cripto.hmacSha256(dadosParaVerificar, segredo)
    variavel assinaturaCorreta = paraBase64Url(assinaturaCorretaRaw)

    se assinaturaRecebida != assinaturaCorreta:
        retorna {"ok": falso, "erro": "Assinatura do token inválida"}
    fim

    variavel payloadTexto = cripto.deBase64(payloadBase64)
    variavel payload = json_texto(payloadTexto)

    # Garante o mesmo fuso horário e a mesma unidade (segundos) na validação
    variavel tempoAgoraSegundos = mat.arredondar(hoje("Africa/Maputo").timestamp() / 1000)
    se payload.exp != nulo e tempoAgoraSegundos > payload.exp:
        retorna {"ok": falso, "erro": "O token expirou"}
    fim
    
    retorna {"ok": verdadeiro, "dados": payload}
fim
