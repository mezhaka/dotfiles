#!/usr/bin/env bash
# Clone every repo in the ultramarin-ai GitHub org into a nested directory
# layout: <repo>/<default-branch-path>/... — so apa-proxy@main/v13 lands in
# apa-proxy/main/v13/, infrastructure@main in infrastructure/main/, etc.
#
# Designed to be run daily from launchd:
#   - new repos:          cloned fresh (all branches; the default branch is
#                         what we check out)
#   - existing repos:     refspec normalised to '*',
#                         `git fetch --prune origin` (all branches),
#                         `git reset --hard origin/<default-branch>` in the
#                         default-branch checkout
#   - default-branch
#     changes (e.g.
#     main/v9 -> main/v10): the repo's whole subtree is removed and
#                          re-cloned at the new path
#
# All remote branches are tracked locally (no `--single-branch`), so feature
# branches that someone else has pushed can be reviewed with a plain
# `git fetch && git checkout <branch>` from inside the default-branch
# checkout — see ~/t/e/CLAUDE.md for the worktree workflow.
#
# This script lives in the dotfiles repo (configs/local-bin) and is stowed
# to ~/.local/bin/clone-all.sh.
#
# Env overrides: ORG, BASE_DIR.
#
# ─── Scheduling under launchd (macOS) ─────────────────────────────────────
#
# A LaunchAgent at ~/Library/LaunchAgents/local.clone-ultramarin.plist runs
# this script daily at 12:00 local time. launchd is preferred over crontab
# on macOS because user agents inherit the login session — so `gh` can read
# its token from the login keychain, which cron jobs typically cannot.
#
# Plist contents:
#
#     <?xml version="1.0" encoding="UTF-8"?>
#     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
#       "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
#     <plist version="1.0">
#     <dict>
#         <key>Label</key>
#         <string>local.clone-ultramarin</string>
#         <key>ProgramArguments</key>
#         <array>
#             <string>/bin/bash</string>
#             <string>/Users/ant/.local/bin/clone-all.sh</string>
#         </array>
#         <key>StartCalendarInterval</key>
#         <dict>
#             <key>Hour</key><integer>12</integer>
#             <key>Minute</key><integer>0</integer>
#         </dict>
#         <key>StandardOutPath</key>
#         <string>/Users/ant/t/e/clone-all.log</string>
#         <key>StandardErrorPath</key>
#         <string>/Users/ant/t/e/clone-all.log</string>
#         <key>RunAtLoad</key>
#         <false/>
#         <key>EnvironmentVariables</key>
#         <dict>
#             <key>HOME</key><string>/Users/ant</string>
#             <key>BASE_DIR</key><string>/Users/ant/t/e</string>
#         </dict>
#     </dict>
#     </plist>
#
# Install / enable (one-time):
#
#     plutil -lint ~/Library/LaunchAgents/local.clone-ultramarin.plist
#     launchctl load -w ~/Library/LaunchAgents/local.clone-ultramarin.plist
#
# Verify it's registered:
#
#     launchctl list | grep clone-ultramarin
#     launchctl print "gui/$(id -u)/local.clone-ultramarin"
#
# Trigger a run on demand (useful for testing after edits):
#
#     launchctl kickstart -k "gui/$(id -u)/local.clone-ultramarin"
#     tail -f ~/t/e/clone-all.log
#
# Change the schedule: edit StartCalendarInterval in the plist, then
# reload it (unload + load, or `launchctl bootout` + `bootstrap`):
#
#     launchctl unload ~/Library/LaunchAgents/local.clone-ultramarin.plist
#     launchctl load   -w ~/Library/LaunchAgents/local.clone-ultramarin.plist
#
# Disable / remove:
#
#     launchctl unload -w ~/Library/LaunchAgents/local.clone-ultramarin.plist
#     rm ~/Library/LaunchAgents/local.clone-ultramarin.plist
#
# Notes:
#   - `launchctl list` shows three columns: PID  last-exit-code  label.
#     "-  0  local.clone-ultramarin" means: not currently running, last
#     run exited 0.
#   - If the laptop is asleep at the scheduled time, launchd will run the
#     job at the next wake. crontab would silently skip the slot.
#   - Logs append to ~/t/e/clone-all.log; rotate or truncate manually if
#     it ever grows uncomfortably large.
# ──────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Cron/launchd give a minimal PATH; make sure homebrew tools are visible.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

ORG="${ORG:-ultramarin-ai}"
BASE_DIR="${BASE_DIR:-$HOME/t/e}"

mkdir -p "$BASE_DIR"

tmp_list="$(mktemp)"
trap 'rm -f "$tmp_list"' EXIT

gh repo list "$ORG" --limit 500 --no-archived \
  --json name,defaultBranchRef \
  --jq '.[] | [.name, (.defaultBranchRef.name // "")] | @tsv' \
  > "$tmp_list"

total=$(wc -l < "$tmp_list" | tr -d ' ')
echo "[$(date '+%F %T')] Found $total repos in $ORG"

i=0
cloned=0
updated=0
skipped=0
failed=0

while IFS=$'\t' read -r name branch; do
  i=$((i + 1))
  if [[ -z "$name" ]]; then
    continue
  fi
  if [[ -z "$branch" ]]; then
    echo "[$i/$total] $name — no default branch, skipping"
    skipped=$((skipped + 1))
    continue
  fi

  target="$BASE_DIR/$name/$branch"

  # Refresh existing checkout in place.
  if [[ -d "$target/.git" ]]; then
    current_branch="$(git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    if [[ "$current_branch" != "$branch" ]]; then
      echo "[$i/$total] $name — checkout branch '$current_branch' != default '$branch', will re-clone"
      rm -rf "$BASE_DIR/$name"
    else
      echo "[$i/$total] $name@$branch — updating"
      # Normalise the fetch refspec to '*' (migrates older single-branch
      # clones in place; no-op on fresh clones).
      git -C "$target" config remote.origin.fetch \
        '+refs/heads/*:refs/remotes/origin/*'
      if git -C "$target" fetch --quiet --prune origin \
         && git -C "$target" reset --hard --quiet "origin/$branch"; then
        updated=$((updated + 1))
        continue
      else
        echo "  !! update failed for $name@$branch"
        failed=$((failed + 1))
        continue
      fi
    fi
  fi

  # New target path doesn't exist yet — clear stale sibling paths under the
  # repo dir (left over from a previous default-branch name) before cloning.
  if [[ -d "$BASE_DIR/$name" ]] && [[ ! -d "$target/.git" ]]; then
    echo "  pruning stale $name/* before re-clone"
    rm -rf "$BASE_DIR/$name"
  fi

  echo "[$i/$total] $name@$branch -> $name/$branch (clone)"
  mkdir -p "$(dirname "$target")"

  if gh repo clone "$ORG/$name" "$target" -- \
       --branch "$branch" --quiet; then
    cloned=$((cloned + 1))
  else
    echo "  !! clone failed for $name@$branch"
    failed=$((failed + 1))
  fi
done < "$tmp_list"

echo "[$(date '+%F %T')] Done. cloned=$cloned updated=$updated skipped=$skipped failed=$failed total=$total"
[[ "$failed" -eq 0 ]]
