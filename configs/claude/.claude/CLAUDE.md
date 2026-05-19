Use `pre-commit run --all-files` for linting.

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