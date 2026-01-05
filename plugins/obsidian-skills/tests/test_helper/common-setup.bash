# Common test setup for obsidian-skills bats tests
#
# Load this in each test file:
#   setup() {
#       load 'test_helper/common-setup'
#       _common_setup
#   }
#

# Try to load bats helper libraries from common locations
_load_bats_libs() {
    # Get the tests directory relative to this file
    local tests_dir
    tests_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    local lib_paths=(
        "${tests_dir}/lib"
        "/usr/local/lib"
        "/usr/lib"
        "${HOME}/.local/lib"
        "/opt/homebrew/lib"
    )

    for base in "${lib_paths[@]}"; do
        if [[ -f "${base}/bats-support/load.bash" ]]; then
            load "${base}/bats-support/load"
            load "${base}/bats-assert/load"
            return 0
        fi
    done

    # Fallback: try loading from npm global install
    if [[ -d "${HOME}/node_modules" ]]; then
        load "${HOME}/node_modules/bats-support/load"
        load "${HOME}/node_modules/bats-assert/load"
        return 0
    fi

    echo "Warning: bats-support/bats-assert not found. Some assertions may not work." >&2
    return 1
}

# Common setup function to be called from each test's setup()
_common_setup() {
    # Load helper libraries
    _load_bats_libs || true

    # Get the tests directory (where this file lives)
    TESTS_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
    export TESTS_DIR

    # Project paths
    PLUGIN_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"
    export PLUGIN_ROOT
    export SCRIPTS_DIR="${PLUGIN_ROOT}/skills/obsidian-research/scripts"
    export FIXTURES_DIR="${TESTS_DIR}/fixtures"

    # Create a temporary directory for each test
    export TEST_TEMP_DIR="${BATS_TEST_TMPDIR:-$(mktemp -d)}"
}

# Helper to copy fixtures to temp directory
copy_fixtures_to_temp() {
    local fixture_subdir="${1:-topics}"
    cp -r "${FIXTURES_DIR}/${fixture_subdir}" "${TEST_TEMP_DIR}/"
}

# Helper to create a markdown file with topics in temp directory
create_md_with_topics() {
    local filename="$1"
    local content="$2"
    echo "$content" > "${TEST_TEMP_DIR}/${filename}"
}

# Helper to count lines in output
# shellcheck disable=SC2154  # $output is set by bats 'run' command
count_lines() {
    echo "$output" | grep -c . || echo 0
}

# Helper to check if output contains a specific topic
has_topic() {
    local topic="$1"
    echo "$output" | grep -qx "$topic"
}

# Helper to get topic at specific line number (1-indexed)
topic_at_line() {
    local line_num="$1"
    echo "$output" | sed -n "${line_num}p"
}
