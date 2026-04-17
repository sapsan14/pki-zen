# /attic — staged for github.com/sapsan14/life

These files do not belong in the published book, but they are too interesting
to discard. They are the *scaffolding around the sūtra*: the chat that birthed
it, the process notes of its April refactor, and the research pointer.

They are staged here so you, the Author, can port them into
[github.com/sapsan14/life](https://github.com/sapsan14/life) as diary
reflections. Each file declares its destination on the top line.

## Manifest

| Source here | Destination in `life` repo | Why |
|---|---|---|
| `origin-chat.md` | `reflect/2025-11-12_pki-zen-origin-chat.md` | Primary source — the ChatGPT dialogue from which the sūtra grew. Preserve verbatim. |
| `author-process.md` | `reflect/2026-04-17_pki-zen-refactor.md` | Meta-diary: this editorial refactor, as a diary entry. |
| `verbalized-sampling-note.md` | `reflect/2026-04-17_verbalized-sampling-pki-zen.md` | Commentary on arXiv:2510.01171 and why *"five jokes with probabilities"* matters as a prompt technique. |

## Porting

Suggested workflow:

```bash
# from the root of the life repo
cp ../pki-zen/attic/origin-chat.md            reflect/2025-11-12_pki-zen-origin-chat.md
cp ../pki-zen/attic/author-process.md         reflect/2026-04-17_pki-zen-refactor.md
cp ../pki-zen/attic/verbalized-sampling-note.md reflect/2026-04-17_verbalized-sampling-pki-zen.md

# update TOPICS.md to point at these three new reflections under the PKI-ZEN topic
```

Then remove `/attic` from `pki-zen` once ported, or leave it as a reading
trail. Your choice.

## A small note on recursion

Moving `/attic` to `life` *and* leaving a short polished version as
`books/*/99-appendix-origin.md` here is not duplication — it is the same
thing at two different levels of observability. The book contains the
*story*; the life repo contains the *evidence*. In the spirit of `v9.7`:
*aletheia* means *the unhidden*.
