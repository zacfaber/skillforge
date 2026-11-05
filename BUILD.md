# SKILLFORGE v1 — BUILD ORDER
You are the builder agent on Zac Faber's Mac. Build the SkillForge v1 pipeline in a NEW directory `~/skillforge`. Work only inside `~/skillforge`. Everything else on this machine is read-only reference. Read this whole order before starting.

## What SkillForge is
"Watch how I do this, and make it a skill." SkillForge learns transferable expert judgment from a human demonstration: Teach episodes -> Forge (Muse Spark infers the rules, including what NOT to generalize) -> Bind (apply the rules to a new creator's evidence) -> Verify (judge a produced artifact against the learned criteria). The product is the judgment layer. Deterministic tools execute; the model reasons and judges.

## What already exists (use it, do not rebuild it)
- Meta Model API: base `https://api.meta.ai/v1`, model `muse-spark-1.3` (standard tier), OpenAI-compatible chat completions, guaranteed JSON-schema response format is available. The API key lives in `~/skilldrive/.env` (read it at runtime; NEVER print it, log it, or write it into any file in ~/skillforge).
- SkillDrive v0.3 daemon is live (`~/skilldrive/v03/skilldrive ping` answers, served_by daemon). It is frozen infrastructure for this build: do not modify anything under `~/skilldrive`.
- Source material on this machine: the finished Festus Feasts site and its build record (locate them; start with `find ~ -maxdepth 3 -iname "*festus*" 2>/dev/null`), the KO Fitness preview build (search `*ko*fitness*` / `*kofitness*`), `~/nikhil-gupta-mock` (read-only; its `agency/` folder holds Zac's written quality standards), `~/chepheww` (read-only reference).

## Build these pieces (Python 3, standard library ONLY — no pip installs, no new services, $0 spend)
Directory layout:
```
~/skillforge/
  forge/__init__.py
  forge/client.py     — Meta API client (urllib), key from ~/skilldrive/.env, model muse-spark-1.3, generous max_tokens (Spark always reasons; 9000 is a known-good budget), JSON-schema response format support, retries on 429/5xx only
  forge/schemas.py    — the six schemas as JSON Schema dicts (below)
  forge/prompts.py    — forge / bind / verify system prompts (your authorship, rules below)
  forge/episodes.py   — load + validate TeachEpisode JSON files
  forge/run_forge.py  — episodes -> Spark -> Skill JSON; archives raw response + sha256 + UTC timestamp under out/runs/
  forge/run_bind.py   — Skill + TasteCard -> BoundSkill JSON + rendered creative brief (markdown)
  forge/verify.py     — BoundSkill criteria + target page text/screenshot path -> Verification JSON
  forge/review.py     — the correction loop: print each inferred rule + anti-rules, accept typed corrections per decision, re-run Forge for corrected decisions only, version the Skill (v1, v2...)
  episodes/           — the four teaching episodes you author (below)
  tastecards/kyle.json
  out/                — generated artifacts
  BUILD-REPORT.md     — your final report (below)
```

## The six schemas (field shapes are the contract; types/required are yours to tighten sensibly)
- TeachEpisode: schema_version, episode_id, skill_domain, creator{id,name}, decision, before{screen_ref,page_context,ax_summary}, action{summary,selected_ref}, annotation{why,reject}, after{screen_ref,outcome}. Minimally required: episode_id, decision, before.page_context, action.summary, annotation.why, after.outcome.
- DecisionRule: decision_id, name, evidence[{episode_id,observed}], inferred_rule, anti_rules[], inputs_needed[], success_criteria[], confidence (low|medium|high — never numeric).
- Skill: schema_version, skill_id, name, learned_from[episode_ids], purpose, decisions[DecisionRule x4], global_anti_rules[].
- TasteCard: schema_version, creator_id, creator_name, source_material{profile_url,bio,captions[],content_samples[{ref,type,context}]}, observations{recurring_topics[],recurring_language[],visual_signals[],audience_signals[]}, constraints{must_include[],must_avoid[]}. TasteCard is EVIDENCE ONLY: no recommended palette/hero/sections/voice anywhere in it — recommendations belong to BoundSkill, or the transfer test is contaminated.
- BoundSkill: schema_version, skill_id, creator_id, bindings[{decision_id, rule, decision, rationale, evidence_refs[], success_criteria[], confidence}], creative_brief{summary,hero,visual_direction,sections[],voice}.
- Verification: schema_version, skill_id, creator_id, artifact{url,screen_refs[]}, checks[{decision_id,status(PASS|FAIL|UNCERTAIN),criterion,evidence,revision}], overall. UNCERTAIN must exist: never force a judgment the evidence cannot support.

## Prompt rules (forge / bind / verify)
- Forge system prompt must: demand the distinction OBSERVED vs TRANSFERABLE RULE vs ANTI-RULE vs SUCCESS CRITERIA per decision; forbid generalizing demonstration-specific nouns, colors, image types, layouts, subjects, or phrases; prefer intent over mechanism; treat human annotation as high-value evidence but narrow it to the smallest justified principle; require an explicit anti-rule per decision ("what would a naive replay copy that must NOT transfer?"); forbid binding to any new creator (learning stage only); return ONLY schema-valid JSON. CRITICAL: the prompt must not contain, hint at, or enumerate the expected rules. The model does not get the answer key.
- Bind system prompt must: apply the SAME rules to the new creator's evidence ONLY; demonstration-specific details have zero authority; every binding cites evidence_refs; insufficient evidence -> say so, confidence low; the creative brief must be executable by a coding agent with no access to the demonstration; return ONLY schema-valid JSON.
- Verify system prompt must: judge the artifact against the BoundSkill success criteria one by one, cite observable evidence per check, use UNCERTAIN when evidence is insufficient, and on FAIL write a specific revision request (what to change, in the direction of the rule).

## The four teaching episodes (author from the REAL Festus build)
Decisions: `hero_asset`, `visual_direction`, `sections`, `voice` — all from Zac's Festus Feasts build (finished site: festus.fabersolutions.io; four story-led features: Four Kings, Buttercup Diner, 9JaGrills, Chotto Matte).
- Ground every episode in locatable evidence: the build record on this machine, the live site, and Zac's written standards in `~/nikhil-gupta-mock/agency/` (his quality standard documents). Cite the source in a `provenance` field per episode.
- annotation.why must express Zac's actual decision criteria as documented in his standards and the build's observable choices — do NOT invent plausible-sounding rationale that no document supports. Where the record is thin, keep the annotation to what the evidence shows and mark confidence accordingly. Zac grades and corrects these himself in the review loop; your job is faithful records, not flattering ones.
- annotation.reject: what must not be generalized from this episode (e.g., the specific subject matter of the demonstration creator).

## Kyle TasteCard (evidence only)
Kyle Parker, KO Fitness: NASM-CPT, IRONMAN Florida 2026, personal training / coaching, Zac's consented case study; a preview site with a working intake agent already exists (locate its build record on this machine for content samples). Fill source_material and observations from that real material only. No invented stats, no invented testimonials.

## Acceptance run (do this before writing the report)
1. `run_forge` on the four episodes -> `out/skill-001.json` (+ archived raw response with hash + timestamp).
2. `run_bind` Skill 001 + Kyle TasteCard -> `out/bound-kyle.json` + `out/bound-kyle-brief.md`.
3. Print in the report: the four inferred rules VERBATIM, their anti-rules, and the four Kyle bindings (decision + rationale) verbatim.
Pass bar (report honestly against it, do not tune prompts to force a pass after seeing output — one cold run, graded as-is): at least 3 of 4 rules are genuine abstractions (intent-level, would survive a total change of subject), at least 3 have meaningful anti-rules, and no rule requires the demonstration creator's subject matter, palette, or voice.

## Hard constraints
- DEPLOY-SAFETY: if another session/agent is active in any repo you touch, work in a separate checkout — here: work ONLY in `~/skillforge`, which is yours alone. Do not push anything anywhere (local git init + local commits are fine and encouraged for provenance). No deploys.
- $0 SPEND: no purchases, no signups, no pip installs. Meta API calls use the existing key only.
- Do not kill, restart, or disturb any running process (other build chains may be active on this machine — coexist).
- Secrets: the API key is read from `~/skilldrive/.env` at runtime only. If it appears in any output or log, stop and report.
- If the Meta API call fails: report the HTTP status and body verbatim in BUILD-REPORT.md and continue building everything that does not depend on it (schemas, prompts, episodes, CLI plumbing with a --dry-run mode that prints the exact request payload).

## BUILD-REPORT.md must contain
Files created (tree), how to run each command, the acceptance-run results verbatim (rules, anti-rules, Kyle bindings), pass-bar assessment per criterion, every failure or workaround, and total Meta API calls made.
