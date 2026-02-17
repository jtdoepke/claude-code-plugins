#!/usr/bin/env bats

# Integration tests for local (pane) mode.
# These require tmux to be installed and create a real tmux session.
#
# We simulate local mode by setting TMUX and TMUX_PANE to point to a
# real tmux session we create for testing.

setup_file() {
    export TEST_SESSION="bats-local-test-$$"
    tmux new-session -d -s "$TEST_SESSION" -x 200 -y 50 bash
    sleep 0.5
    export INITIAL_PANE
    INITIAL_PANE="$(tmux display-message -t "$TEST_SESSION" -p '#{pane_id}')"
    export TEST_TMUX_SOCKET
    TEST_TMUX_SOCKET="$(tmux display-message -t "$TEST_SESSION" -p '#{socket_path},#{pid},0')"
}

teardown_file() {
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
}

setup() {
    load '../test_helper/common-setup'
    _common_setup
    export TMUX="${TEST_TMUX_SOCKET}"
    export TMUX_PANE="${INITIAL_PANE}"
    export MODE="local"
    TARGET_PANE=""
}

teardown() {
    # Kill any extra panes created during the test
    local pane_ids
    pane_ids="$(tmux list-panes -t "$TEST_SESSION" -F '#{pane_id}' 2>/dev/null)" || return 0
    local pane
    while IFS= read -r pane; do
        [[ -z "$pane" ]] && continue
        [[ "$pane" == "$INITIAL_PANE" ]] && continue
        tmux kill-pane -t "$pane" 2>/dev/null || true
    done <<< "$pane_ids"
}

# Helper: launch bash and set TARGET_PANE in the current shell.
# local_launch_cli runs in a subshell ($(...)) so TARGET_PANE doesn't propagate.
_launch_bash_pane() {
    local formatted_id
    formatted_id="$(local_launch_cli "bash" --size=50)"
    [[ -n "$formatted_id" ]]
    # TARGET_PANE was set inside the subshell; we need to find the new pane.
    # The formatted_id is session:window.pane_index -- resolve it back.
    local resolved
    resolved="$(local_resolve_pane "${formatted_id##*.}")" || {
        # Fallback: get last pane from list
        run_tmux list-panes -t "$(local_get_current_window_id)" -F '#{pane_id}'
        resolved="$(echo "$TMUX_OUT" | tail -n1)"
    }
    TARGET_PANE="$resolved"
    printf '%s' "$formatted_id"
}

# --- status ---

@test "local: status shows session name" {
    run cmd_status
    assert_success
    assert_output --partial "$TEST_SESSION"
}

# --- launch + list_panes ---

@test "local: launch creates a new pane visible in list_panes" {
    _launch_bash_pane >/dev/null

    local panes_json
    panes_json="$(local_list_panes)"
    [[ "$panes_json" == *'"index":"0"'* ]]
    [[ "$panes_json" == *'"index":"1"'* ]]

    local_kill_pane --pane="$TARGET_PANE" 2>/dev/null || true
}

# --- send + capture ---

@test "local: send and capture round-trip" {
    _launch_bash_pane >/dev/null

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local_send_keys "echo tmux-test-12345" --enter=True --delay-enter=0.5

    sleep 1

    local output
    output="$(local_capture_pane --lines=10)"
    [[ "$output" == *"tmux-test-12345"* ]]

    local_kill_pane 2>/dev/null || true
}

# --- execute with exit codes ---

@test "local: execute returns exit_code 0 for successful command" {
    _launch_bash_pane >/dev/null
    local resolved="$TARGET_PANE"

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local result
    result="$(local_execute "true" --pane="$resolved" --timeout=10)"
    [[ "$result" == *'"exit_code":0'* ]]

    local_kill_pane --pane="$resolved" 2>/dev/null || true
}

@test "local: execute returns non-zero exit code" {
    _launch_bash_pane >/dev/null
    local resolved="$TARGET_PANE"

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local result
    result="$(local_execute "echo test-output && (exit 42)" --pane="$resolved" --timeout=10)"
    [[ "$result" == *'"exit_code":42'* ]]
    [[ "$result" == *'test-output'* ]]

    local_kill_pane --pane="$resolved" 2>/dev/null || true
}

# --- execute with output ---

@test "local: execute captures command output" {
    _launch_bash_pane >/dev/null
    local resolved="$TARGET_PANE"

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local result
    result="$(local_execute "echo hello-from-execute" --pane="$resolved" --timeout=10)"
    [[ "$result" == *'"exit_code":0'* ]]
    [[ "$result" == *'hello-from-execute'* ]]

    local_kill_pane --pane="$resolved" 2>/dev/null || true
}

# --- wait_idle ---

@test "local: wait_idle returns success after command finishes" {
    _launch_bash_pane >/dev/null

    run local_wait_for_idle --idle-time=1.0 --timeout=5
    assert_success

    local_kill_pane 2>/dev/null || true
}

# --- interrupt ---

@test "local: interrupt does not crash" {
    _launch_bash_pane >/dev/null

    # shellcheck disable=SC2119
    run local_send_interrupt
    assert_success

    local_kill_pane 2>/dev/null || true
}

# --- kill ---

@test "local: kill removes pane from list" {
    _launch_bash_pane >/dev/null
    local to_kill="$TARGET_PANE"

    # Use TARGET_PANE (no --pane= flag) to avoid safety check
    # against the "current" pane, which in test context might
    # resolve to the wrong pane since there's no real client.
    # shellcheck disable=SC2119
    local_kill_pane

    local panes_json
    panes_json="$(local_list_panes)"
    [[ "$panes_json" != *"$to_kill"* ]]
}

# --- resize ---

@test "local: resize does not crash" {
    _launch_bash_pane >/dev/null

    run local_resize_pane --direction=down --amount=5
    assert_success

    run local_resize_pane --direction=up --amount=5
    assert_success

    local_kill_pane 2>/dev/null || true
}

@test "local: resize rejects invalid direction" {
    _launch_bash_pane >/dev/null

    run local_resize_pane --direction=diagonal --amount=5
    assert_failure

    local_kill_pane 2>/dev/null || true
}

# --- focus ---

@test "local: focus does not crash" {
    _launch_bash_pane >/dev/null

    # shellcheck disable=SC2119
    run local_focus_pane
    assert_success

    local_kill_pane 2>/dev/null || true
}

# --- clear ---

@test "local: clear does not crash" {
    _launch_bash_pane >/dev/null

    # shellcheck disable=SC2119
    run local_clear_pane
    assert_success

    local_kill_pane 2>/dev/null || true
}

# --- wait_for_prompt ---

@test "local: wait_for_prompt detects matching pattern" {
    _launch_bash_pane >/dev/null

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local_send_keys "echo PROMPT_MARKER_XYZ" --enter=True --delay-enter=0.5
    sleep 0.5

    run local_wait_for_prompt "PROMPT_MARKER_XYZ" --timeout=5
    assert_success

    local_kill_pane 2>/dev/null || true
}

@test "local: wait_for_prompt times out when pattern absent" {
    _launch_bash_pane >/dev/null

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    run local_wait_for_prompt "NONEXISTENT_PATTERN_99999" --timeout=2
    assert_failure

    local_kill_pane 2>/dev/null || true
}

@test "local: wait_for_prompt supports regex" {
    _launch_bash_pane >/dev/null

    local_wait_for_idle --idle-time=1.0 --timeout=5 || true

    local_send_keys "echo REGEX_TEST_42" --enter=True --delay-enter=0.5
    sleep 0.5

    run local_wait_for_prompt "REGEX_TEST_[0-9]+" --timeout=5
    assert_success

    local_kill_pane 2>/dev/null || true
}
