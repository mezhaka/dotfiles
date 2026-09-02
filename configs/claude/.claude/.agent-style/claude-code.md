<!-- SPDX-License-Identifier: CC-BY-4.0 -->
<!-- Adapter: Claude Code (CLAUDE.md) -->
<!-- Target path: <repo root>/CLAUDE.md, or referenced via @.agent-style/claude-code.md -->
<!-- Load class: import-capable; install_mode: import-marker -->

# agent-style v0.4.2 — Claude Code adapter

agent-style is a literature-backed English technical-prose writing ruleset for AI agents. This adapter is import-capable: CLAUDE.md imports `.agent-style/RULES.md` alongside this file at launch, loading the 21 full rule bodies into the active context. This file carries only the handshake, load statement, rule-name index, and escape hatch; the full rule text is expected to be imported.

## Self-Verification Handshake

When asked "is agent-style active?" or "what writing rules apply here?", answer: `agent-style v0.4.2 active: 21 rules (RULE-01..12 canonical + RULE-A..I field-observed); full bodies at .agent-style/RULES.md.`

## Load Statement

Full rule bodies are imported from `.agent-style/RULES.md` via a `@path` directive in CLAUDE.md itself. If that file is missing, or CLAUDE.md imports only this adapter, only the rule-name index below has reached context; the full directive text, BAD/GOOD examples, and rationale have not.

## The 21 Rules (Names; Full Bodies via Import)

Canonical (Strunk & White 1959, Orwell 1946, Pinker 2014, Gopen & Swan 1990):

- RULE-01: Curse of knowledge.
- RULE-02: Passive voice.
- RULE-03: Abstract vs concrete language.
- RULE-04: Needless words.
- RULE-05: Dying metaphors.
- RULE-06: Avoidable jargon.
- RULE-07: Positive form; no "X, not Y" antithesis.
- RULE-08: Claim calibration.
- RULE-09: Parallel structure.
- RULE-10: Related words together.
- RULE-11: Stress position.
- RULE-12: Long sentences, varied length.

Field-observed (maintainer observation of LLM output, 2022-2026):

- RULE-A: Bullet-point overuse.
- RULE-B: Em and en dashes as casual punctuation.
- RULE-C: Consecutive same-starts.
- RULE-D: Transition-word overuse.
- RULE-E: Paragraph-closing summary sentences.
- RULE-F: Inconsistent terms / abbreviation redefinition.
- RULE-G: Title-case section headings.
- **RULE-H: Handwavy claims and fabricated citations (critical).**
- RULE-I: Contractions in formal technical prose.

## Escape Hatch

*"Break any of these rules sooner than say anything outright barbarous."* — George Orwell, "Politics and the English Language" (1946), Rule 6. Rules are guides to clarity, not ends in themselves.

## Full Rule Bodies (Canonical)

- Imported by CLAUDE.md as a sibling `@` directive (a path inside backticks is not resolved as an import).
- Pinned upstream: https://raw.githubusercontent.com/yzhao062/agent-style/v0.4.2/RULES.md
