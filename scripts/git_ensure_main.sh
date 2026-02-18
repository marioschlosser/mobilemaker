#!/bin/bash
# Ensures we're on main branch and cleans up orphaned staging branches/worktrees
# Run this at the start of any Claude session or as a hook

set -e

# Skip cleanup when running inside an automated agent job (worktree is intentional)
if [ "${AGENT_JOB:-}" = "1" ]; then
    echo "[GIT CLEANUP] Skipping (inside agent job)"
    exit 0
fi

cd "$(dirname "$0")/.."

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if we're on a staging branch (shouldn't happen with worktrees, but handle legacy)
if [[ "$CURRENT_BRANCH" == agent-staging-* ]]; then
    echo "[GIT CLEANUP] WARNING: On staging branch '$CURRENT_BRANCH', switching to main..."

    # Abort any in-progress merge
    git merge --abort 2>/dev/null || true

    # Force checkout to main (discards uncommitted changes on staging branch)
    git checkout -f main

    echo "[GIT CLEANUP] Switched to main"
fi

# Clean up orphaned staging branches (local) - only those without active worktrees
OLD_STAGING=$(git branch --list 'agent-staging-*' 2>/dev/null || true)
if [ -n "$OLD_STAGING" ]; then
    echo "[GIT CLEANUP] Removing orphaned staging branches..."
    for branch in $OLD_STAGING; do
        branch=$(echo "$branch" | tr -d ' *')
        # Check if this branch has an active worktree
        WORKTREE=$(git worktree list --porcelain 2>/dev/null | grep -A1 "branch refs/heads/$branch" | head -1 || true)
        if [ -z "$WORKTREE" ]; then
            git branch -D "$branch" 2>/dev/null || true
        else
            echo "[GIT CLEANUP] Skipping branch '$branch' (active worktree)"
        fi
    done
fi

# Clean up orphaned worktrees
git worktree prune 2>/dev/null || true

# Remove empty .worktrees directory if it exists and is empty
if [ -d ".worktrees" ] && [ -z "$(ls -A .worktrees 2>/dev/null)" ]; then
    rmdir .worktrees 2>/dev/null || true
fi

# Clean up orphaned agent stashes (drop from highest index to lowest to avoid shifting)
AGENT_STASH_INDICES=$(git stash list 2>/dev/null | grep -n "Pre-agent-job-" | cut -d: -f1 || true)
if [ -n "$AGENT_STASH_INDICES" ]; then
    STASH_COUNT=$(echo "$AGENT_STASH_INDICES" | wc -l | tr -d ' ')
    echo "[GIT CLEANUP] Dropping $STASH_COUNT orphaned agent stash(es)..."
    for line_num in $(echo "$AGENT_STASH_INDICES" | sort -rn); do
        idx=$((line_num - 1))
        git stash drop "stash@{$idx}" 2>/dev/null || true
    done
fi

# Report current state
echo "[GIT CLEANUP] On branch: $(git rev-parse --abbrev-ref HEAD)"
