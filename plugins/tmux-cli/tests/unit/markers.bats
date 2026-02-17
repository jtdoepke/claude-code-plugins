#!/usr/bin/env bats

setup() {
    load '../test_helper/common-setup'
    _common_setup
}

# --- generate_execution_markers ---

@test "generate_execution_markers: sets START_MARKER and END_MARKER" {
    generate_execution_markers
    [[ -n "$START_MARKER" ]]
    [[ -n "$END_MARKER" ]]
}

@test "generate_execution_markers: markers contain PID" {
    generate_execution_markers
    [[ "$START_MARKER" == *"$$"* ]]
    [[ "$END_MARKER" == *"$$"* ]]
}

@test "generate_execution_markers: start and end are different" {
    generate_execution_markers
    [[ "$START_MARKER" != "$END_MARKER" ]]
}

@test "generate_execution_markers: markers have expected prefix" {
    generate_execution_markers
    [[ "$START_MARKER" == __TMUX_EXEC_START_* ]]
    [[ "$END_MARKER" == __TMUX_EXEC_END_* ]]
}

@test "generate_execution_markers: successive calls produce unique markers" {
    generate_execution_markers
    local first_start="$START_MARKER"
    sleep 0.01  # ensure different nanosecond timestamp
    generate_execution_markers
    [[ "$START_MARKER" != "$first_start" ]]
}

# --- wrap_command_with_markers ---

@test "wrap_command_with_markers: wraps command correctly" {
    local result
    result="$(wrap_command_with_markers "ls -la" "START123" "END123")"
    assert_equal "$result" 'echo START123; { ls -la; } 2>&1; echo END123:$?'
}

@test "wrap_command_with_markers: handles command with special chars" {
    local result
    result="$(wrap_command_with_markers 'echo "hello world"' "S" "E")"
    assert_equal "$result" 'echo S; { echo "hello world"; } 2>&1; echo E:$?'
}

# --- find_markers_in_output ---

@test "find_markers_in_output: both markers present" {
    find_markers_in_output $'START\nsome output\nEND:0' "START" "END"
    assert_equal "$HAS_START" "1"
    assert_equal "$HAS_END" "1"
}

@test "find_markers_in_output: only start marker" {
    find_markers_in_output $'START\nsome output' "START" "END"
    assert_equal "$HAS_START" "1"
    assert_equal "$HAS_END" "0"
}

@test "find_markers_in_output: only end marker" {
    find_markers_in_output $'some output\nEND:0' "START" "END"
    assert_equal "$HAS_START" "0"
    assert_equal "$HAS_END" "1"
}

@test "find_markers_in_output: neither marker" {
    find_markers_in_output "some random output" "START" "END"
    assert_equal "$HAS_START" "0"
    assert_equal "$HAS_END" "0"
}

@test "find_markers_in_output: end marker needs colon" {
    find_markers_in_output "END without colon" "START" "END"
    assert_equal "$HAS_END" "0"
}

# --- parse_marked_output ---

@test "parse_marked_output: successful command exit 0" {
    local captured=$'__START__\nhello world\n__END__:0'
    local result
    result="$(parse_marked_output "$captured" "__START__" "__END__")"
    # Verify JSON contains expected fields
    [[ "$result" == *'"exit_code":0'* ]]
    [[ "$result" == *'"output":"hello world"'* ]]
}

@test "parse_marked_output: command with non-zero exit" {
    local captured=$'__START__\nerror occurred\n__END__:42'
    local result
    result="$(parse_marked_output "$captured" "__START__" "__END__")"
    [[ "$result" == *'"exit_code":42'* ]]
    [[ "$result" == *'"output":"error occurred"'* ]]
}

@test "parse_marked_output: missing markers returns -1" {
    local result
    result="$(parse_marked_output "no markers here" "__START__" "__END__")"
    [[ "$result" == *'"exit_code":-1'* ]]
}

@test "parse_marked_output: multiline output" {
    local captured=$'__START__\nline1\nline2\nline3\n__END__:0'
    local result
    result="$(parse_marked_output "$captured" "__START__" "__END__")"
    [[ "$result" == *'"exit_code":0'* ]]
    [[ "$result" == *'line1'* ]]
    [[ "$result" == *'line2'* ]]
    [[ "$result" == *'line3'* ]]
}

@test "parse_marked_output: empty output between markers" {
    local captured=$'__START__\n__END__:0'
    local result
    result="$(parse_marked_output "$captured" "__START__" "__END__")"
    [[ "$result" == *'"exit_code":0'* ]]
}

@test "parse_marked_output: ignores command echo, uses echoed marker" {
    # The captured output includes both the typed command (with $?) and the echoed markers
    local captured
    captured='echo __START__; { true; } 2>&1; echo __END__:$?'
    captured+=$'\n__START__\n__END__:0'
    local result
    result="$(parse_marked_output "$captured" "__START__" "__END__")"
    [[ "$result" == *'"exit_code":0'* ]]
}
