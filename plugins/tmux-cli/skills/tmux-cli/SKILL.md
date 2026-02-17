---
name: tmux-cli
description: This skill should be used when the user needs to interact with CLI applications, other Claude Code agents, or scripts running in tmux panes or windows. Common triggers include "run this in another pane," "SSH into the server," "open a REPL in tmux," "send a command to the other pane," or "check what's running in the other pane."
---

# tmux-cli

## Instructions

Use the `tmux-cli` command to communicate with other CLI Agents or Scripts in
other tmux panes. Do `tmux-cli help` to see how to use it!

The command is available at `${CLAUDE_PLUGIN_ROOT}/scripts/tmux-cli`. No
additional installation is required -- it is a self-contained bash script with
no dependencies beyond tmux, bash 4+, and standard coreutils.

## Key Commands

### Execute with Exit Code Detection

Use `${CLAUDE_PLUGIN_ROOT}/scripts/tmux-cli execute` when you need to know if
a shell command succeeded or failed:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/tmux-cli execute "make test" --pane=2
# Returns JSON: {"output": "...", "exit_code": 0}

${CLAUDE_PLUGIN_ROOT}/scripts/tmux-cli execute "npm install" --pane=ops:1.3 --timeout=60
# Returns exit_code=0 on success, non-zero on failure, -1 on timeout
```

This is useful for:

- Running builds and knowing if they passed
- Running tests and detecting pass/fail
- Multi-step automation that should abort on failure

**Note**: `execute` is for shell commands only, not for agent-to-agent chat.
For communicating with another Claude Code instance, use `send` + `wait_idle` +
`capture` instead.
