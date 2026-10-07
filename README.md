# mambas-jwt

Biblioteca de **JSON Web Tokens (JWT)** para [MambaScript](https://www.npmjs.com/package/mambascript-mz). Gera e valida tokens assinados com **HS256**, compatíveis com o padrão (testados no [jwt.io](https://jwt.io)).

## Requisitos

- `mambascript-mz` **2.28.4 ou superior**

A lib usa funções que só existem a partir dessa versão: `json_para_texto` e, no módulo `criptografia`, `paraBase64Url`, `hmacSha256Url` e `deBase64`.

## Instalação

```bash
mambas instalar mambas-jwt
```

## Uso rápido

```
importar jwt de "mambas-jwt"

variavel segredo = "minha-chave-secreta"

# gerar um token válido por 1 hora (3600 segundos)
variavel token = jwt.assinar({"id": 1, "nome": "Habibo"}, segredo, {"expiraEm": 3600})
escreva(token)

# validar
variavel resultado = jwt.validar(token, segredo)

se resultado.ok:
    escreva("Token válido para o utilizador " + resultado.dados.nome)
senao:
    escreva("Token recusado: " + resultado.erro)
fim
```

## API

### `assinar(payload, segredo, opcoes)`

Gera um token JWT assinado com HS256.

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `payload` | objeto | Dados que vão dentro do token (ex.: `{"id": 1}`) |
| `segredo` | texto | Chave secreta usada para assinar |
| `opcoes` | objeto | Opcional. `expiraEm`: duração em **segundos** |

Devolve o token como texto, no formato `header.payload.assinatura`.

Se `opcoes.expiraEm` for informado, a lib acrescenta o campo `exp` ao payload (timestamp Unix, em segundos). Este campo é adicionado ao objeto `payload` que passaste.

Exemplos de `expiraEm`:

| Valor | Duração |
|-------|---------|
| `900` | 15 minutos |
| `3600` | 1 hora |
| `86400` | 1 dia |
| `604800` | 7 dias |

### `validar(token, segredo)`

Verifica a assinatura e a expiração. **Não lança erro**: devolve sempre um objeto.

Token válido:

```
{ ok: verdadeiro, dados: { id: 1, nome: "Habibo", exp: 1791326509 } }
```

Token recusado:

```
{ ok: falso, erro: "Assinatura do token inválida" }
```

Mensagens de erro possíveis:

| Erro | Quando acontece |
|------|-----------------|
| `Token mal formado` | O token não tem exatamente 3 partes separadas por `.` |
| `Assinatura do token inválida` | Segredo errado ou token alterado |
| `O token expirou` | O `exp` do payload já passou |

## Exemplo: proteger uma rota

```
importar jwt de "mambas-jwt"

variavel SEGREDO = "troque-por-uma-chave-longa-e-aleatoria"

variavel autenticar = funcao(req, res):
    variavel cabecalho = req.cabecalhos["authorization"]

    se cabecalho == nulo:
        res.json(401, {"success": falso, "message": "Token em falta"})
        retorna nulo
    fim

    variavel token = cabecalho.substituir("Bearer ", "")
    variavel resultado = jwt.validar(token, SEGREDO)

    se resultado.ok == falso:
        res.json(401, {"success": falso, "message": resultado.erro})
        retorna nulo
    fim

    retorna resultado.dados
fim
```

> Adapte os nomes (`req.cabecalhos`, `res.json`) ao framework HTTP que estiver a usar.

## Notas de segurança

- Use um segredo **longo e aleatório** (32 caracteres ou mais) e guarde-o em variáveis de ambiente, nunca no código.
- O payload de um JWT é **codificado, não cifrado**: qualquer pessoa consegue lê-lo. Não coloque senhas nem dados sensíveis lá dentro.
- Defina sempre `expiraEm`. Um token sem expiração é válido para sempre.
- Sempre verifique `resultado.ok` antes de confiar em `resultado.dados`.

## Limitações

- Suporta apenas o algoritmo **HS256**.
- Valida a assinatura e o campo `exp`. Os campos `nbf`, `iss` e `aud` não são verificados automaticamente.

## Licença

MIT
