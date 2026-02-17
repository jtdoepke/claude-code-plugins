#!/usr/bin/env bats

setup() {
    load '../test_helper/common-setup'
    _common_setup
}

@test "json_escape: plain string unchanged" {
    result="$(json_escape "hello world")"
    assert_equal "$result" "hello world"
}

@test "json_escape: escapes double quotes" {
    result="$(json_escape 'say "hello"')"
    assert_equal "$result" 'say \"hello\"'
}

@test "json_escape: escapes backslashes" {
    result="$(json_escape 'path\\to\\file')"
    assert_equal "$result" 'path\\\\to\\\\file'
}

@test "json_escape: escapes newlines" {
    result="$(json_escape $'line1\nline2')"
    assert_equal "$result" 'line1\nline2'
}

@test "json_escape: escapes tabs" {
    result="$(json_escape $'col1\tcol2')"
    assert_equal "$result" 'col1\tcol2'
}

@test "json_escape: escapes carriage returns" {
    result="$(json_escape $'line1\rline2')"
    assert_equal "$result" 'line1\rline2'
}

@test "json_escape: empty string" {
    result="$(json_escape "")"
    assert_equal "$result" ""
}

@test "json_escape: combined special characters" {
    result="$(json_escape $'he said "hi"\nand\tthen\\left')"
    assert_equal "$result" 'he said \"hi\"\nand\tthen\\left'
}

@test "json_escape: backslash before quote" {
    result="$(json_escape '\\"')"
    assert_equal "$result" '\\\\\"'
}

@test "json_escape: escapes backspace" {
    result="$(json_escape $'before\bafter')"
    assert_equal "$result" 'before\bafter'
}

@test "json_escape: escapes form feed" {
    result="$(json_escape $'before\fafter')"
    assert_equal "$result" 'before\fafter'
}

@test "json_escape: strips ANSI color codes" {
    result="$(json_escape $'\x1b[31mred text\x1b[0m')"
    assert_equal "$result" 'red text'
}

@test "json_escape: strips ANSI bold and reset" {
    result="$(json_escape $'\x1b[1mbold\x1b[0m normal')"
    assert_equal "$result" 'bold normal'
}

@test "json_escape: escapes other control characters as \\uXXXX" {
    # U+0001 (SOH) should become \u0001
    result="$(json_escape $'\x01')"
    assert_equal "$result" '\u0001'
}

@test "json_escape: escapes NUL as \\u0000" {
    # printf to embed a literal NUL -- bash strings can't hold NUL,
    # so we test the vertical tab (U+000B) instead which is representable.
    result="$(json_escape $'\x0b')"
    assert_equal "$result" '\u000b'
}

@test "json_escape: mixed ANSI, control chars, and normal text" {
    result="$(json_escape $'\x1b[32mgreen\x1b[0m \x01 hello\nnewline')"
    assert_equal "$result" 'green \u0001 hello\nnewline'
}
