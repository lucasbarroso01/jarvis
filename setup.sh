#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REPO="https://github.com/adewaskar/jarvis"
UPSTREAM_REF="${JARVIS_UPSTREAM_REF:-main}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/app"

say() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
die() { printf '\n\033[31mERRO:\033[0m %s\n' "$1" >&2; exit 1; }

say "Checando pre-requisitos"

command -v node >/dev/null 2>&1 || die "Node.js nao encontrado. Instale o Node 20+ em https://nodejs.org"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 20 ] || die "Node $(node -v) encontrado, mas o Jarvis precisa do 20 ou mais novo."
echo "Node $(node -v) OK"

command -v claude >/dev/null 2>&1 \
  || die "Claude Code nao encontrado. Instale com: npm install -g @anthropic-ai/claude-code — depois rode 'claude' uma vez para fazer login."
echo "Claude Code encontrado em $(command -v claude)"

say "Baixando o Jarvis"
if [ -d "$APP/.git" ]; then
  echo "app/ ja existe, atualizando"
  git -C "$APP" fetch origin "$UPSTREAM_REF"
  git -C "$APP" checkout "$UPSTREAM_REF"
  git -C "$APP" pull --ff-only origin "$UPSTREAM_REF"
else
  git clone --branch "$UPSTREAM_REF" "$UPSTREAM_REPO" "$APP"
fi

say "Instalando dependencias"
(cd "$APP" && npm install)

if [ -f "$ROOT/jarvis.env" ]; then
  say "Aplicando jarvis.env"
  grep -E '^VITE_' "$ROOT/jarvis.env" > "$APP/.env.local" || true
  echo "Variaveis VITE_ copiadas para app/.env.local"
fi

say "Rodando o check do proprio projeto"
(cd "$APP" && npm run setup)

say "Pronto. Suba o Jarvis com: ./start.sh"
