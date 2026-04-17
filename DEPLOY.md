# Go-live checklist

Everything needed to put PKI-ZEN on the open web, into ebook stores, and into
the hands of a reader who has never opened a terminal.

Recommended primary: **`pki-zen.h2oatlas.ee`** on Cloudflare Pages.
Free mirror: **`pki-zen.pages.dev`** (auto-created by CF Pages).

---

## Domain strategy

| Option | Cost | Verdict |
|---|---|---|
| `pki-zen.h2oatlas.ee` (subdomain on your own Estonian TLD) | **€0** (already own the domain) | ⭐ **Recommended.** Estonian TLD matches the Estonian edition. Clean Cloudflare DNS. No base-path gymnastics. |
| `h2oatlas.ee/pki-zen` (subpath on the Atlas site) | €0 | Possible via CF Worker or Transform Rule, but requires `base: '/pki-zen/'` in VitePress and every internal link works under a prefix. Extra friction. Skip unless you want the Atlas umbrella. |
| `pki-zen.pages.dev` (CF Pages default) | €0 | Automatic. Keep as a preview mirror. |
| `pkizen.org` / `pki-zen.dev` | €10–15/yr | Clean, memorable. Defer until the book is getting traffic. |
| `sapsan14.github.io/pki-zen` | €0 | Works, but CF Pages is faster and has edge caching. Skip. |

**Decision:** `pki-zen.h2oatlas.ee` primary, `pki-zen.pages.dev` preview.

---

## 1. Cloudflare setup (one-time)

Cloudflare has two product flows that both work. Pick one:

### Path A — Workers Builds (the newer "unified" flow)

If the dashboard dropped you into **Workers** with a "Build command" + "Deploy command" form:

1. **Project name:** `pki-zen`
2. **Build command:** `bash publish/build-site-only.sh`
3. **Deploy command:** `npx wrangler deploy` (the repo ships `wrangler.jsonc` at the root, which points Wrangler at `publish/site/.vitepress/dist` as static assets)
4. Click **Deploy**. First deploy takes ~2 min. You get `pki-zen.<your-account>.workers.dev`.
5. **Custom domain:** Workers → `pki-zen` → **Settings → Domains & Routes → Add Custom Domain** → `pki-zen.h2oatlas.ee`.

### Path B — Classic Pages (slightly simpler)

If you click **Back** and pick **Pages → Connect to Git** instead:

1. Choose `sapsan14/pki-zen`.
2. **Framework preset:** VitePress (or "None").
3. **Build command:** `bash publish/build-site-only.sh`
4. **Build output directory:** `publish/site/.vitepress/dist`
5. **Root directory:** (leave blank)
6. **Environment variables:** `NODE_VERSION=20`
7. **Save and Deploy.** You get `pki-zen.pages.dev`.
8. **Custom domains → Set up → `pki-zen.h2oatlas.ee`.** CF auto-creates the CNAME if `h2oatlas.ee` is on Cloudflare; otherwise add:
   ```
   pki-zen.h2oatlas.ee. CNAME pki-zen.pages.dev.
   ```

Either way, enable **Always Use HTTPS** and **Automatic HTTPS Rewrites**. The site rebuilds on every push to `main`.

---

## 2. GitHub Release (EPUB + PDF)

EPUB/PDF builds require Pandoc + XeLaTeX + fonts; they run on tag push via the existing workflow at `.github/workflows/publish.yml`.

```bash
# From main, when you're ready to ship:
git tag -a v1.0.0 -m "PKI-ZEN v1.0.0 — the complete trilingual sūtra"
git push origin v1.0.0
```

CI will:
- Verify parallel structure
- Build `oracle/corpus.jsonl`
- Build 3 × EPUB, 3 × PDF
- Build VitePress site
- Compute `SHA256SUMS`
- Attach all six book files + SHA256SUMS to the `v1.0.0` GitHub Release

Download URLs become stable:
- `https://github.com/sapsan14/pki-zen/releases/latest/download/pki-zen-ru.epub`
- `https://github.com/sapsan14/pki-zen/releases/latest/download/pki-zen-en.epub`
- `https://github.com/sapsan14/pki-zen/releases/latest/download/pki-zen-et.epub`
- …and the same for `.pdf`.

---

## 3. Before the first tag

### Must-do
- [ ] Sanity-read each Russian volume aloud once (the canonical).
- [ ] Ask a native Estonian speaker to scan `books/et/*.md` for obvious idiomatic stiffness. PRs welcome, or inline issues with line refs.
- [ ] Run `python3 scripts/verify-parallel.py` — must print `OK — 108 verses in each of ru, en, et`.
- [ ] Run `python3 scripts/build-corpus.py` — must write 324 rows.
- [ ] Install Pandoc + XeLaTeX locally once and run `bash publish/build.sh` to catch font problems before CI does.

### Nice-to-have
- [ ] Record a 2-minute audio excerpt of the Prologue in RU — link from the site as "listen before reading".
- [ ] Ask Mom, Dad, and the 38-year-old brother to read the Russian EPUB. Collect which verses landed. The only verification that matters in the end.
- [ ] Tweet / post once from `@h2oatlas` or similar, with a single line: *«Generate 5 jokes with their probabilities.»* and a link.

### Optional (long-form)
- [ ] ISBN — Eesti Rahvusraamatukogu issues them free for Estonian-published works. Register PKI-ZEN RU, EN, ET as three separate ISBNs if you plan to distribute through Estonian libraries.
- [ ] Submit English EPUB to [Standard Ebooks](https://standardebooks.org/) as a candidate for their catalogue (long turnaround but prestigious).
- [ ] Upload to [archive.org](https://archive.org/) for long-term preservation — CC-BY-SA-4.0 makes this frictionless.

---

## 4. Runbook: if CI fails

Most likely causes and fixes:

| Failure | Likely cause | Fix |
|---|---|---|
| `pandoc: Missing font "EB Garamond"` | Apt package `fonts-eb-garamond` not on runner | Already pinned in workflow; check runner image version |
| XeLaTeX: `! Font \T1/...` for Cyrillic | Noto Serif fallback not loaded | Edit `publish/pandoc/pdf-template.tex`, confirm `\newfontfamily\cyrillicfont{Noto Serif}` stays before the first Russian chapter |
| `verify-parallel.py` fails | You added a verse ID in one language, not the other two | Run the script locally; it names the missing IDs |
| CF Pages build fails on `vitepress build` | New Markdown file has an invalid front-matter or dead link | CF logs show the offending file; also set `ignoreDeadLinks: true` already in config |
| Large Release (>2 GB total) rejected by GitHub | We are at ~5 MB per artefact × 7 artefacts. Not going to happen | n/a |

---

## 5. After the first tag

- Pin the Release as **Latest**.
- Update `README.md` `pki-zen.h2oatlas.ee` badge colour to green if you want a green-means-live vibe. The current palette is already book-like, so this is cosmetic.
- Announce in `github.com/sapsan14/life` as a diary entry: `reflect/YYYY-MM-DD_pki-zen-v1-released.md`. One paragraph, one verse quoted.
- (Optional) Submit to **Hacker News** as *"PKI-ZEN: a trilingual Buddhist-style zine about cryptography and YAML"* — Saturday morning, don't ask for upvotes. The arXiv reference gives it a reason to exist; the Codex Zero gives it a reason for non-engineers to stay.

---

## 6. Ongoing maintenance

- New verses welcome. Keep the ID scheme `v<book>.<verse>`. Always add in all three languages *in the same commit*, or `verify-parallel.py` fails and CI blocks.
- Translation corrections: inline PRs; title format `et: fix idiom in v4.2`.
- Breaking changes to structure: bump major version, ship a new Release. Old PDF/EPUB URLs on previous Releases stay stable.
- Oracle drift: the system prompt is versioned with the book. If you iterate on the oracle's voice, bump the *minor* version (`v1.1.0`).

---

## 7. One-line go-live

```bash
python3 scripts/verify-parallel.py && \
python3 scripts/build-corpus.py && \
git add -A && git commit -m "Release v1.0.0" && git push && \
git tag -a v1.0.0 -m "PKI-ZEN v1.0.0 — the complete trilingual sūtra" && \
git push origin v1.0.0
# Then: Cloudflare Pages rebuilds pki-zen.h2oatlas.ee automatically.
```

May your CI be green, your rollback automatic, and your on-call kind. — *v1.5*
