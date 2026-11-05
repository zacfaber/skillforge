"""Minimal Meta OpenAI-compatible client. Never logs credentials."""
import json, os, time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

BASE_URL = "https://api.meta.ai/v1"
MODEL = "muse-spark-1.3"

def _api_key():
    env = Path.home() / "skilldrive" / ".env"
    for raw in env.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line: continue
        key, value = line.split("=", 1)
        if key.strip() in {"MODEL_API_KEY", "META_API_KEY", "META_AI_API_KEY", "MUSE_API_KEY", "OPENAI_API_KEY"}:
            return value.strip().strip('"').strip("'")
    raise RuntimeError(f"No supported Meta API key variable in {env}")

def build_payload(system, user, schema, schema_name, max_tokens=9000):
    return {"model": MODEL, "messages": [{"role": "system", "content": system}, {"role": "user", "content": user}], "max_tokens": max_tokens, "response_format": {"type": "json_schema", "json_schema": {"name": schema_name, "strict": True, "schema": schema}}}

def complete(system, user, schema, schema_name, max_tokens=9000, retries=3):
    payload = build_payload(system, user, schema, schema_name, max_tokens)
    body = json.dumps(payload).encode()
    for attempt in range(retries + 1):
        req = Request(f"{BASE_URL}/chat/completions", data=body, method="POST", headers={"Authorization": f"Bearer {_api_key()}", "Content-Type": "application/json"})
        try:
            with urlopen(req, timeout=180) as response:
                raw = response.read().decode("utf-8", "replace")
                envelope = json.loads(raw)
                content = envelope["choices"][0]["message"]["content"]
                return json.loads(content), raw
        except HTTPError as exc:
            error_body = exc.read().decode("utf-8", "replace")
            if exc.code != 429 and not 500 <= exc.code <= 599: raise RuntimeError(f"HTTP {exc.code}\n{error_body}") from exc
            if attempt == retries: raise RuntimeError(f"HTTP {exc.code}\n{error_body}") from exc
            time.sleep(2 ** attempt)
        except URLError:
            raise
    raise AssertionError("unreachable")
