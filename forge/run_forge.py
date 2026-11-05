import argparse, hashlib, json
from datetime import datetime, timezone
from pathlib import Path
from .client import build_payload, complete
from .episodes import load_episodes
from .prompts import FORGE_SYSTEM
from .schemas import SKILL, validate

def forge(episodes, output, dry_run=False, only=None, prior=None, corrections=None):
    selected = [e for e in episodes if not only or e["decision"] in only]
    user = "Teaching episodes:\n" + json.dumps(selected, indent=2)
    if prior is not None: user += "\nPrior Skill (retain unselected decisions):\n" + json.dumps(prior, indent=2)
    if corrections: user += "\nHuman corrections (authoritative for the named decisions):\n" + json.dumps(corrections, indent=2)
    payload = build_payload(FORGE_SYSTEM, user, SKILL, "skill")
    if dry_run:
        print(json.dumps(payload, indent=2)); return None
    result, raw = complete(FORGE_SYSTEM, user, SKILL, "skill")
    validate(result, SKILL)
    if only and prior:
        replacements = {d["decision_id"]: d for d in result["decisions"]}
        result["decisions"] = [replacements.get(d["decision_id"], d) if d["decision_id"] in only else d for d in prior["decisions"]]
        result["skill_id"] = prior["skill_id"]
        validate(result, SKILL)
    out = Path(output); out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    digest = hashlib.sha256(raw.encode()).hexdigest()
    archive = out.parent / "runs" / f"forge-{stamp}-{digest[:12]}"
    archive.mkdir(parents=True, exist_ok=False)
    (archive / "response.json").write_text(raw)
    (archive / "metadata.json").write_text(json.dumps({"utc_timestamp": stamp, "sha256": digest, "output": str(out)}, indent=2) + "\n")
    return result

def main():
    p = argparse.ArgumentParser(); p.add_argument("episodes"); p.add_argument("-o", "--output", default="out/skill-001.json"); p.add_argument("--dry-run", action="store_true")
    a = p.parse_args(); forge(load_episodes(a.episodes), a.output, a.dry_run)
if __name__ == "__main__": main()
