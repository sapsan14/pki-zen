---
destination: sapsan14/life → reflect/2026-04-17_pki-zen-refactor.md
category: pki-zen / editorial process / meta
date: 2026-04-17
---

# Refactoring PKI-ZEN into a complete sūtra

On 17 April 2026, I asked an AI editor to review PKI-ZEN critically — as a
fiction editor, a comic-book editor, and an engineer with a sense of humor —
and to rebuild it into a *publishable* artifact in three languages.

This file is the meta-reflection on that refactor. It belongs in the life
repo because, per `v9.7`, signature and timestamp matter more than the author:
recording the process is how we make it verifiable.

## What changed

**Before (9 flat files):**
- `PKI-ZEN_COMPLETE_RUS.txt` (5 books bundled)
- `PKI-ZEN_COMPLETE_ENG.txt` (same, English)
- `book6.md`, `book7.md` (RU only)
- `book8.md` (EN), `book8-rus.md` (RU)
- `notes.txt` (raw origin chat)
- `README.md`, `README_RUS.md`

**After (structured trilingual):**
- `books/ru/` — 13 files (0 Prologue, 10 volumes, appendix, colophon) × 108 verses canonical
- `books/en/` — full parallel translation with wordplay calibration
- `books/et/` — first-time Estonian translation, 108 verses
- `publish/` — Pandoc + VitePress full pipeline
- `oracle/` — 324-row JSONL corpus + system prompt + 10 examples
- `attic/` — staged for the life repo

**New material as Author:**
- Book 0 (Prologue) — 9 verses framing the chat origin as sūtra.
- Book IX (Field of Trust) — 9 verses drawn from
  [trust-field-theory](https://github.com/sapsan14/life/blob/main/reflect/2026-02-18_trust-field-theory.md) reflection.
- Book X (Codex Zero) — 18 glossary-koans so Mom, Dad, and a 38-year-old
  brother who never opened a terminal can read the rest.
- ~30 new verses expanding Books III, IV, V, VII, VIII to 9 verses each.
- Colophon with a "trust receipt" for the reader (SHA-256 of the RU source).

## What was preserved verbatim

Every original verse from the `COMPLETE` txt files and books 6–8 survived,
polished lightly for cadence but not semantically altered. The probabilities
were preserved or added consistently. The closing *v5.9* — `openssl rand
-hex 32 … the breath of a new epoch` — remains the last verse of Book V, as
it always was, because it was already the best line in the corpus.

## Translation doctrine

**Russian canonical → English → Estonian**, in that order. English optimized
for *wordplay preservation* (e.g. "HSM of the soul" survived intact).
Estonian went for *rhythm and idiom*, not calque: "OCSP души" became "hinge
OCSP" with a half-beat of gloss where the joke needs it to breathe in a new
language.

Estonian was the hardest. Technical words mostly stay as loans (`pod`,
`namespace`, `YAML`, `pipeline`), but the metaphors around them are native
(`ühiskorter` for pod, `küpsisevabrik` for CI/CD). The `Nullkoodeks`
(Codex Zero) gets an Estonian reader into the book within fifteen minutes.

## What this taught me

1. **Structure is a form of love.** A flat folder of `.txt` files hides the
   shape of the idea. Splitting into numbered volumes with stable verse IDs
   makes every verse citable, translatable, oracle-queryable.

2. **Readability is a translation problem, even in one language.** The
   Mom/Dad/brother test forced me to write Book X, and that book is now my
   favourite.

3. **The Oracle is the book's real form.** Paper is a cache of the sūtra.
   The JSONL corpus + system prompt is the book *as a function*.

## Open threads

- Book XI — an audiobook read in all three languages. No plan yet.
- A second oracle mode: *hymnal* — no random improvisation, only exact verse
  lookup by tag and language. Useful as a meditation timer.
- Integration with Aletheia: each release of the book signs the corpus with
  a timestamped PQ certificate. (See
  [reflect/2026-02-11_eatf-market-context.md](https://github.com/sapsan14/life/blob/main/reflect/2026-02-11_eatf-market-context.md).)
- Parents' reading session. Record which verses land.

— Tallinn, 17 April 2026
