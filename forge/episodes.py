import json
from pathlib import Path
from .schemas import TEACH_EPISODE, validate

def load_episodes(path):
    files = sorted(Path(path).glob("*.json")) if Path(path).is_dir() else [Path(path)]
    if not files: raise ValueError(f"No episode JSON files in {path}")
    episodes = [validate(json.loads(file.read_text()), TEACH_EPISODE) for file in files]
    ids = [item["episode_id"] for item in episodes]
    if len(ids) != len(set(ids)): raise ValueError("Duplicate episode_id")
    return episodes
