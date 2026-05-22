#!/usr/bin/env bash
# Claude Code status line script
# Outputs: branch ◆ context ◆ model ◆ PR info

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# --- Git branch ---
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
else
    branch=""
fi
[ -z "$branch" ] && branch="(no branch)"

# --- Model ---
[ -z "$model" ] && model="unknown"

# --- Context window ---
if [ -n "$used" ] && [ -n "$remaining" ]; then
    ctx="ctx: $(printf '%.0f' "$used")% used / $(printf '%.0f' "$remaining")% left"
else
    ctx=""
fi

# --- PR info (cached, 60s TTL) ---
pr_info=""
if [ -n "$branch" ] && [ "$branch" != "(no branch)" ] && [ -n "$cwd" ]; then
    cache_file="/tmp/claude-pr-cache-$(echo "$branch" | tr '/' '_').txt"
    now=$(date +%s)
    cache_valid=0
    if [ -f "$cache_file" ]; then
        cache_mtime=$(stat -f '%m' "$cache_file" 2>/dev/null || stat -c '%Y' "$cache_file" 2>/dev/null || echo 0)
        age=$(( now - cache_mtime ))
        [ "$age" -lt 60 ] && cache_valid=1
    fi
    if [ "$cache_valid" -eq 1 ]; then
        pr_info=$(cat "$cache_file")
    else
        pr_json=$(gh pr view --json number,title,state 2>/dev/null)
        # Fallback: when the local branch name doesn't match the upstream remote
        # ref (e.g., `claude --worktree 'feature/foo'` rewrites `/` to `+` in the
        # local branch, but `gh pr view` looks the PR up by the literal local
        # branch name on GitHub). Try the upstream's remote ref shortname.
        if [ -z "$pr_json" ]; then
            upstream_ref=$(git -C "$cwd" config "branch.$branch.merge" 2>/dev/null | sed 's|^refs/heads/||')
            if [ -n "$upstream_ref" ] && [ "$upstream_ref" != "$branch" ]; then
                pr_json=$(cd "$cwd" && gh pr view "$upstream_ref" --json number,title,state 2>/dev/null)
            fi
        fi
        # Second fallback: `claude --worktree` creates the local branch but
        # never pushes or sets upstream tracking, so the first fallback misses
        # on worktree branches whose remote was created via an explicit-refspec
        # push (which doesn't set tracking). Derive the remote ref from the
        # worktree convention: strip the `worktree-` prefix, rewrite `+` → `/`.
        if [ -z "$pr_json" ] && [[ "$branch" == worktree-* ]]; then
            derived_ref="${branch#worktree-}"
            derived_ref="${derived_ref//+//}"
            pr_json=$(cd "$cwd" && gh pr view "$derived_ref" --json number,title,state 2>/dev/null)
        fi
        if [ -n "$pr_json" ]; then
            pr_num=$(echo "$pr_json" | jq -r '.number // empty')
            pr_title=$(echo "$pr_json" | jq -r '.title // empty')
            pr_state=$(echo "$pr_json" | jq -r '.state // empty')
            if [ -n "$pr_num" ]; then
                # Truncate title at 40 chars
                short_title="${pr_title:0:40}"
                [ ${#pr_title} -gt 40 ] && short_title="${short_title}..."
                pr_info="PR#${pr_num} [${pr_state}]: ${short_title}"
            else
                pr_info="no PR"
            fi
        else
            pr_info="no PR"
        fi
        printf '%s' "$pr_info" > "$cache_file"
    fi
fi

# --- Assemble line ---
parts=()
parts+=("$branch")
[ -n "$ctx" ] && parts+=("$ctx")
parts+=("$model")
[ -n "$pr_info" ] && parts+=("$pr_info")

sep=' ◆ '
line="${parts[0]}"
for ((i = 1; i < ${#parts[@]}; i++)); do
    line+="${sep}${parts[i]}"
done
echo "$line"
