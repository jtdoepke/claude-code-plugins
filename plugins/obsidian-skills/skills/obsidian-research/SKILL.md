---
name: obsidian-research
description: Create research notes in the Obsidian vault. ALWAYS use if the user requests "research". Otherwise, use when the user asks to: compare technologies or approaches, evaluate options, make recommendations ("which should I use", "what's the best"), or investigate/look into a topic. Do NOT use for simple facts, explanations, or how-to questions, unless the user has asked for "research".
---

# Research Notes Skill

## Instructions

When asked to research a topic, follow the Research Workflow below. The workflow scales based on topic complexity - simple topics skip directly to creating the note, while comprehensive research uses parallel exploration followed by deep analysis.

## Research Workflow

### Phase 1: Initial Assessment
1. Check existing topics in the vault using the helper script
2. Assess complexity to determine research depth (simple vs comprehensive)
3. For comprehensive research, identify 2-4 distinct dimensions of the topic that would benefit from parallel exploration

### Phase 2: Exploration (Comprehensive Research Only)
**Launch up to 4 Explore agents IN PARALLEL** to survey the topic from different angles. Each agent should have a specific focus.

Dimensions to explore might include:
- Different subtopics or aspects of the research question
- Competing approaches or technologies being compared
- Different source types (official documentation, community discussion, academic research)
- Contrasting perspectives (proponents vs critics, different use cases)
- Different aspects of evaluation (performance, security, cost, usability)

**Guidelines:**
- Use 1 agent when the topic is narrow or well-defined
- Use multiple agents when comparing options, evaluating complex topics, or needing diverse perspectives
- Quality over quantity - use the minimum number of agents necessary
- Each agent should return: key sources found, main concepts/terms, summary of findings
- Agents have access to all tools (web search, Sourcegraph, Confluence, documentation, etc.)

### Phase 3: Deep Research (Main Thread)
Using the exploration results as guidance:
1. Read/fetch the most relevant sources identified by Explore agents
2. Apply the critical analysis framework to claims and findings
3. Cross-reference information across sources
4. Identify gaps, contradictions, or areas needing clarification

### Phase 4: Synthesis & Output
1. Integrate findings into a coherent narrative
2. Form recommendations with supporting evidence
3. Create the research note using the template
4. Save to `Research/YYYY-MM-DD-topic-name.md` (kebab-case)

## Template

Use the template in `references/template.md` as the starting point for new research notes. Replace `{{date:YYYY-MM-DD}}` with the actual date and `{{title}}` with the research title.

## Research Depth

Scale research effort to topic complexity:

### Simple Research
For quick lookups, factual questions, or narrow topics:
- Skip Phase 2 (Exploration agents)
- Direct web search or documentation lookup
- Straightforward synthesis into research note

### Comprehensive Research
For complex topics, comparisons, or strategic decisions:
- Execute full workflow including Phase 2 exploration
- Deploy parallel Explore agents to survey the landscape
- Main thread performs deep analysis on exploration findings
- Thorough synthesis with critical evaluation

## Source Types

When researching comprehensively, consider gathering information from multiple source types:

- **Academic**: Papers, studies, specifications, standards
- **Industry**: Best practices, case studies, vendor documentation
- **Community**: Forums, blogs, discussions, Stack Overflow
- **Technical**: Implementation details, benchmarks, code examples
- **Comparison**: Alternative solutions, competing approaches

## Information Synthesis

When synthesizing findings:

- Cross-reference information across sources
- Validate claims with multiple sources
- Identify patterns and contradictions
- Extract consensus views
- Highlight dissenting opinions or minority perspectives

## Analysis Framework

Apply critical evaluation to findings:

- **Claims vs evidence**: Distinguish opinion from substantiated fact
- **Hidden costs and trade-offs**: What are the downsides not mentioned?
- **Long-term implications**: Second and third-order effects
- **Edge cases and failure modes**: Where does this break down?

## Frontmatter Format

```yaml
---
tags:
  - ai_generated
  - research
  - topic/existing-topic
  - topic/another-topic
date: "YYYY-MM-DD"
summary: "One-line summary of the research"
author: "Claude Code"
---
```

## Required Sections

Core sections (always include):

- **Context**: Background and motivation for this research
- **Findings**: Key discoveries and information gathered
- **Analysis**: Interpretation, implications, and connections
- **Sources**: URLs and references used (listed at bottom)

Optional sections (for comprehensive research):

- **Executive Summary**: Brief overview of key conclusions (at top, after Context)
- **Comparison Matrix**: Table comparing alternatives (when evaluating options)
- **Implementation Guidance**: Practical next steps (when actionable)
- **Decision Framework**: Criteria for choosing between options (when decision-focused)

## Topic Management

- Add relevant topics as tags with the `topic/` prefix (e.g., `topic/infrastructure-as-code`)
- Use kebab-case for topic names
- Notes can have multiple topic tags

### Existing Topics

Run the helper script to list existing topics in the vault:
```bash
${CLAUDE_PLUGIN_ROOT}/skills/obsidian-research/scripts/list-topics.sh ${CLAUDE_PROJECT_DIR}
```

## Linking

- Use `[[wikilinks]]` inline to link to related vault notes
- Do not create a separate "Related" section; integrate links naturally in the text
