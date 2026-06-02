Use `pre-commit run --all-files` for linting.

**Python: `assert` only in unit test functions**: `assert` statements are
stripped when the interpreter runs with optimizations (`python -O`), so a
function that uses `assert` changes behavior depending on interpreter flags.
In normal (non-test) code, raise an exception instead. For example, instead of

```python
assert some_variable is not None
```

do

```python
if some_variable is None:
    raise ValueError("some_variable should not be None")
```

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

**Shortcut tooling — default to the `shotcut` MCP, fall back to `short` CLI**:

- **Default**: use the `shotcut` MCP (`mcp__shotcut__*`) for any single-object
  operation — fetching a story or epic by ID, creating/updating a story,
  posting a comment, setting state, reading workflow/team/iteration metadata,
  getting a branch-name suggestion. Returns structured JSON, no shell parsing,
  and avoids spending a Bash turn on what should be one call. Common ones:
  `stories-get-by-id`, `stories-search`, `stories-create`, `stories-update`,
  `stories-create-comment`, `epics-get-by-id`, `epics-update`,
  `epics-create-comment`, `iterations-*`, `stories-get-branch-name`.
- **Use the `short` CLI (https://github.com/shortcut-cli/shortcut-cli) only
  when MCP can't do the job efficiently**:
  - **Bulk / server-side-filtered search** with operators that `stories-search`
    doesn't expose: `short search "epic:34220 state:done" -f "%id\t%updated" -q`.
  - **Raw API passthrough** for endpoints no MCP tool covers, e.g. epic
    rename: `short api /epics/{epic_id} -X PUT -f name="New Epic Name"`.
  - **Scripted loops** over many stories where one MCP call per item would
    be wasteful — write the `short` pipeline once, run it in Bash.
- **File uploads**: neither `short` (verified up to v5.0.0) nor
  `mcp__shotcut__stories-upload-file` work for local files — `short` lacks the
  command, and the hosted MCP can't see the local filesystem. Use `curl`:
  ```
  SHORTCUT_TOKEN=$(jq -r .token ~/.config/shortcut-cli/config.json)
  curl -sS -X POST "https://api.app.shortcut.com/api/v3/files" \
    -H "Shortcut-Token: $SHORTCUT_TOKEN" \
    -F "file0=@/absolute/path/to/file" \
    -F "story_id=<story_id>"
  ```
  Returns a JSON array with the new file's `id` and confirms the attachment via
  `story_ids: [<story_id>]`. To attach the same file to multiple stories, repeat
  the upload — there's no documented "associate existing file with another
  story" endpoint.

**PR description format**: do not start PR descriptions with a `## Summary`
header — the opening paragraph is already understood to be the summary. Start
directly with the summary content.

**No CI-automated tooling in the PR "Test plan"**: do not mention `pre-commit
run`, `terraform fmt`, or any other linter / formatter / static-analysis tool
that already runs automatically as part of CI in a "Test plan" section of a PR
description. These checks run in CI regardless, so there is no need to call them
out — the "Test plan" should describe manual verification or behavior the author
specifically checked, not the automated gate.

**Draft PR titles**: when opening a PR as a draft (`gh pr create --draft`),
prepend `WIP: ` to the title (e.g. `WIP: Constrain apa-pm IAM (sc-36821)`).
Drop the prefix when marking the PR ready for review.

**Draft PR reviews — trigger Copilot + Gemini, then act on their comments**:
when asked to create a draft PR, after opening it, request reviews from
GitHub Copilot and Gemini (whichever bots are configured on the repo), then
wait for their review comments to land and address them on the user's
behalf — apply suggested fixes, push follow-up commits, and resolve or
reply to threads as appropriate. Use judgment on which comments to accept
vs. push back on; flag anything non-obvious before acting. No need to ask
for permission to kick off the reviews — it's pre-authorized for draft PRs.

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

**Session naming for Shortcut work**: when this session's work becomes
associated with a specific Shortcut story — typically because the user
mentions a story ID, names a worktree path under
`<repo>/{type}/sc-{story_id}-{slug}/`, or your own commands `cd` into such
a worktree — suggest a `/rename` command so the session shows up tagged
in the Claude agents view. Sessions are commonly launched from a parent
directory like `~/t/e`, so cwd at launch is *not* the signal; wait until
the story or worktree comes up in the conversation. The rename target is
the post-`{type}/` slug — `sc-{story_id}-{slug}`, not the full branch
path. If only the story ID is known, look up the slug via
`mcp__shotcut__stories-get-branch-name`. Phrase as a one-line paste-ready
suggestion, e.g. `/rename sc-36658-set-up-apa-gui-for-a-new-windows-user`.
You cannot invoke `/rename` yourself — it's a user-typed slash command.
Suggest once per session, on the turn the association is first
established; don't re-prompt later.

**After a PR is merged, refresh the local default branch**: once a PR has
merged, pull the latest changes into the local default-branch checkout (the
`main`/default branch) so it reflects the merge — e.g. `git pull` (or
`git fetch && git reset --hard origin/<default>`) in the
`<repo>/<default-branch>/` checkout. This keeps the base for the next
worktree current rather than waiting on the daily refresh job.

**Off-topic questions**: when asked something outside the software-engineering
scope (e.g. device settings, general life questions), just answer directly if
you know the answer. Don't preface with disclaimers about being a CLI tool or
your scope.