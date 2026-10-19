# .github

This repository holds miragon-blueprints' organization-level GitHub defaults.

- [`profile/README.md`](profile/README.md) — the public profile shown on [github.com/miragon-blueprints](https://github.com/miragon-blueprints).
- [`docs/blueprints.md`](docs/blueprints.md) — maintainer notes: how the blueprints relate, the update model, and the auto-synced service landscape.

Files placed here apply across the whole organization. See GitHub's docs on [organization profiles](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/customizing-your-organizations-profile) and [community health files](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file).

## Claude Code plugins

This repository is also a [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) for maintainer tooling. Every blueprint enables it via its `.claude/settings.json`; to install it manually:

```bash
/plugin marketplace add miragon-blueprints/.github        # once per machine
/plugin install blueprint-tools@miragon-blueprints        # then install what you need
```

| Plugin | What it does |
| --- | --- |
| [`blueprint-tools`](plugins/blueprint-tools/) | Maintainer skills for the blueprints. Currently `/blueprint-tools:propagate-blueprint-change`, which turns a change in one blueprint into tracking issues in the others. |

```
.claude-plugin/marketplace.json   # registers all plugins
plugins/<name>/                   # one self-contained plugin each
```

To add a plugin, drop it under `plugins/<name>/` with its own `.claude-plugin/plugin.json` and add an entry to `marketplace.json`.
