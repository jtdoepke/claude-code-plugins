# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Claude Code plugin marketplace repository. It hosts plugins that extend Claude Code with specialized skills for managing an Obsidian vault.

## Repository Structure

```
.claude-plugin/marketplace.json  # Marketplace manifest - lists all plugins
plugins/
  obsidian-skills/               # Plugin: Obsidian vault management skills
    .claude-plugin/plugin.json   # Plugin manifest (version tracked here)
    skills/                      # SKILL.md files define agent skills
    tests/                       # Bats test suite
```

## Commands

### Run tests
```bash
bats plugins/obsidian-skills/tests/
```

### Run a single test file
```bash
bats plugins/obsidian-skills/tests/unit/list-topics.bats
```

### Test a plugin locally without installation
```bash
claude --plugin-dir ./plugins/obsidian-skills
```

### Lint shell scripts
```bash
shellcheck plugins/**/*.sh
```

### Validate JSON files
```bash
find . -name "*.json" -exec python3 -m json.tool {} > /dev/null \;
```

## Plugin Development

### Creating a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with name, description, version, and author
2. Add plugin components:
   - `skills/` - Agent skills defined in SKILL.md files
   - `commands/` - Slash commands (.md files)
   - `hooks/` - Event handlers (hooks.json)
3. Register in `.claude-plugin/marketplace.json`

### Skills Format

Skills are defined in `SKILL.md` files with YAML frontmatter:

```markdown
---
name: skill-name
description: When to use this skill
---

# Skill Title

Instructions for the agent...
```

Skills can include:
- `references/` - Supporting documentation files
- `scripts/` - Helper shell scripts

### Version Management

- Track version only in `plugins/<name>/.claude-plugin/plugin.json`

## CI/CD

On every push/PR:
- ShellCheck linting on all scripts in `plugins/`
- Bats tests for obsidian-skills
- JSON validation for all .json files
