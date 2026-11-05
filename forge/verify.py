import argparse, json
from pathlib import Path
from .client import build_payload, complete
from .prompts import VERIFY_SYSTEM
from .schemas import BOUND_SKILL, VERIFICATION, validate

def main():
    p=argparse.ArgumentParser(); p.add_argument("bound_skill"); p.add_argument("--text", default=""); p.add_argument("--text-file"); p.add_argument("--screenshot", action="append", default=[]); p.add_argument("--url", default=""); p.add_argument("-o", "--output", default="out/verification.json"); p.add_argument("--dry-run", action="store_true")
    a=p.parse_args(); bound=json.loads(Path(a.bound_skill).read_text()); validate(bound, BOUND_SKILL)
    page_text = Path(a.text_file).read_text() if a.text_file else a.text
    artifact = {"url": a.url, "screen_refs": a.screenshot}
    user = "BoundSkill:\n"+json.dumps(bound,indent=2)+"\nArtifact:\n"+json.dumps(artifact,indent=2)+"\nPage text:\n"+page_text
    payload=build_payload(VERIFY_SYSTEM,user,VERIFICATION,"verification")
    if a.dry_run: print(json.dumps(payload,indent=2)); return
    result,_=complete(VERIFY_SYSTEM,user,VERIFICATION,"verification"); validate(result,VERIFICATION); Path(a.output).parent.mkdir(parents=True,exist_ok=True); Path(a.output).write_text(json.dumps(result,indent=2)+"\n")
if __name__ == "__main__": main()
