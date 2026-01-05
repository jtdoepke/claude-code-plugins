# Obsidian Bases Syntax Reference

Bases are stored as `.base` files containing valid YAML. This document covers the complete schema.

## Top-Level Structure

```yaml
filters:           # Narrow which files appear
  and: []          # All conditions must match
  or: []           # Any condition can match
  not: []          # Exclude matching files

formulas:          # Computed properties
  name: expression

properties:        # Display configuration
  property_name:
    displayName: "Label"

summaries:         # Custom aggregations (for all views)
  name: expression

views:             # View definitions
  - type: table
    name: "View Name"
```

## Filters

By default, a base includes every file in the vault. Filters narrow results.

### Logical Operators

```yaml
# AND - all conditions must be true
filters:
  and:
    - condition1
    - condition2

# OR - any condition can be true
filters:
  or:
    - condition1
    - condition2

# NOT - exclude matching files
filters:
  not:
    - condition

# Nested logic
filters:
  and:
    - file.hasTag("research")
    - or:
        - file.hasTag("topic/aws")
        - file.hasTag("topic/kubernetes")
```

### Filter Expressions

| Expression | Description |
|------------|-------------|
| `property == "value"` | Exact match |
| `property != "value"` | Not equal |
| `property > value` | Greater than (numbers/dates) |
| `property >= value` | Greater than or equal |
| `property < value` | Less than |
| `property <= value` | Less than or equal |
| `property.contains("text")` | String/list contains value |
| `file.hasTag("tag")` | Has specific tag (hierarchical) |
| `file.inFolder("Folder")` | In specific folder (hierarchical) |
| `file.hasLink("[[Note]]")` | Links to note |

### Date Filters

```yaml
filters:
  and:
    - date >= today() - duration("7d")    # Last 7 days
    - date < today()                       # Before today
```

Duration strings: `"1d"` (day), `"1w"` (week), `"1M"` (month), `"1y"` (year), `"2h"` (hours)

## Property Types

### Note Properties
From YAML frontmatter. Access as `property` or `note.property`:
```yaml
formulas:
  is_draft: status == "draft"
  has_jira: jira_issue != null
```

### File Properties
Built-in metadata about the file:

| Property | Type | Description |
|----------|------|-------------|
| `file.name` | string | Filename without extension |
| `file.path` | string | Full path from vault root |
| `file.ext` | string | File extension |
| `file.size` | number | Size in bytes |
| `file.mtime` | date | Last modified time |
| `file.ctime` | date | Creation time |
| `file.tags` | list | All tags in file |
| `file.links` | list | All outgoing links |
| `file.file` | file | File object for methods |

### Formula Properties
Reference other formulas with `formula.name`:
```yaml
formulas:
  base_price: price * 0.8
  final_price: formula.base_price + tax
```

## Formulas

Formulas create computed properties using expressions.

### Operators

| Category | Operators |
|----------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%` |
| Comparison | `==`, `!=`, `>`, `<`, `>=`, `<=` |
| Boolean | `!`, `&&`, `||` |
| Grouping | `( )` |

### Examples

```yaml
formulas:
  # Conditional display
  display_title: if(title, title, file.file.name)

  # Date calculations
  age_days: (today() - date).days
  is_recent: date >= today() - duration("30d")

  # String manipulation
  short_name: file.file.name.slice(0, 20)

  # List operations
  tag_count: file.tags.length
  first_topic: topics[0]
```

## Views

Each view defines how data renders.

### Common View Options

```yaml
views:
  - type: table           # table, list, cards, map
    name: "Display Name"  # Required

    # Row Sorting (objects with property/direction)
    sort:
      - property: date
        direction: DESC   # ASC or DESC
      - property: title
        direction: ASC

    # Column Ordering (list of property names)
    order:
      - file.name
      - date
      - status

    # Grouping (object form with direction)
    groupBy:
      property: status
      direction: ASC

    # Limit results
    limit: 100

    # View-specific filters (in addition to base filters)
    filter:
      and:
        - status == "active"

    # Property summaries
    summaries:
      price:
        type: sum
```

**Note**: `sort:` and `order:` serve different purposes:
- `sort:` controls row sorting (which items appear first)
- `order:` controls column ordering (which properties display left-to-right)

### Summary Types

| Type | Description | Applies To |
|------|-------------|------------|
| `count` | Count non-empty values | All types |
| `empty` | Count empty values | All types |
| `unique` | Count unique values | All types |
| `sum` | Total | Numbers |
| `average` | Mean | Numbers |
| `min` | Minimum | Numbers, Dates |
| `max` | Maximum | Numbers, Dates |
| `median` | Median | Numbers |
| `range` | Max - Min | Numbers, Dates |
| `stddev` | Standard deviation | Numbers |
| `checked` | Count checked | Checkboxes |
| `unchecked` | Count unchecked | Checkboxes |
| `earliest` | First date | Dates |
| `latest` | Last date | Dates |

### Custom Summaries

```yaml
summaries:
  weighted_avg: values.map(v => v.price * v.quantity).sum() / values.map(v => v.quantity).sum()

views:
  - type: table
    name: "Products"
    summaries:
      price:
        type: custom
        formula: formula.weighted_avg
```

## Properties Display

Configure how properties appear in views:

```yaml
properties:
  date:
    displayName: "Created On"
  status:
    displayName: "Current Status"
  jira_issue:
    displayName: "JIRA"
```

## Complete Example

```yaml
filters:
  and:
    - file.hasTag("plan")
    - "!file.inFolder(\"Templates\")"

formulas:
  age: (today() - date).days
  display_status: if(status, status.title(), "Unknown")

properties:
  date:
    displayName: "Created"
  jira_issue:
    displayName: "JIRA Issue"

views:
  - type: table
    name: "Active Plans"
    sort:
      - property: date
        direction: DESC
    order:
      - file.name
      - date
      - status
    filter:
      and:
        - status == "draft"
    summaries:
      status:
        type: count

  - type: cards
    name: "By Status"
    groupBy:
      property: status
      direction: ASC
```
