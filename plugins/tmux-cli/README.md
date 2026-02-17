# tmux-cli

A Claude Code plugin that provides a `tmux-cli` command for interacting with
CLI applications and other code agents running in tmux panes or windows.

## Overview

This is a **bash port** of the `tmux-cli` plugin from
[pchalasani/claude-code-tools](https://github.com/pchalasani/claude-code-tools),
rewritten as a self-contained bash script with **no Python dependency**.

The original plugin is by [Prasad Chalasani](https://github.com/pchalasani)
and is licensed under the MIT License. See [LICENSE-UPSTREAM](LICENSE-UPSTREAM)
for the original license text.

## Prerequisites

- **tmux** (any recent version; 2.6+ recommended)
- **bash** 4.0+
- **md5sum** (GNU coreutils)
- **date** with nanosecond support (`date +%s%N`, GNU coreutils)

## Usage

The plugin auto-detects the tmux environment:

- **Local mode** (inside tmux): Manages panes in the current window
- **Remote mode** (outside tmux): Manages windows in a dedicated session

### Commands

| Command | Description |
|---|---|
| `tmux-cli status` | Show current tmux status and panes |
| `tmux-cli list_panes` | List panes as JSON |
| `tmux-cli launch "cmd"` | Launch a command in a new pane/window |
| `tmux-cli send "text" --pane=ID` | Send text to a pane |
| `tmux-cli capture --pane=ID` | Capture pane output |
| `tmux-cli execute "cmd" --pane=ID` | Execute command and get JSON with exit code |
| `tmux-cli wait_idle --pane=ID` | Wait for pane to become idle |
| `tmux-cli interrupt --pane=ID` | Send Ctrl+C |
| `tmux-cli escape --pane=ID` | Send Escape key |
| `tmux-cli kill --pane=ID` | Kill a pane/window |
| `tmux-cli help` | Show help |

### Remote-only Commands

| Command | Description |
|---|---|
| `tmux-cli attach` | Attach to the managed session |
| `tmux-cli cleanup` | Kill the managed session |
| `tmux-cli list_windows` | List windows in the session |

### Pane Identifiers

- Just a number (e.g., `2`) -- pane index in current window
- `session:window.pane` format (e.g., `myapp:1.2`)
- Pane ID (e.g., `%12`)

## Credits

Based on [claude-code-tools](https://github.com/pchalasani/claude-code-tools)
by Prasad Chalasani (MIT License).
