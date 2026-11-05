"""JSON Schema contracts and a small standard-library validator."""

CONFIDENCE = {"type": "string", "enum": ["low", "medium", "high"]}
STRINGS = {"type": "array", "items": {"type": "string"}}

TEACH_EPISODE = {
    "type": "object", "additionalProperties": True,
    "required": ["schema_version", "episode_id", "skill_domain", "creator", "decision", "before", "action", "annotation", "after"],
    "properties": {
        "schema_version": {"type": "string"}, "episode_id": {"type": "string", "minLength": 1},
        "skill_domain": {"type": "string"}, "creator": {"type": "object", "required": ["id", "name"], "properties": {"id": {"type": "string"}, "name": {"type": "string"}}},
        "decision": {"type": "string", "enum": ["hero_asset", "visual_direction", "sections", "voice"]},
        "before": {"type": "object", "required": ["page_context"], "properties": {"screen_ref": {"type": "string"}, "page_context": {"type": "string", "minLength": 1}, "ax_summary": {"type": "string"}}},
        "action": {"type": "object", "required": ["summary"], "properties": {"summary": {"type": "string", "minLength": 1}, "selected_ref": {"type": "string"}}},
        "annotation": {"type": "object", "required": ["why", "reject"], "properties": {"why": {"type": "string", "minLength": 1}, "reject": {"type": "string"}, "confidence": CONFIDENCE}},
        "after": {"type": "object", "required": ["outcome"], "properties": {"screen_ref": {"type": "string"}, "outcome": {"type": "string", "minLength": 1}}},
        "provenance": {"type": "array", "items": {"type": "object", "required": ["source", "evidence"], "properties": {"source": {"type": "string"}, "evidence": {"type": "string"}}}}
    }
}

DECISION_RULE = {
    "type": "object", "additionalProperties": False,
    "required": ["decision_id", "name", "evidence", "inferred_rule", "anti_rules", "inputs_needed", "success_criteria", "confidence"],
    "properties": {
        "decision_id": {"type": "string"}, "name": {"type": "string"},
        "evidence": {"type": "array", "items": {"type": "object", "additionalProperties": False, "required": ["episode_id", "observed"], "properties": {"episode_id": {"type": "string"}, "observed": {"type": "string"}}}},
        "inferred_rule": {"type": "string"}, "anti_rules": STRINGS, "inputs_needed": STRINGS, "success_criteria": STRINGS, "confidence": CONFIDENCE
    }
}

SKILL = {
    "type": "object", "additionalProperties": False,
    "required": ["schema_version", "skill_id", "name", "learned_from", "purpose", "decisions", "global_anti_rules"],
    "properties": {"schema_version": {"type": "string"}, "skill_id": {"type": "string"}, "name": {"type": "string"}, "learned_from": STRINGS, "purpose": {"type": "string"}, "decisions": {"type": "array", "minItems": 4, "maxItems": 4, "items": DECISION_RULE}, "global_anti_rules": STRINGS}
}

TASTE_CARD = {
    "type": "object", "additionalProperties": False,
    "required": ["schema_version", "creator_id", "creator_name", "source_material", "observations", "constraints"],
    "properties": {
        "schema_version": {"type": "string"}, "creator_id": {"type": "string"}, "creator_name": {"type": "string"},
        "source_material": {
            "type": "object", "additionalProperties": False,
            "required": ["profile_url", "bio", "captions", "content_samples"],
            "properties": {
                "profile_url": {"type": "string"}, "bio": {"type": "string"}, "captions": STRINGS,
                "content_samples": {
                    "type": "array",
                    "items": {
                        "type": "object", "additionalProperties": False,
                        "required": ["ref", "type", "context"],
                        "properties": {"ref": {"type": "string"}, "type": {"type": "string"}, "context": {"type": "string"}}
                    }
                }
            }
        },
        "observations": {"type": "object", "additionalProperties": False, "required": ["recurring_topics", "recurring_language", "visual_signals", "audience_signals"], "properties": {"recurring_topics": STRINGS, "recurring_language": STRINGS, "visual_signals": STRINGS, "audience_signals": STRINGS}},
        "constraints": {"type": "object", "additionalProperties": False, "required": ["must_include", "must_avoid"], "properties": {"must_include": STRINGS, "must_avoid": STRINGS}}
    }
}

BOUND_SKILL = {
    "type": "object", "additionalProperties": False,
    "required": ["schema_version", "skill_id", "creator_id", "bindings", "creative_brief"],
    "properties": {
        "schema_version": {"type": "string"}, "skill_id": {"type": "string"}, "creator_id": {"type": "string"},
        "bindings": {"type": "array", "minItems": 4, "maxItems": 4, "items": {"type": "object", "additionalProperties": False, "required": ["decision_id", "rule", "decision", "rationale", "evidence_refs", "success_criteria", "confidence"], "properties": {"decision_id": {"type": "string"}, "rule": {"type": "string"}, "decision": {"type": "string"}, "rationale": {"type": "string"}, "evidence_refs": STRINGS, "success_criteria": STRINGS, "confidence": CONFIDENCE}}},
        "creative_brief": {"type": "object", "additionalProperties": False, "required": ["summary", "hero", "visual_direction", "sections", "voice"], "properties": {"summary": {"type": "string"}, "hero": {"type": "string"}, "visual_direction": {"type": "string"}, "sections": STRINGS, "voice": {"type": "string"}}}
    }
}

VERIFICATION = {
    "type": "object", "additionalProperties": False,
    "required": ["schema_version", "skill_id", "creator_id", "artifact", "checks", "overall"],
    "properties": {"schema_version": {"type": "string"}, "skill_id": {"type": "string"}, "creator_id": {"type": "string"}, "artifact": {"type": "object", "additionalProperties": False, "required": ["url", "screen_refs"], "properties": {"url": {"type": "string"}, "screen_refs": STRINGS}}, "checks": {"type": "array", "items": {"type": "object", "additionalProperties": False, "required": ["decision_id", "status", "criterion", "evidence", "revision"], "properties": {"decision_id": {"type": "string"}, "status": {"type": "string", "enum": ["PASS", "FAIL", "UNCERTAIN"]}, "criterion": {"type": "string"}, "evidence": {"type": "string"}, "revision": {"type": "string"}}}}, "overall": {"type": "string"}}
}

SCHEMAS = {"teach_episode": TEACH_EPISODE, "decision_rule": DECISION_RULE, "skill": SKILL, "taste_card": TASTE_CARD, "bound_skill": BOUND_SKILL, "verification": VERIFICATION}

def validate(value, schema, path="$"):
    """Validate the schema subset used here; return value or raise ValueError."""
    typ = schema.get("type")
    ok = {"object": isinstance(value, dict), "array": isinstance(value, list), "string": isinstance(value, str)}.get(typ, True)
    if not ok: raise ValueError(f"{path}: expected {typ}")
    if "enum" in schema and value not in schema["enum"]: raise ValueError(f"{path}: invalid value {value!r}")
    if isinstance(value, str) and len(value) < schema.get("minLength", 0): raise ValueError(f"{path}: too short")
    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0) or len(value) > schema.get("maxItems", 10**9): raise ValueError(f"{path}: invalid item count")
        for i, item in enumerate(value): validate(item, schema.get("items", {}), f"{path}[{i}]")
    if isinstance(value, dict):
        for key in schema.get("required", []):
            if key not in value: raise ValueError(f"{path}: missing {key}")
        props = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            extra = set(value) - set(props)
            if extra: raise ValueError(f"{path}: unexpected {sorted(extra)}")
        for key, item in value.items():
            if key in props: validate(item, props[key], f"{path}.{key}")
    return value
