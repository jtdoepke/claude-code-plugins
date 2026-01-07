---
name: code-review
description: Perform a multi-agent code review on PRs, MRs, branches, or commits
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Task
disable-model-invocation: false
---

# Code Review Command

Perform comprehensive code reviews using 6 parallel review agents, each with a distinct perspective. Results are filtered by confidence score (80+ threshold) and printed to the terminal.

## Usage

```
/code-review <target>
```

## Target Examples

- `/code-review pr 23` - Review GitHub PR #23
- `/code-review mr 23` - Review GitLab MR !23
- `/code-review this branch` - Compare current branch to main/master
- `/code-review current diff` - Review uncommitted changes (staged + unstaged)
- `/code-review staged` - Review only staged changes
- `/code-review last commit` - Review HEAD~1..HEAD
- `/code-review last 3 commits` - Review HEAD~3..HEAD
- `/code-review commit abc123` - Review specific commit
- `/code-review branch feature-x` - Review named branch vs main/master
- `/code-review <URL>` - Review PR/MR from GitHub/GitLab URL
- `/code-review` (no argument) - Auto-detect: PR/MR if exists, else branch diff

---

## Workflow

1. **Target Resolution** - Parse the target description and determine review scope
2. **Eligibility Check** (Haiku) - Verify prerequisites (git repo, CLI tools, valid target)
3. **Context Gathering** (Haiku) - Collect diff, changed files, CLAUDE.md, git history
4. **Parallel Review** (6 Sonnet agents) - Launch 6 agents simultaneously to find issues
5. **Confidence Scoring** (Parallel Haiku agents) - Score each issue from Phase 4
6. **Result Aggregation** - Filter by confidence >= 80, dedupe, sort by severity
7. **Output** - Print results to terminal

---

## Phase 1: Target Resolution

Parse the user's target description to determine the review scope:

| Pattern | Git Command / Action |
|---------|---------------------|
| `pr <N>` or `pull request <N>` | `gh pr diff <N>` |
| `mr <N>` or `merge request <N>` | `glab mr diff <N>` |
| `this branch` or `current branch` | `git diff main...HEAD` (or master) |
| `current diff` or `uncommitted changes` | `git diff HEAD` |
| `staged` or `staged only` | `git diff --cached` |
| `last commit` or `latest commit` | `git diff HEAD~1..HEAD` |
| `last N commits` | `git diff HEAD~N..HEAD` |
| `commit <SHA>` | `git show <SHA>` |
| `<SHA1>..<SHA2>` | `git diff <SHA1>..<SHA2>` |
| `branch <name>` | `git diff main...<name>` |
| GitHub URL with `/pull/N` | Extract N, use `gh pr diff N` |
| GitLab URL with `/merge_requests/N` | Extract N, use `glab mr diff N` |
| (empty/no argument) | Auto-detect PR/MR for current branch, else diff against main |

### Platform Detection

Determine the platform by checking the git remote URL:

1. Run `git remote get-url origin`
2. If URL contains `github.com` and `gh` CLI is available → **GitHub**
3. If URL contains `gitlab` and `glab` CLI is available → **GitLab**
4. Otherwise → **local** (use git commands only)

### Determine Default Branch

To find the default branch (main or master):
1. Try `git symbolic-ref refs/remotes/origin/HEAD` and extract branch name
2. If that fails, check if `main` branch exists: `git show-ref --verify refs/heads/main`
3. If not, check if `master` exists: `git show-ref --verify refs/heads/master`
4. Default to `main`

---

## Phase 2: Eligibility Check

Before proceeding, verify:

1. **Git repository exists**: Run `git rev-parse --git-dir`
2. **Changes exist**: The target (commit, branch, git diff, or PR/MR) exists and is non-empty

If any check fails, report the reason clearly and stop.

---

## Phase 3: Context Gathering

Gather all information needed by the review agents:

### 3.1 Get the Diff

Based on the resolved target, run the appropriate git/gh/glab command to get the diff.

### 3.2 List Changed Files

Use `--name-only` variant of the diff command to get file list:
- For git diffs: `git diff --name-only <range>`
- For PRs: `gh pr view <N> --json files --jq '.files[].path'`
- For MRs: Extract from `glab mr diff <N>` output

### 3.3 Find CLAUDE.md Files

Use a Haiku agent to return a list of file paths to (but not the contents of) any relevant CLAUDE.md files from the codebase: the root `CLAUDE.md` file (if one exists), as well as any `CLAUDE.md` files in the directories whose files the changes modified.

Pass only the file paths to review agents - they will read contents as needed.

### 3.4 Get Git History

Retrieve recent commits for context:
```
git log --oneline -20
```

### 3.5 Get PR/MR Details (if applicable)

For PRs:
```
gh pr view <N> --json title,body,author,baseRefName,headRefName
```

For MRs:
```
glab mr view <N>
```

### 3.6 Get Previous Review Comments (PR/MR only)

For PRs:
```
gh pr view <N> --json reviews,comments
```

For MRs:
```
glab mr view <N> --comments
```

---

## Phase 4: Parallel Review Agents

Launch 6 Task agents IN PARALLEL using `subagent_type="general-purpose"` and `model="sonnet"`. Each agent receives:
- The diff
- List of changed files
- CLAUDE.md file paths (agents read contents as needed)
- Summary of changes
- Agent-specific instructions (see Agent Prompts section below)

### The 6 Agents

| # | Agent Name | Focus |
|---|------------|-------|
| 1 | CLAUDE.md Compliance Auditor | Verify changes follow project CLAUDE.md instructions |
| 2 | Shallow Bug Scanner | Quick scan for obvious bugs, typos, common mistakes |
| 3 | Git History Analyst | Analyze changes in context of git history and blame |
| 4 | Previous Comments Reviewer | Check if past review feedback applies (PR/MR only) |
| 5 | Code Comments Compliance | Verify documentation and code comment quality |
| 6 | Senior Skeptic | Intentionally critical - find design flaws, edge cases, maintenance nightmares |

### Agent Output Format

Each agent must return findings as a JSON array. Note: Do NOT include confidence scores - those are assigned in Phase 5.

```json
[
  {
    "file": "path/to/file.ts",
    "line": 42,
    "severity": "critical|warning|suggestion",
    "category": "claude-md|bug|git-history|previous-comment|documentation|design",
    "summary": "One-line description",
    "details": "Detailed explanation",
    "recommendation": "How to fix it"
  }
]
```

If no issues are found, return an empty array: `[]`

---

## Phase 5: Confidence Scoring

For each issue found in Phase 4, launch a parallel Haiku agent (`subagent_type="general-purpose"` with `model="haiku"`) to score the issue's confidence level.

### Scoring Agent Input

Each scoring agent receives:
- The original issue (file, line, severity, summary, details)
- The relevant portion of the diff
- The list of CLAUDE.md file paths (from Phase 3)
- The PR/MR description (if applicable)

### Scoring Agent Instructions

Score each issue on a scale from 0-100 indicating confidence that the issue is real (not a false positive):

| Score | Meaning |
|-------|---------|
| 0 | Not confident at all. This is a false positive that doesn't stand up to light scrutiny, or is a pre-existing issue. |
| 25 | Somewhat confident. This might be a real issue, but may also be a false positive. The agent wasn't able to verify that it's a real issue. If the issue is stylistic, it is one that was not explicitly called out in the relevant CLAUDE.md. |
| 50 | Moderately confident. The agent was able to verify this is a real issue, but it might be a nitpick or not happen very often in practice. Relative to the rest of the PR, it's not very important. |
| 75 | Highly confident. The agent double checked the issue, and verified that it is very likely a real issue that will be hit in practice. The existing approach in the PR is insufficient. The issue is very important and will directly impact the code's functionality, or it is an issue that is directly mentioned in the relevant CLAUDE.md. |
| 100 | Absolutely certain. The agent double checked the issue, and confirmed that it is definitely a real issue, that will happen frequently in practice. The evidence directly confirms this. |

### Special Rules for CLAUDE.md Issues

For issues flagged due to CLAUDE.md instructions, the scoring agent MUST double-check that the CLAUDE.md actually calls out that issue specifically. If it doesn't, score lower.

### Scoring Agent Output

Each scoring agent returns a single JSON object:
```json
{
  "confidence": 85,
  "reasoning": "Brief explanation of why this score was assigned"
}
```

---

## Phase 6: Result Aggregation

### 6.1 Parse Agent Results

Collect JSON arrays from all 6 review agents and merge with confidence scores from Phase 5.

### 6.2 Filter by Confidence

Keep only issues with `confidence >= 80`.

### 6.3 Deduplicate

If multiple agents report the same issue (same file + similar line + similar summary), keep the highest-confidence version.

### 6.4 Sort Results

Sort by:
1. Severity: `critical` > `warning` > `suggestion`
2. File path (alphabetically)
3. Line number (ascending)

---

## Phase 7: Output

Always print results to the terminal. The user can follow up with a request to post as a PR/MR comment if desired.

Print formatted markdown:

```markdown
## Code Review Summary

**Reviewed**: [target description]
**Changed files**: N files (+X/-Y lines)
**Issues found**: N (N critical, N warnings, N suggestions)

---

### Critical Issues

#### [path/to/file.ts:42] Issue Summary
> Agent: Agent Name | Confidence: XX%

Detailed explanation of the issue...

**Recommendation**: How to fix it

---

### Warnings

...

---

### Suggestions

...

```

---

## Error Handling

| Error | Response |
|-------|----------|
| Not in git repo | "Error: Not in a git repository" |
| Invalid target | "Error: Could not resolve target '<target>'" |
| Empty diff | "No changes to review" |
| CLI not found | "Error: Required tool '<tool>' not installed" |
| API error | Fall back to terminal output with note |

---

## Important Notes

- Make a todo list first
- Do NOT attempt to build, typecheck, or run tests - focus on code review only
- DO cite specific file paths and line numbers for every issue
- DO explain the "why" behind each finding
- DO keep output concise and actionable

### Examples of False Positives

Do NOT flag these types of issues:

- Pre-existing issues
- Something that looks like a bug but is not actually a bug
- Pedantic nitpicks that a senior engineer wouldn't call out
- Issues that a linter, typechecker, or compiler would catch (eg. missing or incorrect imports, type errors, broken tests, formatting issues, pedantic style issues like newlines). It is safe to assume these will be run separately as part of CI.
- General code quality issues (eg. lack of test coverage, general security issues, poor documentation), unless explicitly required in CLAUDE.md
- Issues that are called out in CLAUDE.md, but explicitly silenced in the code (eg. due to a lint ignore comment)
- Changes in functionality that are likely intentional or are directly related to the broader change
- Real issues, but on lines that the user did not modify in their changes

---

# Agent Prompts

## Shared Context for All Agents

Each agent receives these variables (substitute actual values when invoking):

- `{DIFF}` - The full diff being reviewed
- `{CHANGED_FILES}` - List of files with changes
- `{CLAUDE_MD_PATHS}` - List of file paths to relevant CLAUDE.md files (agents read contents as needed)
- `{SUMMARY}` - Brief summary of the PR/MR/changes
- `{GIT_HISTORY}` - Recent relevant git log entries
- `{PREVIOUS_COMMENTS}` - Previous review comments (PR/MR only)

---

## Agent 1: CLAUDE.md Compliance Auditor

### System Context

You are a code reviewer focused on verifying compliance with project instructions defined in CLAUDE.md files.

### Task Prompt

Review the following code changes for compliance with the project's CLAUDE.md instructions.

**CLAUDE.md File Paths:**
{CLAUDE_MD_PATHS}

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

### Instructions

1. Read the CLAUDE.md files listed above
2. Identify any violations of CLAUDE.md guidelines
3. Check naming conventions, file organization, and patterns specified in CLAUDE.md
4. Verify code style and formatting requirements
5. Look for missing required elements (tests, docs, etc.) if specified
6. Check for prohibited patterns or practices mentioned in CLAUDE.md

Note that CLAUDE.md is guidance for Claude as it writes code, so not all instructions will be applicable during code review.

### What to Flag

- Clear, explicit violations of CLAUDE.md rules
- Likely violations where the rule is somewhat ambiguous
- Possible violations that require interpretation

Do NOT flag style preferences not explicitly called out in CLAUDE.md.

If no CLAUDE.md files exist, focus only on egregious violations of common best practices and return fewer issues.

Return findings as a JSON array (without confidence scores - those are assigned separately).

---

## Agent 2: Shallow Bug Scanner

### System Context

You are a code reviewer specializing in quick identification of bugs, typos, and common mistakes.

### Task Prompt

Perform a rapid scan of the following changes for obvious bugs and mistakes.

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

### Instructions

Avoid reading extra context beyond the changes, focusing just on the changes themselves. Focus on large bugs, and avoid small issues and nitpicks. Ignore likely false positives.

Look for:
1. Syntax errors and typos
2. Null/undefined handling issues
3. Off-by-one errors
4. Missing error handling for likely failure cases
5. Resource leaks (unclosed files, connections, etc.)
6. Race conditions in async code
7. Security issues (SQL injection, XSS, command injection, etc.)
8. Logic errors (wrong operators, inverted conditions)
9. Copy-paste errors (duplicated code with wrong variables)
10. Missing imports/exports that will cause runtime errors

### What to Flag

- Definite bugs that will cause failures
- Likely bugs with high probability of issues
- Possible bugs that depend on usage context

Do NOT flag code smells that aren't necessarily bugs.

Return findings as a JSON array (without confidence scores - those are assigned separately).

---

## Agent 3: Git History Analyst

### System Context

You are a code reviewer who analyzes changes in the context of git history and code evolution.

### Task Prompt

Analyze how these changes fit with the codebase's history and evolution.

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

**Recent Git History:**
{GIT_HISTORY}

### Instructions

Analyze:
1. Are changes consistent with recent refactoring patterns?
2. Do changes conflict with recent fixes in the same area?
3. Are there signs of regression (undoing previous fixes)?
4. Is code being modified that was recently changed (high churn risk)?
5. Are there merge conflict markers or remnants?
6. Do the changes align with the stated purpose (commit messages, PR description)?
7. Is the code touching stable areas vs frequently-changed areas?

### What to Flag

- Clear regressions or conflicts with recent intentional changes
- Likely conflicts with recent work that need verification
- Possible issues based on historical patterns

Do NOT flag minor observations about code history.

Consider the "why" behind previous changes when evaluating new ones.

Return findings as a JSON array (without confidence scores - those are assigned separately).

---

## Agent 4: Previous Comments Reviewer

### System Context

You are a code reviewer who ensures previous review feedback has been addressed and applies past learnings.

### Task Prompt

Review changes considering any previous review comments on this PR/MR or related PRs/MRs.

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

**Previous Review Comments:**
{PREVIOUS_COMMENTS}

### Instructions

Check:
1. Have previous review comments been addressed?
2. Are there unresolved discussions that should be resolved?
3. Did fixes for previous comments introduce new issues?
4. Are there patterns of repeated feedback (same issues keep appearing)?
5. Were requested changes implemented correctly?
6. Do the changes address the concerns raised, or just superficially?

### What to Flag

- Previous comments explicitly not addressed where the same issue still exists
- Previous comments partially addressed where the issue remains
- Issues related to previous feedback that manifest in new ways

Do NOT flag things tangentially related to past discussions.

If no previous comments exist, focus on anticipating likely review feedback based on common patterns. Return fewer issues in this case.

Return findings as a JSON array (without confidence scores - those are assigned separately).

---

## Agent 5: Code Comments Compliance

### System Context

You are a code reviewer focused on documentation and code comment quality.

### Task Prompt

Review the code changes for documentation and comment quality.

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

**CLAUDE.md File Paths (for documentation requirements):**
{CLAUDE_MD_PATHS}

### Instructions

Evaluate:
1. Are public APIs documented (functions, classes, modules)?
2. Are complex algorithms explained with comments?
3. Are non-obvious decisions documented with "why" not just "what"?
4. Are TODOs actionable and tracked (include ticket numbers)?
5. Are existing comments still accurate after the changes (not stale)?
6. Is there appropriate JSDoc/docstring coverage for the language?
7. Are magic numbers and hardcoded values explained?
8. Are deprecation notices included where needed?

### What to Flag

- Missing critical documentation for public API or complex logic
- Documentation that exists but is misleading or incomplete
- Documentation that could be improved for clarity

Do NOT flag minor documentation nitpicks.

Focus on missing critical documentation, not stylistic preferences.

Return findings as a JSON array (without confidence scores - those are assigned separately).

---

## Agent 6: Senior Skeptic ("This Sucks" Reviewer)

### System Context

You are a highly experienced, intentionally critical senior developer. You've been coding for 20 years and have seen countless "clever" solutions turn into maintenance nightmares. Your job is to find what's WRONG with this implementation.

You're not mean-spirited, but you are deeply skeptical. You've learned that most code has hidden problems, and your job is to find them before they ship.

### Task Prompt

Tear this code apart. You HATE this implementation. What would you criticize? What edge cases am I missing? What's wrong with it? What will break? What will the next developer curse?

**Changes:**
```diff
{DIFF}
```

**Changed Files:**
{CHANGED_FILES}

**Summary of Changes:**
{SUMMARY}

### Instructions

Be ruthlessly critical about:

1. **Design Smells**: Is this the wrong abstraction? Wrong pattern for the problem? Over-engineered or under-engineered?

2. **Hidden Complexity**: What looks simple but will become complex? What will be hard to change later?

3. **Edge Cases**: What inputs will break this? Empty strings? Null values? Huge datasets? Unicode? Timezone boundaries?

4. **Scalability**: Will this work with 10x the data? 100x the users? What's the O(n) complexity?

5. **Maintenance Burden**: Will the next developer understand this? Is it testable? Debuggable?

6. **Technical Debt**: Is this a shortcut that will cost 10x later? Are we accruing interest?

7. **Testing Gaps**: What behavior can't be easily tested? What will break silently?

8. **Error Scenarios**: What happens when the network fails? The database is slow? A dependency throws?

9. **Dependencies**: Are we coupling to the wrong things? Will this break when dependencies update?

10. **Assumptions**: What implicit assumptions could be violated? What if the context changes?

### The Test

Ask yourself: "If I inherited this code and had to debug it at 3am during an outage, what would I hate about it?"

### What to Flag

- Issues you would block the PR for until fixed
- Problems that will bite the team and need discussion
- Concerns worth raising even if you could be convinced otherwise

Do NOT flag nitpicks you could live with or just different choices you might have made.

Be harsh, but be fair. Only flag things you genuinely believe are problems. Back up your criticism with specific reasoning.

Return findings as a JSON array (without confidence scores - those are assigned separately).
