#!/usr/bin/env bats
#
# Unit tests for list-topics.sh
#
# Tests the topic extraction script's handling of various YAML frontmatter
# formats, ensuring output is sorted and deduplicated.
#
# Topics are stored as tags with "topic/" prefix (e.g., "topic/kubernetes")
#

setup() {
    load '../test_helper/common-setup'
    _common_setup
}

# =============================================================================
# Inline Array Format Tests
# =============================================================================

@test "list-topics: handles inline bare array [topic/foo, topic/bar]" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles inline double-quoted array" {
    create_md_with_topics "test.md" '---
tags: ["topic/alpha", "topic/beta"]
---
# Test'
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles inline single-quoted array" {
    create_md_with_topics "test.md" "---
tags: ['topic/alpha', 'topic/beta']
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles inline mixed quotes array" {
    create_md_with_topics "test.md" '---
tags: ["topic/alpha", '"'"'topic/beta'"'"', topic/gamma]
---
# Test'
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
    assert_line --index 2 "gamma"
}

@test "list-topics: handles single item inline array" {
    create_md_with_topics "test.md" "---
tags: [topic/single]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output "single"
}

@test "list-topics: handles empty inline array" {
    create_md_with_topics "test.md" "---
tags: []
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output ""
}

# =============================================================================
# Multiline Array Format Tests
# =============================================================================

@test "list-topics: handles multiline bare list" {
    create_md_with_topics "test.md" "---
tags:
  - topic/alpha
  - topic/beta
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles multiline double-quoted list" {
    create_md_with_topics "test.md" '---
tags:
  - "topic/alpha"
  - "topic/beta"
---
# Test'
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles multiline single-quoted list" {
    create_md_with_topics "test.md" "---
tags:
  - 'topic/alpha'
  - 'topic/beta'
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles single item multiline list" {
    create_md_with_topics "test.md" "---
tags:
  - topic/single
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output "single"
}

@test "list-topics: handles empty multiline (tags with no items)" {
    create_md_with_topics "test.md" "---
tags:
date: 2024-01-01
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output ""
}

# =============================================================================
# Sorting Tests
# =============================================================================

@test "list-topics: sorts topics alphabetically (inline)" {
    create_md_with_topics "test.md" "---
tags: [topic/zebra, topic/apple, topic/mango]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "apple"
    assert_line --index 1 "mango"
    assert_line --index 2 "zebra"
}

@test "list-topics: sorts topics alphabetically (multiline)" {
    create_md_with_topics "test.md" "---
tags:
  - topic/zebra
  - topic/apple
  - topic/mango
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "apple"
    assert_line --index 1 "mango"
    assert_line --index 2 "zebra"
}

# =============================================================================
# Deduplication Tests
# =============================================================================

@test "list-topics: deduplicates topics within same file (inline)" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha, topic/beta, topic/alpha, topic/gamma, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Should have exactly 3 unique topics
    [[ $(echo "$output" | wc -l) -eq 3 ]]
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
    assert_line --index 2 "gamma"
}

@test "list-topics: deduplicates topics across multiple files" {
    create_md_with_topics "file1.md" "---
tags: [topic/alpha, topic/beta]
---
# Test 1"
    create_md_with_topics "file2.md" "---
tags: [topic/beta, topic/gamma]
---
# Test 2"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Should have exactly 3 unique topics
    [[ $(echo "$output" | wc -l) -eq 3 ]]
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
    assert_line --index 2 "gamma"
}

@test "list-topics: deduplicates across inline and multiline formats" {
    create_md_with_topics "inline.md" "---
tags: [topic/alpha, topic/beta]
---
# Inline"
    create_md_with_topics "multiline.md" "---
tags:
  - topic/beta
  - topic/gamma
---
# Multiline"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    [[ $(echo "$output" | wc -l) -eq 3 ]]
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
    assert_line --index 2 "gamma"
}

# =============================================================================
# Whitespace Handling Tests
# =============================================================================

@test "list-topics: trims extra whitespace in inline array" {
    create_md_with_topics "test.md" "---
tags: [  topic/alpha  ,  topic/beta  ]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: handles spaces after colon in inline array" {
    create_md_with_topics "test.md" "---
tags:   [topic/alpha, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

# =============================================================================
# Edge Cases
# =============================================================================

@test "list-topics: ignores files without topic tags" {
    create_md_with_topics "with-topics.md" "---
tags: [topic/alpha]
---
# Has topics"
    create_md_with_topics "no-topics.md" "---
title: No Topics Here
date: 2024-01-01
---
# No topics"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output "alpha"
}

@test "list-topics: ignores non-topic tags" {
    create_md_with_topics "test.md" "---
tags: [research, topic/alpha, status/draft, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Should only have alpha and beta, not research or status/draft
    [[ $(echo "$output" | wc -l) -eq 2 ]]
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: ignores non-markdown files" {
    create_md_with_topics "valid.md" "---
tags: [topic/alpha]
---
# Valid"
    echo "---
tags: [topic/should-be-ignored]
---" > "${TEST_TEMP_DIR}/notmd.txt"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_output "alpha"
}

@test "list-topics: handles topics with hyphens (kebab-case)" {
    create_md_with_topics "test.md" "---
tags: [topic/my-topic, topic/another-topic]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "another-topic"
    assert_line --index 1 "my-topic"
}

@test "list-topics: handles topics with underscores" {
    create_md_with_topics "test.md" "---
tags: [topic/my_topic, topic/another_topic]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "another_topic"
    assert_line --index 1 "my_topic"
}

@test "list-topics: returns empty for directory with no markdown files" {
    mkdir -p "${TEST_TEMP_DIR}/empty"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}/empty"
    assert_success
    assert_output ""
}

@test "list-topics: handles frontmatter ending with triple dash" {
    create_md_with_topics "test.md" "---
tags:
  - topic/alpha
  - topic/beta
---
# Content after frontmatter"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

@test "list-topics: stops parsing multiline tags at next YAML key" {
    create_md_with_topics "test.md" "---
tags:
  - topic/alpha
  - topic/beta
date: 2024-01-01
summary: This is a summary
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Should only have alpha and beta, not date or summary
    [[ $(echo "$output" | wc -l) -eq 2 ]]
    assert_line --index 0 "alpha"
    assert_line --index 1 "beta"
}

# =============================================================================
# Output Format Validation Tests
# =============================================================================

@test "list-topics: outputs one topic per line" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha, topic/beta, topic/gamma]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    [[ $(echo "$output" | wc -l) -eq 3 ]]
}

@test "list-topics: output contains no quotes" {
    create_md_with_topics "test.md" '---
tags: ["topic/alpha", '"'"'topic/beta'"'"']
---
# Test'
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Check that output doesn't contain quote characters
    refute_output --partial '"'
    refute_output --partial "'"
}

@test "list-topics: output contains no topic/ prefix" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Check that output doesn't contain the prefix
    refute_output --partial "topic/"
}

@test "list-topics: output contains no empty lines" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha, topic/beta]
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    # Count lines vs non-empty lines - should be equal
    local total_lines
    local non_empty_lines
    total_lines=$(echo "$output" | wc -l)
    non_empty_lines=$(echo "$output" | grep -c . || echo 0)
    [[ "$total_lines" -eq "$non_empty_lines" ]]
}

# =============================================================================
# Default Directory Tests
# =============================================================================

@test "list-topics: uses current directory when no argument provided" {
    create_md_with_topics "test.md" "---
tags: [topic/alpha]
---
# Test"
    cd "${TEST_TEMP_DIR}"
    run "${SCRIPTS_DIR}/list-topics.sh"
    assert_success
    assert_output "alpha"
}

# =============================================================================
# Mixed Tags Tests
# =============================================================================

@test "list-topics: extracts topics from mixed tags in multiline format" {
    create_md_with_topics "test.md" "---
tags:
  - research
  - topic/kubernetes
  - status/active
  - topic/aws
  - area/infrastructure
---
# Test"
    run "${SCRIPTS_DIR}/list-topics.sh" "${TEST_TEMP_DIR}"
    assert_success
    [[ $(echo "$output" | wc -l) -eq 2 ]]
    assert_line --index 0 "aws"
    assert_line --index 1 "kubernetes"
}
