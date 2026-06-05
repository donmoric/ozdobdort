#!/usr/bin/env bash
# Ozdobdort skill — git sync helper.
# Použití:
#   sync.sh pull               → natáhne nejnovější sdílenou knowledge (před kontrolou)
#   sync.sh push "zpráva"      → nasdílí lokální změny knowledge ostatním
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || { echo "❌ nelze vstoupit do $DIR"; exit 1; }

if [ ! -d .git ]; then
  echo "ℹ️  Skill ještě není git repo (žádné sdílení). Inicializace: git init + napojení na GitHub remote."
  exit 0
fi

CMD="${1:-pull}"
case "$CMD" in
  pull)
    if ! git remote | grep -q .; then
      echo "ℹ️  Bez remote — pracuji s lokální verzí knowledge."
      exit 0
    fi
    if git pull --rebase --autostash --quiet; then
      echo "✅ Knowledge aktuální ($(git rev-parse --short HEAD))."
    else
      echo "⚠️  Pull selhal (offline / konflikt) — pokračuji s lokální verzí. Vyřeš ručně, pak znovu."
      exit 0
    fi
    ;;
  push)
    MSG="${2:-update knowledge}"
    git add -A
    if git diff --cached --quiet; then
      echo "ℹ️  Nic ke sdílení (žádná změna)."
      exit 0
    fi
    git commit -q -m "$MSG"
    if git remote | grep -q . && git push --quiet; then
      echo "✅ Nasdíleno ostatním: $MSG"
    else
      echo "⚠️  Commit hotov lokálně, ale push neproběhl (bez remote / bez práv / offline). Až bude spojení: git push."
    fi
    ;;
  *)
    echo "Použití: sync.sh [pull | push \"zpráva\"]"; exit 1 ;;
esac
