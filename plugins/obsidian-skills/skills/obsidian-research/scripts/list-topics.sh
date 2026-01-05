#!/bin/bash
# Extract unique topics from YAML frontmatter tags in markdown files
# Topics are stored as tags with "topic/" prefix (e.g., "topic/kubernetes")
# Used by research skill to show existing topics

set -euo pipefail

cd "${1:-.}"

# Find all markdown files and extract tags from YAML frontmatter
# Filter for tags starting with "topic/" and strip the prefix
# Use subshell with || true to handle case where no markdown files have tags (grep returns 1)
{ grep -rh --include="*.md" -A 50 "^tags:" . 2>/dev/null || true; } | awk '
    /^--$/ { in_tags = 0; next }
    /^tags:$/ { in_tags = 1; next }
    /^tags: *\[/ {
        # Inline array format: tags: [tag1, topic/foo, tag2]
        line = $0
        gsub(/^tags: *\[/, "", line)
        gsub(/\].*/, "", line)
        gsub(/["'"'"']/, "", line)
        n = split(line, items, ",")
        for (i = 1; i <= n; i++) {
            gsub(/^ +| +$/, "", items[i])
            if (items[i] ~ /^topic\//) {
                sub(/^topic\//, "", items[i])
                if (items[i] != "") print items[i]
            }
        }
        next
    }
    in_tags && /^  - / {
        # List format: tags:\n  - topic/foo\n  - other-tag
        item = $0
        sub(/^  - /, "", item)
        gsub(/["'"'"']/, "", item)
        gsub(/^ +| +$/, "", item)
        if (item ~ /^topic\//) {
            sub(/^topic\//, "", item)
            if (item != "") print item
        }
    }
    in_tags && /^[a-zA-Z]/ { in_tags = 0 }
' | sort -u
