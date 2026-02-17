# Common test setup for tmux-cli bats tests
#
# Load this in each test file:
#   setup() {
#       load 'test_helper/common-setup'
#       _common_setup
#   }
#

# Try to load bats helper libraries from common locations
_load_bats_libs() {
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

    echo "Warning: bats-support/bats-assert not found." >&2
    return 1
}

# Common setup function to be called from each test's setup()
_common_setup() {
    _load_bats_libs || true

    TESTS_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
    export TESTS_DIR

    PLUGIN_ROOT="$(cd "${TESTS_DIR}/.." && pwd)"
    export PLUGIN_ROOT
    export SCRIPT="${PLUGIN_ROOT}/scripts/tmux-cli"

    export TEST_TEMP_DIR="${BATS_TEST_TMPDIR:-$(mktemp -d)}"

    # Source the script so functions are available for unit tests
    # shellcheck disable=SC1091 source=../../scripts/tmux-cli
    source "$SCRIPT"
}
