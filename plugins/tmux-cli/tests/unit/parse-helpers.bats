#!/usr/bin/env bats

setup() {
    load '../test_helper/common-setup'
    _common_setup
}

# --- parse_bool ---

@test "parse_bool: True returns 0" {
    run parse_bool "True"
    assert_success
}

@test "parse_bool: true returns 0" {
    run parse_bool "true"
    assert_success
}

@test "parse_bool: 1 returns 0" {
    run parse_bool "1"
    assert_success
}

@test "parse_bool: False returns 1" {
    run parse_bool "False"
    assert_failure 1
}

@test "parse_bool: false returns 1" {
    run parse_bool "false"
    assert_failure 1
}

@test "parse_bool: 0 returns 1" {
    run parse_bool "0"
    assert_failure 1
}

@test "parse_bool: invalid returns 2" {
    run parse_bool "maybe"
    assert_failure 2
    assert_output --partial "invalid boolean"
}

# --- parse_delay_enter ---

@test "parse_delay_enter: True enables with 1.5s default" {
    parse_delay_enter "True"
    assert_equal "$DELAY_ENTER_ENABLED" "1"
    assert_equal "$DELAY_ENTER_SECS" "1.5"
}

@test "parse_delay_enter: False disables" {
    parse_delay_enter "False"
    assert_equal "$DELAY_ENTER_ENABLED" "0"
    assert_equal "$DELAY_ENTER_SECS" "0"
}

@test "parse_delay_enter: float value enables with that delay" {
    parse_delay_enter "2.5"
    assert_equal "$DELAY_ENTER_ENABLED" "1"
    assert_equal "$DELAY_ENTER_SECS" "2.5"
}

@test "parse_delay_enter: integer value enables with that delay" {
    parse_delay_enter "3"
    assert_equal "$DELAY_ENTER_ENABLED" "1"
    assert_equal "$DELAY_ENTER_SECS" "3"
}

@test "parse_delay_enter: 0 disables" {
    parse_delay_enter "0"
    assert_equal "$DELAY_ENTER_ENABLED" "0"
}

@test "parse_delay_enter: invalid value fails" {
    run parse_delay_enter "notanumber"
    assert_failure
    assert_output --partial "invalid delay_enter"
}

# --- float_ge ---

@test "float_ge: 2.0 >= 1.0 is true" {
    run float_ge 2.0 1.0
    assert_success
}

@test "float_ge: 1.0 >= 1.0 is true" {
    run float_ge 1.0 1.0
    assert_success
}

@test "float_ge: 0.5 >= 1.0 is false" {
    run float_ge 0.5 1.0
    assert_failure
}

@test "float_ge: integer comparison 3 >= 2" {
    run float_ge 3 2
    assert_success
}
