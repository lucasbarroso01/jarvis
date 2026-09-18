# Jarvis — setup do Lucas

Assistente de voz que roda no navegador com interface estilo Homem de Ferro. Você
diz **"Hey Jarvis"**, ele acorda e responde usando as ferramentas que você já
conectou ao Claude Code.

Este repositório **não contém** o código do assistente. Ele é a camada de setup e
configuração: dois scripts e um arquivo de variáveis que baixam, configuram e
sobem o projeto original com as suas preferências.

O código do assistente é o projeto open source [`adewaskar/jarvis`][upstream],
licença MIT. Manter ele separado, clonado em `app/`, significa que você recebe as
correções do autor com um `./setup.sh` em vez de ter uma cópia congelada.

[upstream]: https://github.com/adewaskar/jarvis

---

## Como funciona

São duas peças rodando na sua máquina:

- **A cara** — uma página web (React + Three.js) que escuta, fala e mostra o
  reator. Roda em `http://localhost:5173`.
- **O cérebro** — um servidor Node local, o *bridge*, que roda o Claude Agent SDK.
  Ele sobe o `claude` de verdade em segundo plano. Então quem responde é o Claude
  Code, logado com a sua conta.

Não existe chave de API nova nem segunda cobrança. O uso vai na conta Claude que
você já tem.

---

## Pré-requisitos

| O quê | Por quê |
|---|---|
| **Claude Code instalado e logado** | É o cérebro. Se `claude` abre no terminal, está pronto. Senão: `npm install -g @anthropic-ai/claude-code` e rode `claude` uma vez. |
| **Node.js 20 ou mais novo** | É um app web Node. Instalador em [nodejs.org](https://nodejs.org). |
| **Chrome ou Edge, em janela de verdade** | Precisa de microfone e WebGL. **Painel de preview dentro do editor não serve** — bloqueia o microfone, a página carrega bonita e nunca te escuta. |
| **ElevenLabs (opcional)** | Só para a voz boa. Deixe para depois de funcionar. |

---

## Instalação

```bash
git clone https://github.com/lucasbarroso01/jarvis.git
cd jarvis
cp jarvis.env.example jarvis.env
chmod +x setup.sh start.sh
./setup.sh
```

O `setup.sh` checa Node e Claude Code, clona o projeto em `app/`, instala as
dependências e roda o check do próprio projeto.

## Uso

```bash
./start.sh
```

Abra `http://localhost:5173` no **Chrome ou Edge**, em janela normal. Vai rolar a
sequência de boot e aparecer o reator. Clique em **INITIALISE**, permita o
microfone e diga **"Hey Jarvis"**.

### Teclas

| Tecla | O que faz |
|---|---|
| `Espaço` | Falar sem usar a palavra de ativação |
| Só falar por cima | Interrompe ele no meio da frase |
| `D` | Painel de diagnóstico — diz se ele está te ouvindo e se está emitindo som |
| `T` | Teste de áudio de uma linha |
| `Esc` | Manda ele parar |

---

## A voz boa (opcional)

Crie uma conta gratuita na [ElevenLabs](https://elevenlabs.io), copie a chave do
perfil e cole em `jarvis.env`:

```
ELEVENLABS_API_KEY=sua_chave_aqui
```

Não tem botão para ligar. O app detecta a chave no boot e se atualiza sozinho —
voz e transcrição melhoram juntas. Sem chave, cai na voz do navegador.

`jarvis.env` está no `.gitignore`. A chave nunca vai para o GitHub. Cole ela no
terminal ou no arquivo, nunca em caixa de chat de site.

---

## Conectar calendário, email e seus números

Esta é a parte que transforma o brinquedo em ferramenta — e é onde quase todo
mundo tropeça.

**Conectores que você adicionou no claude.ai não funcionam aqui.** Eles ficam na
sua conta, não no seu disco. O bridge lê os servidores MCP do arquivo local
`~/.claude.json`. Então tudo que você quiser que o Jarvis enxergue precisa ter
sido adicionado pela linha de comando pelo menos uma vez.

Para ver o que você já tem, abra o Claude Code e peça:

> Me mostre todos os servidores MCP que estão hoje no meu `~/.claude.json`, como
> uma lista simples do que cada um conecta. Depois me diga quais destes três
> estão faltando e o que eu precisaria para adicionar cada um: meu calendário,
> meu email, e o lugar onde ficam meus números de faturamento. Não adicione nada
> ainda — só me mostre a lista e o que falta.

Adicione **um de cada vez** e teste depois de cada um. Quando conectar um,
reinicie o Jarvis e pergunte algo que só aquela ferramenta saberia responder.

A pergunta que justifica o build inteiro é uma que cruza dois sistemas:

> Hey Jarvis — como está meu dia? Me lê minhas reuniões em ordem, me diz para
> qual eu não me preparei, e me diz se alguma coisa que chegou no email hoje de
> manhã tem relação com alguma delas.

Perguntar um fato único que já está na sua tela sempre vai parecer um jeito mais
lento de olhar o calendário. Porque é.

---

## O que ele tem permissão de fazer

Por padrão o Jarvis é **somente leitura**. Ele busca, consulta e gera à vontade.
Qualquer coisa que muda o mundo — enviar, apagar, instalar, pagar — é recusada.

Isso é decisão de design do autor, e a razão é boa: voz é uma interface péssima
para caixa de confirmação. Então a decisão é tomada antes, não na hora.

Para ligar escrita:

```bash
./start.sh --writes
```

Leia o `decideTool()` em `app/bridge/server.mjs` antes. *"Hey Jarvis, limpa minha
pasta de downloads"* significa uma coisa bem diferente com escrita ligada. Uma
frase mal ouvida com escrita ligada não é um mal-entendido, é uma ação.

### Regras que valem a pena seguir

- Rode **somente leitura na primeira semana**. Aprenda o que ele entende errado
  antes de deixar ele agir sobre o que entendeu errado.
- Conecte **uma ferramenta por vez** e teste. Quando quebrar, você sabe o quê.
- Antes de ligar escrita, peça algo efetivo e **confirme que ele recusa**. Se ele
  fizer, você não está no modo que pensa que está.
- Escrita só para tarefas que você refaria barato: rascunho, agendamento,
  arquivamento. Nunca dinheiro, contrato ou coisa irreversível.
- Fale em frase inteira, não em palavra-chave. Palavra-chave dá resposta de campo
  de busca.

---

## Quando não funciona

**Ele parece vivo mas nunca responde.** Nove em dez vezes é o microfone: ou você
está num painel de preview em vez de janela de navegador de verdade, ou dispensou
a permissão do microfone sem perceber. Aperte `D`.

**Ele fala por cima de você e termina a frase.** O lado de falar funciona, o de
ouvir não. Aperte `D` e veja o diagnóstico.

**A página não carrega.** Confira se o terminal com o `./start.sh` ainda está
rodando.

**Bridge inacessível.** Veja se alguma outra coisa está ocupando a porta `8787`.

---

## Estrutura

```
.
├── setup.sh              # checa pré-requisitos, clona o upstream, instala
├── start.sh              # carrega jarvis.env e sobe o app
├── jarvis.env.example    # modelo de configuração — copie para jarvis.env
└── app/                  # o projeto adewaskar/jarvis (fora do git, vem no setup)
```

Para fixar uma versão específica do upstream em vez de seguir a `main`:

```bash
JARVIS_UPSTREAM_REF=<tag-ou-commit> ./setup.sh
```

---

## Créditos

O assistente é [`adewaskar/jarvis`](https://github.com/adewaskar/jarvis), MIT.
Este repositório é só o setup em volta dele.

O passo a passo original veio do guia "Build Your Own Jarvis", da Reprise AI.
