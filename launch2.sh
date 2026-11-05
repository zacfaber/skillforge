#!/bin/zsh
# SkillForge phase 2 launcher — Codex headless on the phase 2 order.
export PATH="$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
cd "$HOME/skillforge" || exit 1
echo "LAUNCH-PHASE2 $(date -u +%Y-%m-%dT%H:%M:%SZ) pid $$" >> build.log
codex exec -C "$HOME/skillforge" --sandbox workspace-write --skip-git-repo-check - < PHASE2.md >> build.log 2>&1
echo "EXIT2 $? $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> build.log
