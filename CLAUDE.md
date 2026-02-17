# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Claude Code plugin marketplace repository hosting plugins that extend Claude Code functionality. Plugins can provide skills (agent capabilities), commands (slash commands), and hooks (event handlers).

## Commands

```bash
# Run all tests for a plugin
bats plugins/obsidian-skills/tests/
bats plugins/tmux-cli/tests/unit/ plugins/tmux-cli/tests/integration/

# Run a single test file
bats plugins/obsidian-skills/tests/unit/list-topics.bats
bats plugins/tmux-cli/tests/integration/local-mode.bats

# Test a plugin locally without installation
claude --plugin-dir ./plugins/<plugin-name>

# Lint shell scripts (run via pre-commit)
pre-commit run -a

# Validate all JSON files
find . -name "*.json" -not -path "*/tests/lib/*" -exec python3 -m json.tool {} > /dev/null \;
```

## Plugin Development

### Creating a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "plugin-name",
     "description": "What the plugin does",
     "version": "0.1.0",
     "author": { "name": "Author Name" }
   }
   ```

2. Add plugin components:
   - `skills/` - SKILL.md files with YAML frontmatter (name, description) followed by agent instructions
   - `commands/` - Slash command definitions (.md files)
   - `hooks/` - Event handlers (hooks.json)
   - `references/` - Supporting documentation (referenced by skills)
   - `scripts/` - Helper shell scripts (called by skills)

3. Register in `.claude-plugin/marketplace.json`

### Skills Format

```markdown
---
name: skill-name
description: When Claude should use this skill (triggers automatic invocation)
---

# Skill Title

Instructions for the agent when skill is activated...
```

### Testing

Bats tests use vendored `bats-support` and `bats-assert` libraries as git submodules under `tests/lib/`. When adding tests to a new plugin, add these submodules:

```bash
git submodule add https://github.com/bats-core/bats-support.git plugins/<name>/tests/lib/bats-support
git submodule add https://github.com/bats-core/bats-assert.git plugins/<name>/tests/lib/bats-assert
```

### Version Management

Track version only in `plugins/<name>/.claude-plugin/plugin.json`. Bump version when releasing changes.

## CI/CD

A pre-commit hook runs ShellCheck on all shell scripts (excluding `tests/lib/`).

GitHub Actions CI runs on push/PR to main:
- ShellCheck on scripts in `plugins/` (ignores `tests/lib/`)
- Bats tests for obsidian-skills
- JSON validation
