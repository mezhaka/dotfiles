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

**Python: alias `polars` as `pl` and `pyarrow` as `pa`**: by convention, import
these libraries under their standard short aliases — `import polars as pl`,
`import pyarrow as pa` (and `import pyarrow.dataset as ds`,
`import pyarrow.parquet as pq` for the submodules) — rather than under their
full module names. Keep code references aliased; the full module path is fine
in prose (docstrings/comments) when documenting the library's own API.

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

**Shortcut tooling — default to the claude.ai Shortcut connector, fall back to `short` CLI**:

- **Default**: use the claude.ai Shortcut connector (`mcp__claude_ai_Shortcut__*`) for any single-object
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
  `mcp__claude_ai_Shortcut__stories-upload-file` work for local files — `short` lacks the
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

**No CI-automated tooling in the PR "Test plan"**: do not mention `pre-commit run`, `terraform fmt`,
`terraform validate`, `pixi run unit-test`, or any other linter / formatter / validation /
static-analysis / test-suite step that already runs automatically as part of CI in a "Test plan"
section of a PR description. These checks run in CI regardless, so there is no need to call them out
— the "Test plan" should describe manual verification or behavior the author specifically checked,
not the automated gate.

**Draft PR titles**: when opening a PR as a draft (`gh pr create --draft`),
prepend `WIP: ` to the title (e.g. `WIP: Constrain apa-pm IAM (sc-36821)`).
Drop the prefix when marking the PR ready for review.

**CHANGELOG entry when promoting a draft PR**: when marking a draft PR ready
for review, propose adding an entry to the repo's CHANGELOG that summarizes
the PR's current work, if the repo keeps one. Draft the entry and ask before
committing it rather than adding it silently.

**Reconcile the PR description when promoting a draft to ready**: marking a
draft ready is a description-sync checkpoint, not just a CHANGELOG one. Before
flipping it, re-read the body and rewrite anything the promotion or an
out-of-band action has made stale: references to the PR being a draft/WIP or
"pending coordination"; future-tense plans or "not yet done" caveats for work
that has since happened (e.g. a `terraform apply` already run, a step already
verified); and Test-plan items that were speculative when drafted but have now
actually passed — mark those done. If part of the change was already
applied/deployed ahead of merge, say so explicitly: it tells the merger the PR
is reconciling the default branch with live state. This complements "Keep the
PR description in sync with the PR's contents" below, which covers
diff-altering pushes; this clause covers state changes that leave the diff
untouched.

**Draft PR reviews — trigger Copilot, then act on its comments**:
when asked to create a draft PR, after opening it, request a review from
GitHub Copilot, then wait for its review comments to land and address them
on the user's behalf — apply suggested fixes, push follow-up commits, and
resolve or reply to threads as appropriate. Use judgment on which comments
to accept vs. push back on; flag anything non-obvious before acting. No need
to ask for permission to kick off the review — it's pre-authorized for
draft PRs.

**Keep the PR description in sync with the PR's contents**: when working on
an open PR (including drafts) and pushing changes that alter what the PR does —
new commits, dropped commits, scope changes — check whether the PR description
still accurately reflects the diff, and update it (`gh pr edit --body ...`)
when it doesn't. Review-feedback fixups that don't change the PR's purpose
don't require a description update.

**Branch naming for ultramarin-ai PRs**: PR branches use
`{type}/sc-{story_id}-{slug}` — e.g. `chore/sc-36788-raise-pd-ssd-quota-europe-west3`.
`{type}` is the Shortcut story type (`chore`, `feature`, or `bug`);
`{story_id}` is the numeric Shortcut story ID; `{slug}` is a short kebab-case
description. Only the `sc-{id}` token matters for Shortcut's GitHub
integration to auto-link the PR — the slug is free-form (verified 2026-04-28
against story sc-36789). To fetch Shortcut's own suggestion non-interactively,
the claude.ai Shortcut connector exposes `mcp__claude_ai_Shortcut__stories-get-branch-name`. **Pick the
branch name before opening the PR**: renaming the branch of an open PR has
been observed to close the PR (see project auto-memory
`branch_naming_convention.md`). **If asked to open a PR and no Shortcut
story is known from the conversation context**, do NOT invent a
non-conforming branch name — first ask the user for the story ID, or
suggest creating one (e.g. via `mcp__claude_ai_Shortcut__stories-create`) before
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
`mcp__claude_ai_Shortcut__stories-get-branch-name`. Phrase as a one-line paste-ready
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

**Obsidian vault location**: the Obsidian vault lives in iCloud at
`/Users/ant/Library/Mobile Documents/com~apple~CloudDocs/obsidian` (the vault
itself is the `a/` subdirectory).

**Off-topic questions**: when asked something outside the software-engineering
scope (e.g. device settings, general life questions), just answer directly if
you know the answer. Don't preface with disclaimers about being a CLI tool or
your scope.

<!-- BEGIN agent-style v0.4.2 -->
@.agent-style/claude-code.md
<!-- END agent-style -->
