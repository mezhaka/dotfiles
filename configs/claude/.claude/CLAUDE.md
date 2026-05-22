Use `pre-commit run --all-files` for linting.

**No Claude Code attribution in PRs or commits**: when creating a PR, do not
append the `🤖 Generated with [Claude Code](https://claude.com/claude-code)`
footer to the body. When creating a commit, do not append the
`Co-Authored-By: Claude ...` trailer. Both are off by default in every repo.

**Reference the Shortcut story in commits and PR descriptions**: every commit
message AND every PR description must end with a line
`Part of https://app.shortcut.com/othoz42/story/XXX`, where `XXX` is the numeric
Shortcut story ID. When the current branch follows the
`{type}/sc-{story_id}-{slug}` convention, extract the ID with:
`git branch --show-current | sed -E 's/.*sc-([0-9]+)-.*/\1/'`. If no story ID
is known from context or the branch name, ask before committing or opening the
PR rather than omitting the line. For commits, use an **unquoted** heredoc
(`<<EOF`, not `<<'EOF'`) so the command substitution actually expands.

**Commit message body — motivation, not mechanics**: the diff already shows
*what* changed; the body should explain *why*. Following the Pro Git §5.2
guideline ("contrast its implementation with previous behavior",
https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project),
open the body by describing the prior behavior and the problem it caused,
then state how this commit changes it. "Prior to this change, …" is a useful
default opener. Skip restating the code-level diff — if a reader needs the
*what*, they can read the patch. **Scope**: applies to non-trivial commits;
small fixes (typos, dependency bumps, formatting-only changes) don't need a
body at all — a clear subject line is enough.

**Shortcut CLI**: Use the `short` command (https://github.com/shortcut-cli/shortcut-cli) to interact
with Shortcut stories and epics. For searching stories, use search operators for efficient
server-side filtering. Example: `short search "epic:34220" -f "%id\t%updated" -q` fetches all
stories from epic 34220 with their IDs and updated dates in quiet mode (no loading spinner).
To rename an epic, use the API command: `short api /epics/{epic_id} -X PUT -f name="New Epic Name"`.

**Attaching files to Shortcut stories**: neither `short` (verified up to v5.0.0) nor the
`mcp__shotcut__stories-upload-file` MCP tool work for local-file uploads — `short` lacks the
command, and the hosted MCP can't see the local filesystem. Use `curl` against the API directly:
```
SHORTCUT_TOKEN=$(jq -r .token ~/.config/shortcut-cli/config.json)
curl -sS -X POST "https://api.app.shortcut.com/api/v3/files" \
  -H "Shortcut-Token: $SHORTCUT_TOKEN" \
  -F "file0=@/absolute/path/to/file" \
  -F "story_id=<story_id>"
```
Returns a JSON array with the new file's `id` and confirms the attachment via
`story_ids: [<story_id>]`. To attach the same file to multiple stories, repeat the upload — there's
no documented "associate existing file with another story" endpoint.

**PR description format**: do not start PR descriptions with a `## Summary`
header — the opening paragraph is already understood to be the summary. Start
directly with the summary content.

**Draft PR titles**: when opening a PR as a draft (`gh pr create --draft`),
prepend `WIP: ` to the title (e.g. `WIP: Constrain apa-pm IAM (sc-36821)`).
Drop the prefix when marking the PR ready for review.

**Branch naming for ultramarin-ai PRs**: PR branches use
`{type}/sc-{story_id}-{slug}` — e.g. `chore/sc-36788-raise-pd-ssd-quota-europe-west3`.
`{type}` is the Shortcut story type (`chore`, `feature`, or `bug`);
`{story_id}` is the numeric Shortcut story ID; `{slug}` is a short kebab-case
description. Only the `sc-{id}` token matters for Shortcut's GitHub
integration to auto-link the PR — the slug is free-form (verified 2026-04-28
against story sc-36789). To fetch Shortcut's own suggestion non-interactively,
the `shotcut` MCP exposes `mcp__shotcut__stories-get-branch-name`. **Pick the
branch name before opening the PR**: renaming the branch of an open PR has
been observed to close the PR (see project auto-memory
`branch_naming_convention.md`). **If asked to open a PR and no Shortcut
story is known from the conversation context**, do NOT invent a
non-conforming branch name — first ask the user for the story ID, or
suggest creating one (e.g. via `mcp__shotcut__stories-create`) before
creating the branch.