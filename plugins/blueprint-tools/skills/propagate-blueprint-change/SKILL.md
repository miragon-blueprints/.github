---
name: propagate-blueprint-change
description: Propagate a change from one miragon blueprint to the rest of the family. Takes a source PR or issue, evaluates for every other blueprint whether the change applies, applies with engine-specific adaptation, or does not apply, and — after explicit confirmation — opens tracking issues in the affected repos that reference the source, or comments the missing part onto an existing issue that already covers most of it. Never edits code in other repos and refuses to run without a source PR/issue. Trigger when the user wants to propagate or sync a change across blueprints, asks whether a change also applies to the other blueprints, or wants issues for the other blueprints.
---

# Propagate a blueprint change

The blueprints in `miragon-blueprints` are descendants of `fullstack-example`: same MiraVelo domain, same hexagonal Kotlin / Spring Boot scaffolding, different process-engine integration (see `docs/blueprints.md` in `miragon-blueprints/.github`). A change in one blueprint often belongs in the others too. This skill turns that into **tracked issues**, so nothing drifts silently.

Follow the steps in order. Do not skip the confirmation gate.

## 0. Gate: a source reference is mandatory
- The change must exist as a **PR or issue**. Accept a number (in the current repo) or a URL.
- If the user gave none, look for a PR on the current branch: `gh pr view --json number,url`.
- If there is still nothing, **stop**. Tell the user to open a PR (or an issue) first and re-run. Never work from a local diff or a verbal description alone — every propagated issue must point back to a reviewable source.

## 1. Understand the source change
- PR: `gh pr view <n> -R <owner>/<repo> --json title,body,url,state,files,closingIssuesReferences` and `gh pr diff <n> -R <owner>/<repo>`.
- Issue: `gh issue view <n> -R <owner>/<repo> --json title,body,url,state` and read the PRs linked to it.
- Summarize the change in two or three sentences and classify it as one of: `domain/process`, `architecture`, `tooling/ci`, `docs`, `engine-specific`.
- An `engine-specific` change (worker wiring, delegate style, engine/broker config) usually stays local — say so up front.

## 2. Find the targets
List the org's non-archived blueprints, excluding `.github` and the source repo:
```
gh api "orgs/miragon-blueprints/repos?per_page=100&type=public" --paginate \
  --jq '.[] | select(.archived == false and .name != ".github") | .name'
```
Respect the direction of flow: changes land in `fullstack-example` first and flow downstream. If the source is a variant and the change is not engine-specific, `fullstack-example` is a target too — the reference must not fall behind its descendants.

## 3. Evaluate each target
For every target, check whether the touched files and concepts exist there — `gh api repos/miragon-blueprints/<repo>/contents/<path>` for the changed paths, `gh search code --repo miragon-blueprints/<repo> "<symbol>"` for moved or renamed code. Assign exactly one verdict with a one-line reason:
- `applies` — the change carries over as is.
- `adapt` — it applies, but engine-specific parts differ; name them.
- `not-applicable` — e.g. engine-specific to the source, or the affected code does not exist in the target.

## 4. Check existing issues
For each `applies`/`adapt` target, search open issues by source and by topic:
```
gh issue list -R miragon-blueprints/<repo> --state all --search "<source URL>"
gh issue list -R miragon-blueprints/<repo> --state open --search "<key terms of the change>"
```
Decide per target:
- **Duplicate** — an issue already covers the change completely: list it, propose nothing.
- **Partial overlap** — an issue covers most of it but misses something: propose a **comment** on that issue instead of a new one, containing only the missing delta plus the source link.
- **None** — propose a new issue.

## 5. Propose and confirm (AskUserQuestion)
Show a table `repo | verdict | action (new issue / comment on #n / skip) | reason`, followed by the draft of each issue or comment. Then use **AskUserQuestion** with `multiSelect` to let the user pick which actions to run. Run nothing the user did not select.

## 6. Create the issues and comments
Write in English and keep it compact — only what the target repo needs, no restating of the source diff.
- Title: `<type>: <summary> (from <source-repo>#<n>)`, with `<type>` a conventional-commit type (`feat`, `fix`, `refactor`, `chore`, `docs`, …).
- Body:
  ```
  Propagated from <source URL>.

  ## Change
  <summary from step 1>

  ## What to carry over
  <files / concepts to change in this repo>

  ## Engine-specific notes
  <only for `adapt`: what differs here and how to adapt it>
  ```
- Label `blueprint-sync`. If the repo lacks it, create it first — only in repos the user confirmed:
  `gh label create blueprint-sync -R miragon-blueprints/<repo> --color 1f6feb --description "Change propagated from another blueprint"`
- `gh issue create -R miragon-blueprints/<repo> --title "<title>" --label blueprint-sync --body-file <file>`
- Comments on partially overlapping issues: `Also covers <source URL>:` followed by a short bullet list of the missing delta — `gh issue comment <n> -R miragon-blueprints/<repo> --body-file <file>`.

## 7. Link back
Post **one** comment on the source PR/issue listing every created issue and commented issue (`gh pr comment` / `gh issue comment`), so the references run both ways. Finish with those URLs and the targets judged `not-applicable` or duplicate.

## Never
- Never edit, commit, push or open PRs in another blueprint — this skill only creates issues and issue comments there.
- Never create an issue or comment without the user's selection in step 5.
- Never run without a source PR or issue.
