#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/app"

[ -d "$APP" ] || { echo "app/ nao existe. Rode ./setup.sh primeiro." >&2; exit 1; }

if [ -f "$ROOT/jarvis.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/jarvis.env"
  set +a
fi

cd "$APP"

if [ "${1:-}" = "--writes" ]; then
  echo "MODO ESCRITA ATIVO — o Jarvis pode enviar, apagar e instalar coisas."
  echo "Ctrl+C agora se voce nao quis isso."
  sleep 3
  exec npm start -- --writes
fi

exec npm start
