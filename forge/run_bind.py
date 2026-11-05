import argparse, json
from pathlib import Path
from .client import build_payload, complete
from .prompts import BIND_SYSTEM
from .schemas import BOUND_SKILL, SKILL, TASTE_CARD, validate

def render_brief(bound):
    b = bound["creative_brief"]
    lines = [f"# Creative brief — {bound['creator_id']}", "", b["summary"], "", "## Hero", "", b["hero"], "", "## Visual direction", "", b["visual_direction"], "", "## Sections", ""]
    lines += [f"- {x}" for x in b["sections"]]
    lines += ["", "## Voice", "", b["voice"], "", "## Decision bindings", ""]
    for x in bound["bindings"]: lines += [f"### {x['decision_id']}", "", x["decision"], "", f"Rationale: {x['rationale']}", "", f"Evidence: {', '.join(x['evidence_refs'])}", ""]
    return "\n".join(lines)

def bind(skill, taste, output, brief, dry_run=False):
    validate(skill, SKILL); validate(taste, TASTE_CARD)
    user = "Learned Skill:\n" + json.dumps(skill, indent=2) + "\nTasteCard evidence:\n" + json.dumps(taste, indent=2)
    payload = build_payload(BIND_SYSTEM, user, BOUND_SKILL, "bound_skill")
    if dry_run: print(json.dumps(payload, indent=2)); return None
    result, _ = complete(BIND_SYSTEM, user, BOUND_SKILL, "bound_skill"); validate(result, BOUND_SKILL)
    Path(output).parent.mkdir(parents=True, exist_ok=True); Path(output).write_text(json.dumps(result, indent=2) + "\n"); Path(brief).write_text(render_brief(result) + "\n")
    return result

def main():
    p = argparse.ArgumentParser(); p.add_argument("skill"); p.add_argument("tastecard"); p.add_argument("-o", "--output", default="out/bound.json"); p.add_argument("--brief", default="out/bound-brief.md"); p.add_argument("--dry-run", action="store_true")
    a=p.parse_args(); bind(json.loads(Path(a.skill).read_text()), json.loads(Path(a.tastecard).read_text()), a.output, a.brief, a.dry_run)
if __name__ == "__main__": main()
