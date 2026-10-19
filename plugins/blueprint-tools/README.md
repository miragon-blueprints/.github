# blueprint-tools

A Claude Code plugin bundling the skills maintainers of the miragon blueprints use to keep the family in sync. Add new skills under `skills/<name>/SKILL.md`.

## Skills

### `/blueprint-tools:propagate-blueprint-change`

Takes a change that exists as a PR or issue in one blueprint and evaluates, for every other non-archived blueprint in the org, whether it applies as is, applies with engine-specific adaptation, or does not apply. It skips repos that already track the change, shows a proposal with issue drafts, and — only after you select which ones — opens `blueprint-sync` issues in the affected repos that link back to the source. Finally it comments on the source PR/issue with the created issues, so references run both ways.

**Rules**

- No source PR or issue, no run — local diffs alone are rejected.
- It only creates issues; it never edits, pushes or opens PRs in other blueprints.
- Nothing is created without your confirmation.

**Prerequisites**

- `gh` authenticated with permission to create issues and labels in `miragon-blueprints`

## License

MIT
