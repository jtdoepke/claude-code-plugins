# Claude Code Plugins

Personal Claude Code plugin marketplace by Jaye Doepke.

## Installation

Add this marketplace to Claude Code:

```bash
claude plugin marketplace add jtdoepke/claude-code-plugins
```

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [obsidian-skills](#obsidian-skills) | Skills for managing an Obsidian vault | 0.1.0 |

### obsidian-skills

Skills for creating and managing content in an Obsidian vault. Includes:

- **obsidian-bases** - Create and configure Obsidian Bases (database-like views for notes)
- **obsidian-plan** - Create project implementation plans in the vault
- **obsidian-research** - Create research notes with structured analysis

Install:

```bash
claude plugin install obsidian-skills@jtdoepke-plugins
```

## Development

### Adding a New Plugin

1. Create a new directory under `plugins/`:

   ```bash
   mkdir -p plugins/my-plugin/.claude-plugin
   ```

2. Create the plugin manifest at `plugins/my-plugin/.claude-plugin/plugin.json`:

   ```json
   {
     "name": "my-plugin",
     "description": "Description of your plugin",
     "version": "0.0.1",
     "author": {
       "name": "Your Name"
     }
   }
   ```

3. Add your plugin components:
   - `skills/` - Agent skills (SKILL.md files)
   - `commands/` - Slash commands (.md files)
   - `agents/` - Specialized agents (.md files)
   - `hooks/` - Event handlers (hooks.json)

4. Register the plugin in `.claude-plugin/marketplace.json`

5. Bump the version in `plugin.json` when releasing changes

### Testing Locally

Test a plugin directly without installation:

```bash
claude --plugin-dir ./plugins/obsidian-skills
```

Run the test suite:

```bash
bats plugins/obsidian-skills/tests/
```

### CI/CD

- **CI** runs on every push and PR: shellcheck, bats tests, JSON validation
- **Releases** are created automatically when a plugin's version changes in `plugin.json`

## License

MIT License - see [LICENSE](LICENSE) for details.
