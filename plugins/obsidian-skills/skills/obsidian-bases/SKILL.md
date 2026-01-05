---
name: obsidian-bases
description: Create and configure Obsidian Bases (database-like views for notes). Use when creating .base files, embedding bases in markdown, writing base formulas or filters, configuring table/list/cards/map views, or querying vault content by properties like tags, dates, topics, or status.
---

# Obsidian Bases

Bases are database-like views that display, filter, sort, and group notes based on their properties. Data stays in markdown files; bases just provide views.

## Quick Start

Create a `.base` file with this structure:

```yaml
filters:
  and:
    - file.hasTag("daily_note")
views:
  - type: table
    name: "My View"
```

Or embed in markdown using a `base` code block.

## File Formats

### Standalone `.base` files
- Create in any folder
- Embed in notes with `![[filename.base]]`
- Embed specific view: `![[filename.base#ViewName]]`

### Embedded code blocks
````markdown
```base
filters:
  and:
    - file.hasTag("research")
views:
  - type: table
    name: "Research"
```
````

## Core Syntax

### Filters

Filters narrow which files appear. Use `and`, `or`, `not` operators:

```yaml
filters:
  and:
    - file.hasTag("plan")
    - status == "draft"
```

```yaml
filters:
  or:
    - file.hasTag("research")
    - file.hasTag("plan")
```

```yaml
filters:
  not:
    - file.inFolder("Templates")
```

Common filter expressions:
- `file.hasTag("tagname")` - files with specific tag (hierarchical matching)
- `property == "value"` - exact property match
- `property.contains("text")` - string/list contains value
- `property >= value` - numeric/date comparison
- `file.inFolder("FolderName")` - files in folder (hierarchical matching)

### Views

Each base can have multiple views with different layouts:

```yaml
views:
  - type: table
    name: "Table View"
    sort:                      # Row sorting
      - property: date
        direction: DESC
    order:                     # Column ordering (property names)
      - file.name
      - date
      - status
    limit: 50
  - type: cards
    name: "Card View"
    groupBy:                   # Object form with direction
      property: topics
      direction: ASC
```

**View types**: `table`, `list`, `cards`, `map`

**Sorting vs Ordering**:
- `sort:` - Controls row sorting (objects with `property` and `direction`)
- `order:` - Controls column ordering (list of property names)

### Formulas

Create computed properties:

```yaml
formulas:
  days_old: (today() - date).days
  display_name: if(title, title, file.name)
```

Reference in views with `formula.property_name`.

### Properties

Configure how properties display:

```yaml
properties:
  date:
    displayName: "Created"
  status:
    displayName: "Status"
```

### Summaries

Add aggregations to views:

```yaml
views:
  - type: table
    name: "Tasks"
    summaries:
      status:
        type: count
```

Built-in summaries: `count`, `sum`, `average`, `min`, `max`, `median`, `range`, `stddev`

## View Types Overview

| Type | Use Case | Key Features |
|------|----------|--------------|
| Table | Structured data | Sortable columns, summaries, keyboard nav |
| List | Simple lists | Bullet/numbered markers, nested properties |
| Cards | Visual gallery | Cover images, grid layout |
| Map | Location data | Interactive pins (requires Maps plugin) |

## Reference Documentation

For detailed information, read these reference files:

- **`references/syntax.md`** - Complete YAML schema and operators
- **`references/functions.md`** - All available functions by category
- **`references/views.md`** - View type configuration details
- **`references/vault-examples.md`** - Examples using this vault's properties

## This Vault's Properties

Common properties used in this vault:
- `date` - Creation date (YYYY-MM-DD format)
- `tags` - Array of categories and topics (topics use `topic/` prefix)
- `status` - Workflow status (e.g., "draft")
- `jira_issue` - JIRA ticket reference
- `source` - URL for clippings
- `author` - Content author
- `summary` - Brief description

Common tags:
- `daily_note` - Daily journal entries
- `clippings` - Saved web articles
- `plan` - Implementation plans
- `research` - Research projects
- `ai_generated` - Claude-generated content
- `topic/example-topic` - Topic tags (use `topic/` prefix for topics)
