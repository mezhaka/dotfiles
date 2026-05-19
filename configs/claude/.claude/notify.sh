#!/bin/bash
# Claude Code notification hook
# Suppressed if CLAUDE_QUIET=1 is set at session launch

[ "${CLAUDE_QUIET}" = "1" ] && exit 0

terminal-notifier -title "Claude Code" -message "Claude needs your attention" >/dev/null 2>&1 & disown
