#!/bin/zsh
# SkillForge v1 builder launcher — Codex headless on the master prompt.
export PATH="$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
cd "$HOME/skillforge" || exit 1
echo "LAUNCH-CODEX $(date -u +%Y-%m-%dT%H:%M:%SZ) pid $$" >> build.log
codex exec -C "$HOME/skillforge" --sandbox workspace-write --skip-git-repo-check - < BUILD.md >> build.log 2>&1
echo "EXIT $? $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> build.log
