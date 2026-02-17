#!/usr/bin/env bats

# Integration tests for remote (window) mode.
# These require tmux to be installed and create a dedicated session.

setup_file() {
    # Ensure we are NOT inside tmux for remote mode
    unset TMUX
    unset TMUX_PANE
    export SESSION_NAME="bats-remote-test-$$"
}

teardown_file() {
    tmux kill-session -t "bats-remote-test-$$" 2>/dev/null || true
}

setup() {
    load '../test_helper/common-setup'
    _common_setup
    # Force remote mode
    unset TMUX
    unset TMUX_PANE
    export MODE="remote"
    SESSION_NAME="bats-remote-test-$$"
    remote_ensure_session
}

# --- launch ---

@test "remote: launch creates a window" {
    local window_id
    window_id="$(remote_launch_cli "bash" --name="test-win")"
    [[ -n "$window_id" ]]
    [[ "$window_id" == "${SESSION_NAME}:"* ]]
}

# --- send + capture round-trip ---

@test "remote: send and capture round-trip" {
    local window_id
    window_id="$(remote_launch_cli "bash" --name="send-test")"
    [[ -n "$window_id" ]]

    # Wait for shell
    remote_wait_for_idle --pane="$window_id" --idle-time=1.0 --timeout=5 || true

    # Send a command
    remote_send_keys "echo remote-test-67890" --pane="$window_id" --enter=True --delay-enter=0.5

    sleep 1

    local output
    output="$(remote_capture_pane --pane="$window_id" --lines=10)"
    [[ "$output" == *"remote-test-67890"* ]]
}

# --- execute ---

@test "remote: execute returns exit_code 0" {
    local window_id
    window_id="$(remote_launch_cli "bash" --name="exec-test")"
    [[ -n "$window_id" ]]

    remote_wait_for_idle --pane="$window_id" --idle-time=1.0 --timeout=5 || true

    local result
    result="$(remote_execute "echo remote-exec-output" --pane="$window_id" --timeout=10)"
    [[ "$result" == *'"exit_code":0'* ]]
    [[ "$result" == *'remote-exec-output'* ]]
}

@test "remote: execute returns non-zero exit code" {
    local window_id
    window_id="$(remote_launch_cli "bash" --name="fail-test")"
    [[ -n "$window_id" ]]

    remote_wait_for_idle --pane="$window_id" --idle-time=1.0 --timeout=5 || true

    local result
    # Use a subshell exit so the bash session stays alive for marker capture
    result="$(remote_execute "(exit 7)" --pane="$window_id" --timeout=10)"
    [[ "$result" == *'"exit_code":7'* ]]
}

# --- list_windows ---

@test "remote: list_windows shows created windows" {
    remote_launch_cli "bash" --name="list-test" >/dev/null

    run remote_list_windows
    assert_success
    assert_output --partial "list-test"
}

# --- cleanup ---

# --- local-only commands rejected in remote mode ---

@test "remote: resize rejected in remote mode" {
    run cmd_resize --direction=down --amount=5
    assert_failure
    assert_output --partial "only available in local mode"
}

@test "remote: focus rejected in remote mode" {
    run cmd_focus --pane=0
    assert_failure
    assert_output --partial "only available in local mode"
}

@test "remote: clear rejected in remote mode" {
    run cmd_clear --pane=0
    assert_failure
    assert_output --partial "only available in local mode"
}

@test "remote: wait_for_prompt rejected in remote mode" {
    run cmd_wait_for_prompt "pattern" --timeout=1
    assert_failure
    assert_output --partial "only available in local mode"
}

# --- cleanup ---

@test "remote: cleanup destroys session" {
    # Ensure session exists
    remote_ensure_session

    remote_cleanup_session

    # Session should be gone
    run tmux has-session -t "$SESSION_NAME"
    assert_failure
}
