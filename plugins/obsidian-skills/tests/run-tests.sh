#!/bin/bash
#
# Convenience script to run obsidian-skills tests
#
# Usage: ./run-tests.sh [TEST_TYPE]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

usage() {
    cat <<EOF
Usage: $0 [TEST_TYPE]

TEST_TYPE:
  all          Run all tests (default)
  unit         Run only unit tests

OPTIONS:
  -h, --help   Show this help message

Examples:
  $0           # Run all tests
  $0 unit      # Run unit tests only
EOF
}

# Check for bats
if ! command -v bats &>/dev/null; then
    echo "Error: bats is not installed." >&2
    echo "Install with: brew install bats-core (macOS) or apt install bats (Debian/Ubuntu)" >&2
    exit 1
fi

TEST_TYPE="all"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        all|unit)
            TEST_TYPE="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Determine which tests to run
case "$TEST_TYPE" in
    all|unit)
        TEST_PATH="${SCRIPT_DIR}/unit"
        ;;
esac

echo "Running $TEST_TYPE tests..."
bats --recursive --timing "$TEST_PATH"
