# Gestão de Velocidade — GBS Serviços

Painel web para acompanhar infrações de excesso de velocidade da frota.
O admin faz login, sobe o relatório `.xlsx` da InoPrime e o painel mostra os
dados (ranking por condutor, filtros de mês/dia/hora/base e detalhe por condutor).
Os dados ficam gravados no Supabase — sobe uma vez e fica salvo.

## Arquivos

| Arquivo        | O que é                                                        |
| -------------- | -------------------------------------------------------------- |
| `index.html`   | O aplicativo (login + upload + painel). É o que vai pra Vercel.|
| `logo.png`     | Logo da GBS. Tem que ficar **na mesma pasta** do `index.html`. |
| `schema.sql`   | Estrutura do banco. Roda **uma vez** no Supabase.              |
| `README.md`    | Este guia.                                                     |

---

## Passo 1 — Criar o banco no Supabase

1. Acesse `https://supabase.com`, faça login e abra (ou crie) o seu projeto.
2. No menu lateral, vá em **SQL Editor** → **New query**.
3. Cole todo o conteúdo de `schema.sql` e clique em **Run**.

Isso cria a tabela `infracoes`, os índices, as regras de segurança (RLS) e
liga o tempo real.

## Passo 2 — Criar o usuário admin

1. No Supabase, vá em **Authentication** → **Users** → **Add user** → **Create new user**.
2. Preencha:
   - **Email**: `admin@gbs.com` (ou outro e-mail que você queira usar)
   - **Password**: `GBS@2026`
   - Marque **Auto Confirm User** (pra não precisar confirmar por e-mail).
3. Clique em **Create user**.

> O login do painel aceita digitar **Admin** no campo "Usuário" — por trás ele
> usa o e-mail configurado. A senha é validada pelo Supabase, nunca fica no código.

## Passo 3 — Pegar as chaves do projeto

1. No Supabase, vá em **Settings** (engrenagem) → **API**.
2. Copie dois valores:
   - **Project URL** (algo como `https://xxxxx.supabase.co`)
   - **anon public** key (uma chave longa)

> A chave **anon** é pública e pode ficar no arquivo — quem protege os dados é o
> RLS do Passo 1. **Nunca** use a chave `service_role` no `index.html`.

## Passo 4 — Configurar o `index.html`

Abra o `index.html` num editor e, no começo do `<script>`, ajuste estas três linhas:

```js
const SUPABASE_URL='https://xxxxx.supabase.co';        // Project URL do Passo 3
const SUPABASE_ANON_KEY='cole_a_anon_public_key_aqui'; // anon key do Passo 3
const ADMIN_EMAIL='admin@gbs.com';                     // o e-mail do Passo 2
```

Salve o arquivo. Enquanto isso não estiver preenchido, o login avisa que falta configurar.

## Passo 5 — Testar (opcional, no seu computador)

Abrir o `index.html` direto com duplo-clique funciona pra ver a tela, mas o login
do Supabase pode exigir um servidor local. O jeito mais simples:

```bash
# na pasta do projeto
python3 -m http.server 5500
```

Depois abra `http://localhost:5500` no navegador, faça login (Admin / GBS@2026) e
suba o `.xlsx` pra testar.

## Passo 6 — Publicar na Vercel

### Opção A — Arrastar a pasta (mais rápido)

1. Acesse `https://vercel.com` e faça login.
2. Clique em **Add New… → Project → Deploy** (ou use o **Vercel CLI** abaixo).
3. Arraste a pasta com `index.html` + `logo.png`. A Vercel publica como site estático.

### Opção B — Vercel CLI

```bash
npm i -g vercel
cd pasta-do-projeto
vercel        # primeira vez: responde as perguntas e faz o deploy de teste
vercel --prod # publica em produção
```

### Opção C — Conectar ao GitHub

1. Suba os arquivos para um repositório no GitHub.
2. Na Vercel: **Add New… → Project → Import** o repositório.
3. Framework: **Other** (é site estático, sem build). Clique em **Deploy**.
4. A cada `git push`, a Vercel atualiza o site sozinha.

> Não precisa configurar build. É HTML estático.

---

## Como usar no dia a dia

1. Acesse o site e faça login (**Admin** / **GBS@2026**).
2. Clique em **Selecionar arquivo** (ou arraste) e suba o `.xlsx` da InoPrime.
3. O painel carrega: use os filtros de **Mês, Dia, Hora e Base**, ajuste o
   **"Pico a partir de"** e clique numa barra do ranking pra ver o detalhe do condutor.

### Sobre o upload

- **Sobe uma vez, fica salvo.** Os dados ficam no Supabase; ao logar de novo o
  painel já mostra tudo, sem precisar subir de novo.
- **Substituir por período:** reenviar o mesmo período apaga o antigo e regrava
  (não duplica). Subir um período novo acrescenta ao histórico.
- O painel atualiza sozinho (tempo real) assim que o upload termina.

---

## Observações

- **Segurança:** a senha do admin é validada pelo Supabase (não está no código).
  Para criar mais usuários, repita o Passo 2.
- **Fuso horário:** as datas são tratadas no horário de Brasília (-03:00). Como o
  uso é no Brasil, os filtros batem com o relatório.
- **Formato do arquivo:** o leitor espera o export padrão da InoPrime (com o
  cabeçalho na linha 6 e o período na linha 3). Suba sempre no mesmo formato.

Desenvolvido por: Eliézer França
