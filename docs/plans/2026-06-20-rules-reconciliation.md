# Plan: two rules reconciliations (codify-provenance + cadence-rules.md divergence)

> **Deliverable target (wave 2):** copy this doc to `docs/plans/2026-06-20-rules-reconciliation.md`
> in the `cadence-rules` repo. **This is a design-only plan** — no rule edits, no `chezmoi apply`,
> no branch switch, no PRs happen during plan mode. All mutation is wave 2.

## Context

Two long-narrative-only items about the cadence rules system need to converge:

1. **codify-provenance-rule** — A hard-won epistemic discipline ("staleness before divergence")
   exists only in a field report + retro, never codified into a rule. Without a rule, the next
   session repeats the mistake: trusting a stale cite instead of going to live ground truth.
2. **rules-file-divergence** — The always-loaded methodology file `cadence-rules.md` has drifted
   into **two divergent copies on different timelines**, with no defined single source of truth.
   A naive "copy the newer one over" regresses real content in either direction.

Both converge on the **same file** (`cadence-rules.md`) and the **same source-of-truth question**,
so they're planned together: one reconciling PR that also adds the new section.

## Findings (verified this session)

The two write paths and their audiences:

| Copy | Path | Audience | Has | Lacks |
|---|---|---|---|---|
| **chezmoi / live** | `~/.dotfiles/private_dot_claude/rules/cadence/cadence-rules.md` → `~/.claude/rules/cadence/cadence-rules.md` | Cameron's machine | TodoWrite-disabled, `/outro fast` exception, verbose Verification + Red Flags | `## Subagent Delegation`, adversarial plan-reviewer line |
| **cadence plugin** | `cadence/rules/cadence-rules.md` (`origin/main`) | **every user** (installer copies it) | `## Subagent Delegation` (~80 lines), adversarial plan-reviewer line | platform edits above; managed-by comment stale |

Verified facts:
- **Live == chezmoi source == dotfiles HEAD, byte-identical** (empty diff). chezmoi isn't internally
  drifted; the drift is purely live-vs-plugin.
- **Correction to the divergence intro:** `cadence-groundwork:initializing-cadence` does **not** carry
  an inline template, but it **`cp`s `cadence-rules.md` straight from the cadence plugin cache**
  (`initializing-cadence/SKILL.md:60-66`). So the cadence plugin's `rules/cadence-rules.md` **is**
  the de-facto install source-of-truth for every non-Cameron user — the installer already delegates
  to it. "groundwork should own the template" would create a *third* copy; rejected.
- **Exact merge delta = 6 hunks** (`diff` of the two copies): managed-by comment (both stale),
  TodoWrite line, AskUserQuestion exception, plan-reviewer line, Verification verbosity, and the
  whole `## Subagent Delegation` section. The `(Recommended)` line never diverged.
- cadence `origin/main` has advanced to `2c0677f` (intro cited `c730494`); the working tree is parked
  on `feat/code-reviewer-memory-split` exactly as warned — wave-2 edits to it must use a worktree or
  the Trees-API single-commit pattern, **never a branch switch**.

## Decisions (confirmed with Cameron)

- **Provenance rule home → a new `## Provenance` section in `cadence-rules.md`** (the methodology
  file), sibling to `## Verification`. Rationale: Verification governs what you *assert*; provenance
  governs what you *trust* — the input-side counterpart. Ships via the cadence core plugin, so every
  user gets it automatically, and it rides the same canonical file item 2 reconciles. (Not a skill:
  the trigger is "noticing a cite disagrees with live state" — exactly when you won't think to invoke
  a skill; an always-on rule is the right shape.)
- **Single source of truth → the cadence plugin copy `cadence/rules/cadence-rules.md`.** It's already
  what `initializing-cadence` copies to every user. chezmoi's `private_dot_claude/...` copy becomes a
  downstream **mirror** synced from it — stop hand-editing the chezmoi source independently.

## Item 1 — Provenance rule (new `## Provenance` section)

Insert **after** `## Verification` (and its `### Red Flags — STOP`), **before** `## Subagent
Delegation`, in the canonical `cadence-rules.md`. Draft (RFC-2119, matches the file's voice):

```markdown
## Provenance

Evidence before claims governs what you *assert*; provenance governs what you *trust*. Every
cite — a session-start disclosure, a recalled memory, a numbered artifact in a series — is
authoritative-as-of-a-timestamp, with an expiry.

- **MUST** treat **staleness** (same source, later time) as the first hypothesis when a cite
  disagrees with live state — not **divergence** (a different, competing source)
- **MUST** go to live ground truth before acting on a cite that conflicts with what you observe
- **SHOULD** attribute the gap to *time before origin* — a later-stamped version of the same
  source usually explains it

Three convergent probes from the discovery session, each "a time problem in a different costume":
- a recalled memory cited a stale ADR (0017) when the canonical answer was the later ADR (0019)
- a pasted transcript was not the generated source-of-truth it appeared to be
- a disclosed session name (`keen-mallet`) had been pruned while the live lane was `golden-tongs`
```

Source text: codify intro `2026-06-06-0917-codify-provenance-rule.md` (lines 10-12).

## Item 2 — Reconcile `cadence-rules.md` to one canonical copy

**Build merged content once.** Base = the live/chezmoi content (it keeps the platform edits +
verbose Verification), then layer on what only the plugin copy had:

| Hunk | Resolution |
|---|---|
| managed-by comment | **FIX both** → `<!-- managed by cadence — changes will be overwritten by /cadence-groundwork:initializing-cadence -->` |
| TodoWrite | **KEEP live** — "track multi-step tasks with the Task tools … `TodoWrite` is disabled by default as of v2.1.142" |
| AskUserQuestion exception | **KEEP live** — `/outro fast` form |
| Verification section | **KEEP live** — verbose IDENTIFY/RUN/READ/VERIFY/CLAIM + `### Red Flags — STOP` |
| Plan-reviewer line | **ADOPT plugin** — "SHOULD dispatch an adversarial plan-reviewer panel (2-3 lenses) … at T2/T3" |
| `## Subagent Delegation` | **ADD plugin's** full section (~80 lines: routing table, fork-vs-fresh, fan-out/chain, output handling, failure modes) |
| `## Provenance` | **ADD** (item 1) |

Net: merged = live baseline + plan-reviewer line + Subagent Delegation + Provenance + fixed comment.

## Wave-2 execution sequence

1. **Compose** the merged `cadence-rules.md` content (one file, per the tables above).
2. **cadence plugin PR** (`cameronsjo/cadence`): land merged content at `rules/cadence-rules.md`.
   Working tree is parked on a peer branch → land it via a worktree from `origin/main`
   (`git -C cadence worktree add /tmp/wt -b reconcile/cadence-rules origin/main`) or the Trees-API
   single-commit-to-new-branch pattern. **Do not branch-switch the shared checkout.** PR body:
   `Closes cameronsjo/claude-configurations#<A>` and `#<B>` (plain text, not backticked — cross-repo
   auto-close).
3. **dotfiles mirror** (`~/.dotfiles`): write the *same* merged content to
   `private_dot_claude/rules/cadence/cadence-rules.md`; commit. **Stage only that file** — a
   pre-existing `private_dot_claude/CLAUDE.md` drift sits uncommitted; do not clobber it. Use the
   `4084915+cameronsjo@users.noreply.github.com` email form.
4. **`chezmoi apply`** — now safe: the source is current. (The "do NOT apply" caveat applied only
   while the source was stale; applying *after* the merge is the correct deploy.)
5. **groundwork note** (`cadence-groundwork`): no code change needed (`initializing-cadence` already
   `cp`s the plugin copy). Add a one-line SoT note to the skill: canonical = `cadence/rules/cadence-rules.md`;
   chezmoi mirrors it.
6. **Save this plan** to `docs/plans/2026-06-20-rules-reconciliation.md` in `cadence-rules` (create
   `docs/plans/`).

## Issues to file (wave 2, on `cameronsjo/claude-configurations`)

Two trackable issues, both closed by the one cadence-repo PR:

- **A — `feedback(cadence): codify staleness-before-divergence provenance rule`** (label `cadence`).
  Body: the rule was narrative-only; add `## Provenance` to `cadence-rules.md`.
- **B — `feedback(cadence): cadence-rules.md has two divergent canonical sources — set single source of truth`**
  (label `cadence`). Body: the evidence table above + the resolution (canonical = plugin copy,
  chezmoi mirrors).

Self-heal the `cadence` label if missing before filing
(`gh label list --repo cameronsjo/claude-configurations | grep -q cadence || gh label create cadence …`).

## Verification (wave 2)

- **Two copies now identical:**
  `diff <(git -C ~/.dotfiles show HEAD:private_dot_claude/rules/cadence/cadence-rules.md) <(git -C ~/Projects/claude-configurations/cadence show origin/main:rules/cadence-rules.md)` → empty.
- **Platform edit kept:** `… | grep -c 'TodoWrite is disabled'` → 1.
- **Graft landed:** `… | grep -c '## Subagent Delegation'` → 1.
- **Item 1 landed:** `… | grep -c '## Provenance'` → 1.
- **Comment fixed:** `… | grep 'managed by'` shows `cadence-groundwork`.
- **Deployed copy matches source:**
  `diff ~/.claude/rules/cadence/cadence-rules.md <(git -C ~/.dotfiles show HEAD:private_dot_claude/rules/cadence/cadence-rules.md)` → empty (post-apply).
- **Auto-close wired:** `gh pr view <n> --repo cameronsjo/cadence --json closingIssuesReferences` lists both issues.

## Out of scope / Do NOT

- **No `chezmoi apply` against the stale source** (only after step 3's merged source lands).
- **No reading the `cadence` working tree as `origin/main`** — it's parked on `feat/code-reviewer-memory-split`; use `git show origin/main:…`.
- **No branch switch** on the shared cadence checkout — worktree/Trees-API only.
- The **wrap-rule** micro-opt (codify intro, open question) is **explicitly not decided** — defer; it's an unproven micro-optimization.

---

## Execution record (wave 2 — completed 2026-06-21)

Provenance check at execution time: cadence `origin/main` had advanced again from the
plan-cited `2c0677f` to **`4b68bdae`**. The merge delta was re-verified against live
`origin/main` rather than the plan's quoted hunks; resolutions are intent-based ("KEEP live")
so they survived the drift. The AskUserQuestion-exception hunk had gained a new plugin-side
wording (`--dangerously-skip-permissions`) — resolved to KEEP live per the table.

- **Issues filed** (`cameronsjo/claude-configurations`): A = #169, B = #170 (label `cadence`; label already existed, no self-heal needed).
- **cadence plugin PR**: [#75](https://github.com/cameronsjo/cadence/pull/75) on `cameronsjo/cadence`, branch `reconcile/cadence-rules` from a worktree off `origin/main` (no branch switch on the parked checkout). Commit `bffb62f`, +42/−7 on `rules/cadence-rules.md`. `closingIssuesReferences` confirmed listing #169 and #170; not draft; MERGEABLE.
- **dotfiles mirror**: `~/.dotfiles` commit `17153d3` — staged **only** `private_dot_claude/rules/cadence/cadence-rules.md`; the pre-existing `CLAUDE.md` drift left uncommitted.
- **`chezmoi apply`**: applied the single target path; deployed `~/.claude/rules/cadence/cadence-rules.md` verified byte-identical to the committed source and to the canonical merged content.
- **groundwork note**: PR [#7](https://github.com/cameronsjo/cadence-groundwork/pull/7) on `cameronsjo/cadence-groundwork`, branch `docs/cadence-rules-sot`, commit `a02e67f` — source-of-truth note added to `initializing-cadence/SKILL.md`.

Note: the plan's `grep -c 'TodoWrite is disabled'` check returns 0, not 1 — the live text wraps
the term as `` `TodoWrite` is disabled`` (a backtick sits between `TodoWrite` and `is`). Use
`grep -c 'disabled by default as of Claude Code'` to verify that platform edit instead.
