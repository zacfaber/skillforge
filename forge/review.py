import argparse, json, re
from pathlib import Path
from .episodes import load_episodes
from .run_forge import forge

def main():
    p=argparse.ArgumentParser(); p.add_argument("skill"); p.add_argument("episodes"); p.add_argument("--out-dir",default="out"); a=p.parse_args()
    path=Path(a.skill); skill=json.loads(path.read_text()); corrections={}; changed=set()
    for d in skill["decisions"]:
        print(f"\n[{d['decision_id']}] {d['inferred_rule']}")
        for x in d["anti_rules"]: print(f"  ANTI-RULE: {x}")
        answer=input("Correction (Enter accepts): ").strip()
        if answer: corrections[d["decision_id"]]=answer; changed.add(d["decision_id"])
    if not changed: print("No corrections; no new version created."); return
    match=re.search(r"v(\d+)", path.stem); version=(int(match.group(1))+1 if match else 2)
    output=Path(a.out_dir)/f"{path.stem.split('-v')[0]}-v{version}.json"
    result=forge(load_episodes(a.episodes),output,only=changed,prior=skill,corrections=corrections)
    result["schema_version"]=f"v{version}"; output.write_text(json.dumps(result,indent=2)+"\n"); print(output)
if __name__ == "__main__": main()
