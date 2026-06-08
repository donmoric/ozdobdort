#!/usr/bin/env bash
# Ozdobdort skill — git sync helper (self-bootstrapping).
# Použití:
#   sync.sh pull               → napojí se na GitHub (pokud ještě není) a natáhne nejnovější knowledge
#   sync.sh push "zpráva"      → nasdílí lokální změny knowledge ostatním
#
# Klíčová vlastnost: funguje, i když tuhle složku dostane někdo jen jako ZIP/kopii
# (bez .git). Při prvním `pull` se sama napojí na repo níže a stáhne aktuální verzi
# mechanismu i pravidel — proto lze lokální skill poslat komukoli kdykoli a "ožije".
set -uo pipefail

REPO_URL="https://github.com/donmoric/ozdobdort.git"
BRANCH="main"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR" || { echo "❌ nelze vstoupit do $DIR"; exit 1; }

# Zajisti, že složka je git repo napojené na origin (ať přišla jakkoli).
ensure_repo() {
  if [ ! -d .git ]; then
    git init -q
    git symbolic-ref HEAD "refs/heads/$BRANCH" 2>/dev/null || true
  fi
  if ! git remote | grep -qx origin; then
    git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"
  fi
}

CMD="${1:-pull}"
case "$CMD" in
  pull)
    ensure_repo
    if ! git fetch --quiet origin "$BRANCH" 2>/dev/null; then
      echo "⚠️  Bez spojení s GitHubem — pokračuji s lokální verzí knowledge."
      exit 0
    fi
    if ! git rev-parse --verify -q HEAD >/dev/null 2>&1; then
      # čerstvě napojená kopie (žádná historie) → natáhni vše z GitHubu
      git reset --hard --quiet "origin/$BRANCH"
      echo "✅ Napojeno na GitHub a staženo ($(git rev-parse --short HEAD))."
      exit 0
    fi
    AHEAD=$(git rev-list --count "origin/$BRANCH..HEAD" 2>/dev/null || echo 0)
    if [ "$AHEAD" = "0" ] && git diff --quiet && git diff --cached --quiet; then
      # čistý stav (typicky uživatel co jen kontroluje) → narovnej přesně na GitHub
      git reset --hard --quiet "origin/$BRANCH"
      echo "✅ Knowledge aktuální ($(git rev-parse --short HEAD))."
    else
      # mám rozpracované / nepushnuté změny (přispěvatel) → zachovej je
      if git pull --rebase --autostash --quiet origin "$BRANCH"; then
        echo "✅ Aktuální, lokální práce zachována ($(git rev-parse --short HEAD))."
      else
        echo "⚠️  Konflikt/offline — lokální verzi nechávám. Vyřeš ručně, pak znovu."
        exit 0
      fi
    fi
    ;;
  push)
    ensure_repo
    MSG="${2:-update knowledge}"
    git add -A knowledge/ tools/ *.md   # jen sdílené části (veřejný repo — chrání před omylem položenými soubory)
    git diff --cached --name-only       # vypiš, co se nasdílí (kontrola před commitem)
    if git diff --cached --quiet; then
      echo "ℹ️  Nic ke sdílení (žádná změna)."
      exit 0
    fi
    git commit -q -m "$MSG"
    if git push --quiet origin "$BRANCH" 2>/dev/null; then
      echo "✅ Nasdíleno ostatním: $MSG"
    else
      echo "⚠️  Commit hotov lokálně, ale push neproběhl (bez práv / offline). Až bude přístup: git push origin $BRANCH."
    fi
    ;;
  *)
    echo "Použití: sync.sh [pull | push \"zpráva\"]"; exit 1 ;;
esac
