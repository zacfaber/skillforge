# SKILLFORGE — PHASE 2 ORDER (content, runs, report)
You are the builder agent on Zac Faber's Mac, working in `~/skillforge`. The v1 pipeline code already exists here (forge/client.py, schemas.py, prompts.py, episodes.py, run_forge.py, run_bind.py, verify.py, review.py) from the previous run. That run stopped after writing code: there are NO episodes, NO tastecards, NO out/ artifacts, NO BUILD-REPORT.md. Your job is everything it skipped. Do not rewrite working code; fix only bugs that block the runs below, and note any fix in the report.

## Zac's rulings since the first order (these override BUILD.md where they differ)
1. The teaching episodes come from the TOOTRIPSY build (`~/nikhil-gupta-mock`, live tootripsy.fabersolutions.io) — his best and most well documented build. Not Festus.
2. Festus enters as the COLD BACK-TEST: his identity and brand are night-and-day from tootripsy's, and a finished Festus site exists as ground truth to grade against.

## Deliverable 1 — four teaching episodes from the tootripsy record
Decisions: `hero_asset`, `visual_direction`, `sections`, `voice`. Source record (all inside `~/nikhil-gupta-mock`, read-only): `BUILD-PROMPT.md`, `agency/` (strategy, direction, design-system, copy, asset-sources, Blue-Chip standard), `research/nikhil-brief.md`, `qa/` (build + review reports), `assets/grid/MANIFEST.md` + records.
Documented facts to build the episodes on:
- hero_asset: live drone-footage hero, full native resolution, creator's name in front; Zac rejected stills and soft crops and specified the re-cut (16:9 at source res, crf 18, full-res poster).
- visual_direction: "Apple-keynote restraint over a drone reel" — look derived from the creator's own content and persona.
- sections: the creator's short-version Story opens the scroll; then brands with real room; work; a signature full-bleed video moment; media kit; close. Ordering Zac corrected through review rounds.
- voice: first-person, the creator's cadence leveled up ("The postcards. Every trip turns into a postcard."); professional, never agency-speak; NO em dashes in copy (hard rule).
Write each episode to `episodes/<decision>.json` in the TeachEpisode schema. annotation.why = Zac's criteria as documented in his standards/review record — never invented rationale. annotation.reject = what must not generalize (drone footage, travel subject, this creator's palette/phrases). Add a `provenance` field citing the exact source files per episode.

## Deliverable 2 — two TasteCards (EVIDENCE ONLY — no recommended palette/hero/sections/voice anywhere)
- `tastecards/kyle.json` — Kyle Parker / KO Fitness: NASM-CPT, IRONMAN Florida 2026, coaching. Source: `~/kofitness-rebuild` on this machine (real content only; no invented stats or testimonials).
- `tastecards/festus.json` — Festus Feasts: former Warriors champion turned food creator; four story-led spots (Four Kings, Buttercup Diner, 9JaGrills, Chotto Matte) exist on his finished site. Build this card ONLY from creator-side evidence (his content, bio, the spots as HIS content pillars) — do NOT copy design decisions from the finished site into the card. The card is what a researcher could know before designing anything.

## Deliverable 3 — the runs (real Meta API calls, key from ~/skilldrive/.env at runtime, never printed)
1. Forge cold: `run_forge` on the 4 tootripsy episodes -> `out/skill-001.json` (+ archived raw response, sha256, UTC timestamp under out/runs/).
2. Bind Kyle: -> `out/bound-kyle.json` + `out/bound-kyle-brief.md`.
3. Bind Festus (blind back-test): -> `out/bound-festus.json` + `out/bound-festus-brief.md`. The bind sees ONLY Skill 001 + tastecards/festus.json.
If a run errors: capture the HTTP status + body verbatim into the report, retry only on 429/5xx, and continue with the remaining deliverables.

## Deliverable 4 — BUILD-REPORT.md
Must contain: files created this phase; the four inferred rules VERBATIM with their anti-rules; the Kyle bindings verbatim (decision + rationale); the Festus bindings verbatim; a back-test comparison table (Festus binding vs the real festus.fabersolutions.io decisions: hero, direction, sections, voice — match / partial / miss, with one line of evidence each); the pass-bar assessment (abstraction: >=3 of 4 rules intent-level and subject-free; anti-rules: >=3 meaningful; leakage check: no rule requires drone/travel/Nikhil specifics); every failure or code fix; total Meta API calls made.
Hard constraints remain: $0 spend, stdlib only, nothing outside ~/skillforge written, no processes killed, no pushes or deploys, key never echoed. One cold Forge run — do not re-prompt to improve the output after seeing it.
