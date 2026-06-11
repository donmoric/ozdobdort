---
name: ozdobdort
description: >-
  Ozdobdort — sdílená kontrolní vrstva + knowledge báze pro obsah od garantů
  (české dezerty, zákusky, makronky, dezertní stůl / sweetbar). Aktivuj, když
  máš ZKONTROLOVAT nebo DOLADIT článek/materiál od garanta před předáním klientovi
  (příjemci), nebo když PŘIDÁVÁŠ/UPRAVUJEŠ znalost (pravidlo, kontext, dokument) do
  sdílené databáze. Provede kontrolu na 4 osách (fakta, úplnost, formát, souvislosti)
  + 5-kolový doladící loop podle pravidel z knowledge/, a synchronizuje sdílenou
  databázi přes git (pull na startu, commit+push při změně). Triggery: "/ozdobdort",
  "zkontroluj článek od garanta", "doladí materiál pro klienta", "přidej pravidlo
  do Ozdobdortu", "co máme v knowledge o makronkách".
---

# Ozdobdort — controlling obsahu garantů (sdílený skill)

Sdílená, samo-aktualizující se kontrolní vrstva. Mechanismus je tady, **data jsou v `knowledge/`** a synchronizují se přes git (veřejný GitHub repo). Víc lidí z toho čerpá a společně to updatuje.

## Aktéři (kontext)
- **Garant** — influencer/odbornice, dodává obsah v kategorii.
- **Interní brána** — kolegyně z týmu; schvaluje materiál před odesláním klientovi.
- **Klient** — finální příjemce (Ozdobdort).
- Cíl: ke klientovi jde jen obsah **překontrolovaný AI** podle sdílených pravidel.

---

## KROK 0 — Sync (VŽDY první, nevynechatelné)
Než cokoli uděláš, natáhni nejnovější sdílenou knowledge:
```bash
bash ~/.claude/skills/ozdobdort/tools/sync.sh pull
```
**Tím je zaručeno, že kontrola běží nad NEJNOVĚJŠÍ sdílenou databází** — tj. nad vším, co kdokoli z přispěvatelů naposledy přidal. Bez tohoto kroku bys kontroloval podle zastaralých pravidel; proto ho nikdy nevynechávej.

Pokud sync selže (offline / není remote), **pokračuj s lokální verzí** a upozorni uživatele, že pracuje nad nesynchronizovanou kopií.

---

## REŽIM A — Kontrola materiálu od garanta

### 1. Načti vstup a urči kategorii
- Vstup = článek/materiál (vložený text nebo soubor).
- Urči **doménovou kategorii**: makronky / zákusky / dezertní stůl. Když neurčíš, **zeptej se**, nedomýšlej.
- **Průřezové kategorie kontroluj VŽDY** (bez ohledu na doménu): `alergeny-znaceni`, `bezpecnost-skladovani` a `dietni-upravy` (je-li obsah vegan/bezlepkový). Článek o makronkách obsahuje alergeny (mandle) i bezpečnost (syrové bílky).

### 2. Načti relevantní knowledge
Přečti a drž jako kontrolní normu:
- `knowledge/kontext.md` (brand, tone, názvosloví)
- `knowledge/pravidla.md` (globální pravidla)
- `knowledge/kategorie/<doménová>.md` (makronky / zákusky / dezertní stůl)
- **VŽDY** `knowledge/kategorie/alergeny-znaceni.md` + `bezpecnost-skladovani.md` (průřezové; u vegan/bezlepek i `dietni-upravy.md`)
- relevantní `knowledge/dokumenty/` — zejména `alergeny-1169-2011.md` (alergeny ověřuj proti němu, **ne zpaměti**)

### 3. Kontrola na 4 osách
Projdi materiál a pro každou osu vrať nálezy (`OK` / `⚠ varování` / `⛔ blokující`) + návrh opravy:

| Osa | Co kontroluješ |
|---|---|
| **Fakta** | Tvrzení (postupy, poměry, teploty, názvosloví, trendy) proti `dokumentům`/kontextu. Nejisté → ⛔, **nikdy nedomýšlej fakt.** |
| **Úplnost** | Povinné sekce dle pravidel kategorie. Chybí obsah → ⛔. |
| **Formát** | Struktura, délka, styly dle `pravidla.md`. |
| **Souvislosti** | Konzistence terminologie a návaznost (př. *dezertní stůl* ↔ *sweetbar*), nekoliduje s jinými materiály. |

### 4. 5-kolový doladící loop
Když je ⛔ nebo ⚠ k opravě:
```
kolo k (k=1..5): oprav dle pravidel → re-kontrola všech 4 os
  čisto?  ANO → konec loopu
          NE  → kolo k+1
  k=5 a stále ⛔ → ESKALUJ člověku se seznamem, co nešlo doladit
```
Pravidlo: loop **opravuje formu a doplňuje ze zdrojů v `dokumenty/`**; faktickou mezeru, na kterou nemáš podklad, **neopravuj — eskaluj.** Stručně loguj, co se v kterém kole měnilo.

### 5. Controlling balíček (výstup pro interní bránu → klienta)
Vrať:
1. **Doladěný materiál** (a nabídni export do Wordu / Google Docs).
2. **Soupis nálezů** — co bylo OK / opraveno / eskalováno, s odkazem na konkrétní pravidlo.
3. **Stav:** `připraveno k odeslání` / `vyžaduje rozhodnutí člověka (interní brána)`.

> Odeslání ven klientovi je vždy lidský Decide — skill ho **nikdy neodesílá sám**.

---

## REŽIM B — Přidání / úprava znalosti

Když uživatel chce zapsat nové pravidlo / kontext / dokument:
1. Urči **typ** (pravidlo · kontext · dokument) a **rozsah** (globální vs. kategorie).
2. Zapiš do správného souboru podle `knowledge/_schema.md` (pravidla mají ID, osu, závažnost).
3. Dokumenty (soubory) ulož do `knowledge/dokumenty/` a přidej řádek do jeho `README.md` (název → k čemu slouží).
4. **Automaticky nasdílej ostatním — VŽDY a HNED, bez ptaní.** Jakmile zapíšeš jakoukoli změnu do `knowledge/`, **okamžitě** ji pushni (nečekej na pokyn, nehromaď změny lokálně):
```bash
bash ~/.claude/skills/ozdobdort/tools/sync.sh push "knowledge: <co jsi přidal/změnil>"
```
   Pushovat může **každý přispěvatel** (ne jen správce) — databáze se updatuje od všech. Od příštího `pull` podle ní kontrolují všichni.
   - Když push **neprojde** (chybí přístup / přihlášení ke GitHubu), **řekni to natvrdo** a naviguj k nápravě (přijmout pozvánku collaboratora + jednorázové `gh auth login`). **Nikdy netvrď, že je nasdíleno, když není.**
5. Potvrď uživateli, co se zapsalo a zda to je nasdílené na GitHub.

> ⚠ **Veřejný repo** — do knowledge **nikdy** nedávej citlivá klientská data (ceny, smlouvy, osobní údaje, neveřejné interní info). Jen kontrolní pravidla, kontext a veřejně sdílitelné podklady.

---

## Pravidla chování
- **Nikdy si nedomýšlej fakta** — neověřené tvrzení = ⛔, ne propuštění.
- **Knowledge je zdroj pravdy** — kontroluj podle souborů, ne z hlavy.
- **Audit = git historie** — každá změna knowledge je commit (kdo/co/kdy).
- **Synchronizace je automatická a povinná** — `pull` na startu (KROK 0) a `push` **ihned po každé změně** knowledge. GitHub má vždy nejnovější verzi; nově příchozí (i poslaná offline kopie) si ji při prvním `pull` dotáhnou sami. Nikdy nenech změnu viset jen lokálně.
- Když pravidlo chybí a bránilo by kontrole, **navrhni ho** uživateli k zapsání (Režim B), místo abys improvizoval.
