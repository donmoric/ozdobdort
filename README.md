# Ozdobdort — sdílený kontrolní skill + knowledge báze

Sdílená kontrolní vrstva pro obsah od **garantů** (české dezerty, zákusky, makronky, dezertní stůl / sweetbar). Cíl: ke klientovi jde jen obsah **překontrolovaný AI** podle pravidel, která tady společně udržujeme.

Není to webová appka — je to **Claude skill**: mechanismus v `SKILL.md`, znalosti v `knowledge/`, sdílení přes tenhle git repo.

## Jak to funguje
1. Skill na startu udělá `git pull` → máš nejnovější sdílenou knowledge.
2. Zkontroluje materiál od garanta na 4 osách (fakta · úplnost · formát · souvislosti) + 5-kolový doladící loop.
3. Když přidáš pravidlo/kontext/dokument, skill to `commit`+`push` → ostatní to mají při dalším běhu.

## Jak ho používat — 3 cesty (podle toho, co máš)

### A) Claude Code (plná funkčnost, doporučeno)
```bash
git clone <URL_TOHOTO_REPA> ~/.claude/skills/ozdobdort
```
Pak v Claude Code napiš `/ozdobdort` nebo „zkontroluj tenhle článek od garanta". Auto-sync, kontrola i přidávání znalostí fungují nativně.

### B) claude.ai (web)
Nahraj skill jako Capability/Skill (obsah `SKILL.md` + `knowledge/`). Auto-sync přes git je omezený — knowledge aktualizuj stažením z tohoto repa.

### C) Bez Claude — jen čtení/úprava knowledge
Všechno je čitelný markdown přímo tady na GitHubu. **Přidat znalost můžeš i z prohlížeče:** otevři soubor v `knowledge/`, klikni na tužku (Edit), zapiš, „Commit changes". Ostatním se to projeví po jejich příštím syncu.

## Struktura
```
SKILL.md                  ← mechanismus (jak kontrolovat + jak sdílet)
knowledge/
  _schema.md              ← jak psát pravidla (formát)
  kontext.md              ← brand, tone, obecný kontext Ozdobdortu
  pravidla.md             ← globální kontrolní + formátovací pravidla
  kategorie/              ← pravidla a kontext per kategorie
    makronky.md  dezertni-stul.md  zakusky.md
  dokumenty/              ← referenční podklady (zdroje faktů, vzory)
tools/sync.sh             ← git pull / commit+push helper
```

## Kdo smí zapisovat (sdílená editace)
Repo je **veřejné na čtení** (kdokoli vidí a stáhne knowledge), ale **zápis řídí přístup** — aby knowledge nemohl přepsat kdokoli z internetu:

- **Přispěvatelé = collaborators** repa. Každý přidaný collaborator může `push` → **databázi tak updatují všichni, kdo k ní mají přístup**, ne jen jeden správce.
- Po každém `push` mají ostatní novou verzi při svém příštím `pull` (auto na startu skillu) → **kontroly od té chvíle běží nad novou databází.**
- Kdo nemá Claude Code, může pravidlo přidat i z prohlížeče (Edit → Commit) — pokud je collaborator, jinak přes Pull Request.

**Jak přidat člověka:** GitHub repo → Settings → Collaborators → Add people (potřebuješ jeho GitHub username).

## ⚠ Veřejný repo
Tohle je veřejné. Do knowledge **nedávej citlivá klientská data** (ceny, smlouvy, osobní údaje). Jen kontrolní pravidla, kontext a veřejně sdílitelné podklady.
