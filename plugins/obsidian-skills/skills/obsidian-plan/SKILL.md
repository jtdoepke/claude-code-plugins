---
name: obsidian-plan
description: Create project implementation plans in the Obsidian vault. Use when asked to create a project plan, plan a project, design an implementation, or create a technical plan.
---

# Project Plan Skill

## Instructions

When asked to create a project plan:

1. **Check existing topics**: List files in `Bases/` to find relevant existing topics
2. **Gather context**: Understand requirements, constraints, and related work
3. **Create the note**: Save to `Plans/YYYY-MM-DD-topic-name.md` (kebab-case)

## Template

Use the template in `references/template.md` as the starting point for new plan notes. Replace `{{date:YYYY-MM-DD}}` with the actual date and `{{title}}` with the plan title.

## Planning Process

Use deep critical thinking when creating plans:
- Anticipate hidden complexities and technical debt
- Consider long-term maintainability and scalability
- Evaluate trade-offs beyond surface level
- Identify potential failure modes early
- Challenge common patterns when inappropriate
- Think through second-order consequences of decisions

### 1. Requirements Analysis
- Understand project goals and constraints
- Identify target users and use cases
- Define success criteria
- Assess technical requirements

### 2. Deep Research & Critical Analysis
Investigate:
- Existing research in `.claude/research/`
- Similar solutions and best practices
- Technology options and trade-offs
- Suitable design patterns
- Development approaches

### 3. Architecture Design
- System architecture diagrams
- Component breakdown
- Data flow design
- API specifications
- Security considerations

### 4. Technology Stack
Recommend optimal stack based on requirements, team expertise, scalability needs, budget, and time constraints.

### 5. Implementation Roadmap
Create phased plan with clear milestones.

### 6. Documentation
- Create Architecture Decision Records (ADRs) for major choices
- Update relevant CLAUDE.md files with project overview and key decisions

## Core Philosophy

**Inevitable code** is code where every design choice feels like the only sensible option. When developers encounter your solution, they should think: "Of course it works this way. How else would it work?"

### Key Principles

#### 1. Optimize for the Reader's Cognitive Experience
- **Reader > Writer**: Prioritize the developer who will read and modify this code
- **Immediate Clarity**: Solutions should be self-evident without extensive documentation
- **Eliminate Surprise**: Behavior should match expectations (Principle of Least Astonishment)

#### 2. Simple Interfaces, Sophisticated Implementations
- **Surface Simplicity**: External interfaces should be clean, minimal, and intuitive
- **Hidden Complexity**: Accept internal complexity to eliminate external cognitive load
- **Strategic Design**: Embrace implementation challenges to serve future developers

#### 3. Dissolve Problems, Don't Just Solve Them
- **Make the Right Way Obvious**: Design so the correct approach feels natural
- **Eliminate Wrong Paths**: Remove opportunities for misuse or confusion
- **Natural Constraints**: Guide developers toward success through intelligent constraints

#### 4. Cognitive Load Minimization
- **Single Responsibility**: Each component should have one clear, focused purpose
- **Familiar Patterns**: Leverage existing mental models and common conventions
- **Clear Hierarchy**: Make importance and relationships visually and structurally obvious
- **Localized Effects**: Changes should have predictable, contained impact

#### 5. Inevitable Architecture
- **Obvious Organization**: File structure, naming, and modules should reflect natural domain boundaries
- **Expected Dependencies**: Dependencies should flow in the direction users would naturally expect
- **Natural Evolution**: The codebase should accommodate growth in predictable ways

## Quality Gates

Before finalizing a plan, ask:
- Would a new developer understand this intuitively?
- Does this solution feel "inevitable" rather than clever?
- Have I eliminated opportunities for misunderstanding?
- Is the cognitive load distributed appropriately?
- Does the interface hide the right level of detail?

## Frontmatter Format

```yaml
---
tags:
  - ai_generated
  - plan
  - topic/existing-topic
  - topic/another-topic
date: "YYYY-MM-DD"
summary: "One-line summary of the plan"
status: draft
jira_issue:
author: "Claude Code"
---
```

## Required Sections

- **Context**: Background and problem being solved
- **Requirements**: What needs to be achieved
- **Architecture** (optional): System design, components, data flow - include for technical plans
- **Implementation Steps**: Ordered steps to complete the project
  - Use checkboxes (`- [ ]` / `- [x]`) to track completion of each step
  - Add inline notes with `> [!note]` callouts for implementation details, decisions, or blockers
  - Update checkboxes as work progresses
- **Testing**: How to verify the implementation works
- **Sources**: URLs and references used (listed at bottom)

## Status Values

- `draft` - Initial creation, still being developed
- `ready` - Plan is complete and ready for implementation
- `in-progress` - Implementation has started
- `complete` - Plan has been fully implemented

## Implementation Progress Tracking

When a plan is `in-progress`, track progress within the Implementation Steps section:

### Checkbox Format
- `- [ ]` - Not started
- `- [x]` - Completed

### Progress Notes
Add notes under steps to capture:
- Decisions made during implementation
- Blockers or issues encountered
- Links to commits, PRs, or related resources

### Example

```markdown
## Implementation Steps

- [x] Set up project repository
  > [!note] Created at gitlab.com/mintel/project - 2024-01-15
- [x] Configure CI/CD pipeline
- [ ] Implement core functionality
  > [!note] Blocked: waiting on API spec from team
- [ ] Write tests
- [ ] Deploy to staging
```

## Topic Management

- Add relevant topics as tags with the `topic/` prefix (e.g., `topic/infrastructure-as-code`)
- Use kebab-case for topic names
- Notes can have multiple topic tags

### Existing Topics

Run the helper script to list existing topics in the vault:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/obsidian-plan/scripts/list-topics.sh ${CLAUDE_PROJECT_DIR}
```

## Linking

- Use `[[wikilinks]]` inline to link to related vault notes
- Do not create a separate "Related" section; integrate links naturally in the text

## Jira Integration

- If the plan relates to a Jira issue, add the issue key to `jira_issue` field
