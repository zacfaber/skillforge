# SkillForge — COURSE

Single source of truth for the project's course. Maintained by the build director (Claude Code, this repo).
Last audit: **Sat Oct 31 2026, ~06:00 PT**. Everything below is from files on disk at that time; nothing is graded by the director.

**Submit:** Wed Nov 4, 6:00 PM PT (internal target 3:00 PM) · **Build freeze:** Mon Nov 2, 9:00 PM PT · **Demo recording:** Tue Nov 3

---

## 1. The locked concept (do not redesign)

SkillForge learns a skill by watching a human work, extracts their judgment as rules and anti-rules, binds those rules to a new subject, and verifies the result.
Front door: a Muse widget companion beside fullscreen Minecraft that **watches → takes over (on command, incl. voice) → plays at human speed → gets paused, pointed at, corrected → revises the skill**.
Credibility core: **Skill 001**, a website-building skill forged from the TOOTRIPSY build and bound blind to Kyle (KO Fitness) and Festus.
Meta models are load-bearing: **Muse Spark** = reasoning core, **SAM** = on-demand visual segmentation.

---

## 2. Honesty gates — status today

| Gate | Claim allowed when… | Status | Evidence on disk |
|---|---|---|---|
| **L1 Forging is real** | Skill 001 + binds exist **and Zac has graded the 4 rules** | **Stands, pending Zac's grades** | `out/skill-001.json`; raw response `out/runs/forge-20261029T104623Z-…/response.json`, sha256 `0196f706…4285` re-verified today and matches `metadata.json`; `out/bound-kyle*.json/md`, `out/bound-festus*.json/md` |
| **L2 Companion watches and understands the game** | narration demonstrably matches a live session | **Not met** | `~/skilldrive/widget/narration.log` (459 lines) only reports the frontmost app ("Seeing: you're in Google Chrome."). No frame-based narration of game content exists yet. |
| **L3 It plays at human speed** | v0.4 daemon drives a **full task run** on the record | **Not met** | `~/skilldrive/v04/tape.jsonl` has 13 entries: desktop probes only (one look dx=50, shift/w holds, one dead man's release). **No Minecraft run yet.** |
| **L4 The replay loop improves the skill** | a pause-and-point correction produces a revised skill that changes the next run | **Not met** | `forge/review.py` is a text-only correction loop for website decisions. No replay viewer, no pause/point, no gameplay skill to revise. |

If a gate isn't met by freeze, **that claim narrows**. The project keeps its name and nothing gets fabricated.

---

## 3. What actually exists

**~/skillforge (owned by director)**
- Pipeline: `forge/{client,schemas,prompts,episodes,run_forge,run_bind,verify,review}.py`. Stdlib only. Key is read from `~/skilldrive/.env` when it runs.
- 4 TOOTRIPSY episodes (`episodes/`) with provenance. 2 evidence-only TasteCards (`tastecards/`).
- Skill 001 "Creator Site Judgment": 4 rules plus anti-rules, all marked confidence high by the model. These are **not grades**.
- Kyle bind: 2 of 4 bindings are confidence *low* (hero, sections), because the model flagged unconfirmed assets. Festus bind: hero is *low*.
- **Provenance problems:**
  - `BUILD-REPORT.md` is **stale and contradicts `out/`**. It says Forge failed on DNS (10:13Z Oct 29), but the successful Forge ran at 10:46Z, outside the logged Codex session.
  - `out-forge.log`, `out-bind-kyle.log` and `out-bind-festus.log` are all **0 bytes**.
  - Bind runs were **not archived** (no raw response or hash under `out/runs/`).
  - The git repo has **zero commits**.
- `verify.py` exists but has **never been run** against a real artifact.

**~/skilldrive (owned by Everest — read-only to director)**
- v0.3 accessibility-tree driver: running (`v03/skilldrive serve`, pid 98022).
- v0.4 `motiond`: running (pid 79265) on 127.0.0.1:47904, `ax_trusted=true`. Commands: ping, state, heartbeat, hold, release, release_all, tap, look (writes mouseEventDeltaX/Y), look_stream. 750 ms dead man's switch, 10 s hold cap. Writes a JSONL tape **of commands it executes**.
- MuseWidget.app: running (pid 62619), with the real Muse account embedded, a task watcher and a frontmost-app narrator. It already maps "Minecraft" as an app name.
- `capture` (Swift): grabs one window as a PNG through CGWindowListCreateImage. This could be the frame source.
- `.samvenv`: **empty**. No SAM, torch or weights are installed.
- No perception-spike files found on disk yet. Everest is building it.

**Hardware (affects the demo):** 2019 13" MacBook Pro, i5-8279U, 8 GB RAM, Iris Plus 655. Minecraft fullscreen, frame capture, the widget, Spark calls and screen recording will all run at once on this machine. Run Minecraft vanilla at low settings, **no shaders**, during capture and recording.

**Models on our Meta API key** (GET `/v1/models`, checked 10/31; read-only, no spend): `muse-spark-1.3` (+1.1, 1.2, contributor variants), **`sam-3.1`**, **`muse-voice-transcribe-1.0`**, `muse-image-1.0`, `muse-wonder-1.0`. SAM is a hosted API call, so nothing needs installing locally. "Glimmer" (named in the rules) doesn't appear as a model id; unknown what it maps to.

---

## 3a. Official rules: what changes the course (pasted by Zac 10/31)

**Judging:** Impact **30%** · Use of Meta AI tooling **25%** · Technical depth & execution **20%** · Demo **25%** (working, impressive, *holds up live*, video quality). Submit at cerebralvalley.ai/e/meta-ai-developer-hackathon/hackathon/submit. Indie track, solo. Help from AI tools and contractors is allowed as long as Zac owns the result.

What the rules mean for us:
- **Impact is the biggest weight, and it must "fit one of the problem statements."** Those statements are on the Event page, not in the rules, and **we don't have them yet.** The game is the demo vehicle. The impact story is "anyone can teach an agent a skill by doing it once, then correct it in plain words." Skill 001 (real creators, real sites) is the proof that this matters outside games. Pick the problem statement first, then write the pitch to it.
- **Meta tooling, 25%: "beyond basic integration, surface unexpected capabilities."** We can use four Meta models, each doing real work. **Spark** reasons, forges and plans. **SAM 3.1** locates named objects on demand. **muse-voice-transcribe** hears "take over" and the spoken correction mid-game, which the concept already calls for. The widget runs on **Muse** itself. The surprising capability to show: Spark forging *anti-rules* (what not to copy) from a human demonstration.
- **Demo "holds up live":** judges may ask for it live. Keep a fallback, a recorded clean run, and never present a recording as live.
- **Credits:** $150, **valid for a 10-day window from claim.** Zac: check the claim date. If it was claimed ~Oct 25, credits could expire **before Nov 4**. Do the Spark-heavy runs early and log the spend.
- **Rights and privacy (submission warrants "doesn't violate… privacy rights", and Meta gets a perpetual license to everything submitted):**
  - Kyle is a consented case study.
  - **Festus is an unsold pitch prospect.** Showing his name, likeness or content in a public submission needs his OK, or else blur or anonymize him.
  - The TOOTRIPSY creator (`~/nikhil-gupta-mock`) needs the same check.
  - Minecraft gameplay footage is fine for a video.
  - Nothing that ships may contain `.env`, keys or private client data.
- **Bonus prizes (community vote, most viral)** are announced ~Nov 10. A gameplay video works well for that. Posting it is Zac's call.

---

## 4. Gaps, ranked by whether they block a winning submission

### P0 — blocks the demo the concept promises
1. **No human-input recorder → the Skill 002 teach trace can't be captured as specified.** `motiond`'s tape only logs commands *it* sends. When Zac plays, nothing records his keys and mouse. Needs: a listen-only event tap (keys, buttons, mouse deltas, timestamps) plus synchronized frame capture (~2–4 fps) into one session folder. *Small build, about 2–3 h. Unblocks everything below.*
2. **No in-game perception (L2).** The narrator knows the app name, not the game. Needs: frame → Spark → one-line narration, logged with timestamps, then checked against a recording of the same session. *Everest owns this.*
3. **No gameplay executor (L3).** Nothing yet connects "what Spark sees" to "what motiond does" in Minecraft. Spark takes seconds per call, which is too slow to steer frame by frame. The realistic design: Spark picks the **next step** from the forged skill (e.g. "face the trunk, hold attack until the log drops"), and fast local loops run that step through motiond, checking frames between steps. Also unverified: whether Minecraft (Java, fullscreen, grabbed cursor) accepts motiond's injected deltas and holds. **Test this first, before building on it.**
4. **No gameplay skill schema / Skill 002.** Skill 001's schema is shaped around website decisions (hero, sections…). Skill 002 needs a gameplay episode shape (situation → action → why → reject) that the same Forge prompt rules can run on.

### P1 — needed for L4, the loop that is "the product"
5. **No replay + pause-and-point correction.** Minimum version: a local replay of frames + tape on one timeline, click a moment, type or speak the correction → forge revision (v2) → re-run that step on the record. This can be a plain local HTML page. It doesn't have to be inside the widget.
6. **Zac's grades are owed** for Skill 001's 4 rules, and the Festus back-test table (match / partial / miss) needs his grading too. Without them, L1 isn't fully claimable. *About 15 min of Zac's time.*

### P2 — credibility and hygiene (cheap, do early)
7. Rewrite `BUILD-REPORT.md` to match reality (Forge succeeded 10:46Z; record the hash and the bind outputs), and archive future bind runs.
8. First local commit of `~/skillforge` (provenance before the deadline crunch).
9. SAM: **use the hosted `sam-3.1`** for on-demand "find the tree / crafting table" calls. There's no local install, and the empty `.samvenv` can be ignored. Keep it out of the per-frame loop. Voice: route "take over" and spoken corrections through `muse-voice-transcribe-1.0`.
10. ~~Official rules~~ (received, see §3a). **Still missing:** the Event-page **problem statements**, the submit-form fields and video length limit, and Zac's **credit claim date**.
11. **Consent for Festus and the TOOTRIPSY creator** before they appear in public footage (§3a). Otherwise, anonymize them in the video.

### Not doing (would not change the outcome by Nov 4)
Game-state reading via mods, multi-task skills, a public deploy, widget restyling, more website binds.

---

## 5. Day-by-day plan

**Sat Oct 31 (today) — capture day**
- Director: P2 hygiene (#7, #8) once Zac says build. Write the listen-only teach recorder (#1) in `~/skillforge/teach/` so it doesn't touch Everest's `~/skilldrive`. Draft the gameplay episode schema (#4).
- Everest: perception spike, frame → Spark narration (#2). Run a 2-minute in-game motiond probe: does a look/hold actually move the player (#3 risk check)?
- Zac: grade Skill 001 + the Festus table (#6). **Play the teach job 2–3 times with the recorder on** (spawn → chop tree → planks → crafting table).
- Done when: ≥1 clean teach session folder exists with input + frames, and the in-game motiond probe has a pass/fail result.

**Sun Nov 1 — forge and first run**
- Forge **Skill 002** from the teach trace (one cold run, archived and hashed, like Skill 001).
- Executor v1: Spark chooses the next step from Skill 002, motiond executes it, frames confirm the result. Goal: **one full task run on the tape** (L3).
- L2 evidence: side-by-side of the narration log vs a screen recording of the same session.
- Checkpoint 9 PM: which of L2 and L3 are on the record?

**Mon Nov 2 — the loop, then freeze**
- Replay + pause/point correction (#5) → Skill 002 v2 → re-run the corrected step on the record (L4).
- SAM on-demand locate, if time allows (#9).
- **6 PM gate review** → lock the claims list. **9 PM build freeze.** After freeze: bug fixes only, no features.

**Tue Nov 3 — record**
- Demo script written **only from gates that passed**. Leads with the game; Skill 001 is the credibility core (30–45 s).
- Several takes, keeping raw footage. Write the submission text and README with a claims table that matches §2.

**Wed Nov 4 — submit**
- Final cut by noon. Zac reviews and **submits himself** by the 3:00 PM internal target (6:00 PM hard deadline).

---

## 6. Rules the director follows
- Read-only until Zac says build. Zac does the submission, sends and purchases himself.
- Never grade. Never fabricate. Claims stay capped at the gates in §2.
- `~/skilldrive` and the widget belong to Everest. Don't touch them, and don't disturb other sessions.
- Deploy safety: use a separate checkout or worktree if another session is active. Build and hash-compare before any push; if the hashes differ, stop and report. Watch any Action to completion.
- New work from Zac or Everest gets checked against this file first. If it doesn't serve the submission, say so plainly.
