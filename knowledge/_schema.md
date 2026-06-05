# Schéma knowledge — jak zapisovat (čti před přidáním)

Konzistentní formát = AI kontroluje spolehlivě a všichni si rozumíme.

## Pravidlo (do `pravidla.md` nebo `kategorie/<x>.md`)
Každé pravidlo jako odrážka v tomto tvaru:

```
- **[ID]** `osa` · `závažnost` — <pravidlo lidsky> _(proč: volitelné)_
```

- **ID** — krátký, unikátní: `F-001` (fakta), `U-001` (úplnost), `FM-001` (formát), `S-001` (souvislosti). Globální = bez prefixu kategorie; per kategorie = s prefixem, např. `MAK-FM-001`.
- **osa** — `fakta` | `úplnost` | `formát` | `souvislosti`
- **závažnost** — `blokující` (⛔ musí být splněno) | `varování` (⚠ doporučení)
- **pravidlo** — co musí platit, měřitelně, ne vágně. ✅ „800–1200 slov" ❌ „přiměřená délka".

**Příklad:**
```
- **FM-001** `formát` · `blokující` — Článek má 800–1200 slov.
- **U-002** `úplnost` · `blokující` — Povinné sekce: úvod, postup, tipy, závěr.
- **MAK-F-001** `fakta` · `varování` — Teploty pečení uvádět ve °C i s heat/horkovzduch _(proč: garanti to plette)_.
```

## Kontext (do `kontext.md` nebo `kategorie/<x>.md`)
Volný text — background, ze kterého AI vychází (brand, tone, čeho si všímat). Není to pravidlo k odškrtnutí, ale rámec.

## Dokument (do `dokumenty/`)
Nahraj soubor (md/pdf/docx/txt) a přidej řádek do `dokumenty/README.md`: `název — k čemu slouží / co z něj brát`.

## Pravidla zápisu
- Jeden přírůstek = jeden smysluplný commit (`tools/sync.sh push "…"`).
- Neměň význam cizího pravidla bez domluvy; raději přidej nové a staré označ.
- ⚠ Veřejný repo — žádná citlivá klientská data.
