# SkillForge

**Watch once, learn the skill, drive the computer, take correction.**

SkillForge learns a skill by watching a human work. It extracts the human's
judgment as explicit rules and anti-rules, binds those rules to a brand-new
subject it has never seen worked on, and verifies the result. The human stays
in the loop as grader: corrections are authoritative and produce the next
version of the skill.

The reasoning core is Meta's **Muse Spark** (`muse-spark-1.3` via the Meta
Model API). Every forge, bind, and verify run is a live Spark call with a
strict JSON schema — and every forged skill carries its evidence with it.

## Skill 001 — the proof

Skill 001 is a website-building judgment skill, forged on Oct 29, 2026 from
the build record of a real creator site (TOOTRIPSY). The build was decomposed
into four teaching episodes — one per decision the builder actually made:

| Episode | Decision |
|---|---|
| `episodes/hero_asset.json` | Hero Asset Judgment |
| `episodes/sections.json` | Sections Sequence Judgment |
| `episodes/visual_direction.json` | Visual Direction Judgment |
| `episodes/voice.json` | Voice Judgment |

The forge produced four rules (all confidence: high), each with anti-rules —
the failure modes the human had corrected during the original build — plus
global anti-rules against transferring demonstration-specific assets, palettes,
phrases, or layouts to another creator. See `out/skill-001.json`.

The skill was then **bound blind** to two creators it had never seen, from
evidence cards only (`tastecards/`): Festus Feasts and Kyle Parker / KO
Fitness (`out/bound-festus.json`, `out/bound-kyle.json`, with human-readable
briefs beside them). The pattern across both binds: judgment bound at high
confidence exactly where the creator's own record was rich, and dropped to
low confidence with an explicit hold exactly where evidence was missing
(e.g. hero photo licensing) — the gap was flagged, never filled by invention.

A back-test compared the blind Festus bind against the real, finished Festus
Feasts site: story-first structure, distinct venue proof, signature moment,
inquiry close, and voice discipline matched; the hero *form* and the palette
differed (the real hero is an intimate portrait opposite a headline, not the
predicted full-bleed table moment).

On Oct 31, 2026 the human grader — Zac Faber — officially graded and amended
all four rules. That grading record is `GRADES.md`, and it governs all future
binds.

## Telepathy and Grapefruit: the DJ proof

The widget's second domain. Telepathy (in `telepathy/`) is a live set console the widget built at my direction, much of the build driven from my phone by voice and text while I was away from the desk. Under the interface is a real time analysis bus inside a SuperCollider audio engine: RMS, peak, and six band energies streamed into the page ten times a second. The interface is not simulating the music; it is downstream of it.

Grapefruit (in `grapefruit/`) is the set I conducted through it. My calls, in plain English, one gate at a time, every call logged with my verdict (keep or kill), my own words, and timestamps. The log is a labeled dataset of one person's taste, and it compounds: "turn it down a tad" has a number, and the system knows it because I taught it. I ship changes to my computer from the gym the same way. The widget changed how I use a computer.

## Repo layout

```
episodes/     Teaching episodes decomposed from the demonstration build
tastecards/   Evidence cards for new creators (the bind inputs)
forge/        The pipeline package (stdlib-only Python)
  client.py     Meta Model API client (Muse Spark, strict JSON schema)
  run_forge.py  Episodes        -> a forged skill
  run_bind.py   Skill + card    -> a bound skill + creative brief
  verify.py     Bound skill + artifact -> per-criterion PASS/FAIL/UNCERTAIN
  review.py     Human correction loop -> next skill version
  schemas.py    JSON schemas + validation for every artifact
  prompts.py    System prompts for forge / bind / verify
out/
  skill-001.json          The forged skill
  bound-festus.json/md    Blind bind #1 + brief
  bound-kyle.json/md      Blind bind #2 + brief
  runs/                   Archived forge runs (raw response + sha256 metadata)
GRADES.md       The human grading record for Skill 001
COURSE.md       Project course-keeping and honesty-gate audit (director)
BUILD.md, PHASE2.md, BUILD-REPORT.md   Build records
```

## Setup

Requirements: Python 3.13 (any recent Python 3 works; the package is
standard-library only — no pip installs).

### With a Meta Model API key (live runs)

The pipeline reads its key from `~/skilldrive/.env` — see `.env.example` in
this repo:

```sh
cp .env.example ~/skilldrive/.env
# edit ~/skilldrive/.env and set:
#   MODEL_API_KEY=<your Meta Model API key>
chmod 600 ~/skilldrive/.env
```

**Never commit a real key.** `.env.example` ships empty on purpose.

Run everything as modules from the repo root:

```sh
# Forge a skill from teaching episodes
python3 -m forge.run_forge episodes -o out/skill-001.json

# Bind the skill to a new creator from their taste card
python3 -m forge.run_bind out/skill-001.json tastecards/kyle.json \
    -o out/bound-kyle.json --brief out/bound-kyle-brief.md

# Verify a bound skill against a real artifact (page text + URL)
python3 -m forge.verify out/bound-kyle.json \
    --url https://example.com --text-file page-text.txt \
    -o out/verification.json

# Human correction loop (interactive; produces the next skill version)
python3 -m forge.review out/skill-001.json episodes
```

Every command accepts `--dry-run`, which validates inputs and prints the
exact API payload without making a call.

### Keyless mode (judges: evaluate without a live key)

SkillForge's claims are checkable from recorded runs alone — no API key and
no live call required:

1. **The forged skill** — `out/skill-001.json`: all four rules, anti-rules,
   success criteria, and the episode evidence each rule was inferred from.
2. **Forge run provenance** — `out/runs/forge-20261029T104623Z-0196f7065367/`
   holds the archived raw model response (`response.json`) and `metadata.json`
   with its sha256 (`0196f706…4285`), re-verified Oct 31, 2026. Hash the raw
   response yourself; it matches the skill it produced.
3. **The blind binds** — `out/bound-festus.json` and `out/bound-kyle.json`
   plus their briefs show what the skill predicted for two unseen creators,
   including where it lowered its own confidence and held for missing
   evidence instead of inventing assets.
4. **The back-test** — the Festus bind was scored against the real finished
   site's own design record: 8 criteria checked, with the hero-form and
   palette divergences recorded as divergences, not smoothed over.
5. **The human grades** — `GRADES.md`: Zac's official grades and amendments
   to all four rules, Oct 31, 2026.
6. **Schema check, still keyless** — any pipeline command with `--dry-run`
   validates every artifact against its JSON schema and prints the payload
   that *would* be sent, without calling the API.

A full evidence pack (verbatim rules, the complete back-test table, the Kyle
bind summary, and a plain statement of the remaining gaps) accompanies the
submission.

## The loop, in one line

Demonstration → episodes → forged skill → blind bind → verify → human
grades and corrections → next version. Nothing in this repo claims a gate it
hasn't met; `COURSE.md` keeps the audit.
