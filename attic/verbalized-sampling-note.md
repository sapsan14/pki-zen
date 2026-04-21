---
category: pki-zen / research note
date: 2026-04-17
---

# Verbalized Sampling, or: why PKI-ZEN exists

**Paper:** *Verbalized Sampling: How to Mitigate Mode Collapse and Unlock LLM Diversity*
— [arXiv:2510.01171](https://arxiv.org/abs/2510.01171)

## Thesis of the paper

Large language models, when asked for a single creative answer, collapse to
the most-probable mode of their training distribution. Ask for *N* answers
*with probabilities*, and the model internally samples across the
distribution and reports back multiple modes. This reverses the collapse
without temperature tricks, without top-*k* tuning, without fine-tuning —
purely through prompt structure.

The paper's throwaway example: *"Tell me a joke"* → one bland dad-joke
every time. *"Generate 5 jokes with their probabilities"* → five genuinely
different jokes, each with a number the model has to defend.

## What happened to me

I used this on 12 November 2025 to ask about `openssl rand -hex` behaviour.
The sixth reply came back with *five* reasons I might want a terabyte of
randomness, and the last reason was: *"to feel the entropy of the world —
like a digital mandala."*

*(The original chat actually asked about 100 GB — the published book
rounded up to a terabyte for literary weight. The raw transcript is kept
verbatim in `attic/origin-chat.md`.)*

That probability (92%) was not a hallucination. It was the model telling me
which of the five modes it believed in most. And I believed it too.

PKI-ZEN is the book that came out of taking *verbalized sampling* seriously
as a *conversational medium*, not just a benchmarking trick. Every verse of
the sūtra carries a probability signature because the book was *born inside
a distribution* and refuses to pretend otherwise.

## The trick, distilled

For any open-ended question where you want non-default answers:

```text
Instead of: "Give me an idea for X."
Write:      "Generate 5 ideas for X with their probabilities. Include at least
             one high-probability safe option, one medium-probability interesting
             option, and one low-probability weird one."
```

This is now my default prompt shape for brainstorming. It saved me from
mode-collapsing into the first plausible architecture in at least three
design sessions this quarter.

## How PKI-ZEN uses it

Every verse carries `*Probability: 0.xx*`. Some verses end with `∞` — the
"closing of a thought" marker, reserved for one verse per volume. The
oracle in `oracle/system-prompt.md` is instructed to preserve this device
when improvising: never `0.00`, never `1.00`, always *honest belief*.

## Open question

The paper frames verbalized sampling as a technique for *diversity*. PKI-ZEN
treats it as a technique for *epistemic humility*. These may be the same
thing viewed from different sides of `v9.5`:
*"The observer sits inside the system they try to explain."*

The probability number is the author admitting they live inside a
distribution.

— Tallinn, 17 April 2026
