# Vault-Specific Base Examples

Examples using the properties and tags found in this Obsidian vault.

## Vault Properties Reference

| Property | Type | Used In | Description |
|----------|------|---------|-------------|
| `date` | date | All templates | Creation date (YYYY-MM-DD) |
| `tags` | list | All files | Category tags and topics (topics use `topic/` prefix) |
| `status` | string | Plans | Workflow status (e.g., "draft") |
| `jira_issue` | string | Plans | JIRA ticket reference |
| `source` | string | Clippings | Source URL |
| `author` | list | Clippings | Article author(s) |
| `summary` | string | Plans, Research | Brief description |
| `title` | string | Clippings | Article title |

## Common Tags

| Tag | Meaning | Folder |
|-----|---------|--------|
| `daily_note` | Daily journal entries | Daily Notes/ |
| `clippings` | Saved web articles | Clippings/ |
| `plan` | Implementation plans | Any |
| `research` | Research projects | Research/ |
| `ai_generated` | Claude-generated content | Any |
| `topic/*` | Topic tags (e.g., `topic/kubernetes`) | Any |

---

## Daily Notes Bases

### This Week's Notes

```yaml
filters:
  and:
    - file.hasTag("daily_note")
    - date >= today() - duration("7d")
views:
  - type: table
    name: "This Week"
    sort:
      - property: date
        direction: DESC
```

### Last 30 Days

```yaml
filters:
  and:
    - file.hasTag("daily_note")
    - date >= today() - duration("30d")
views:
  - type: list
    name: "Recent Notes"
    markers: none
    sort:
      - property: date
        direction: DESC
```

### Daily Notes by Month

```yaml
filters:
  and:
    - file.hasTag("daily_note")

formulas:
  month_label: date.format("MMMM YYYY")

views:
  - type: table
    name: "By Month"
    groupBy:
      property: formula.month_label
      direction: DESC
    sort:
      - property: date
        direction: DESC
```

---

## Clippings Bases

### All Clippings

```yaml
filters:
  and:
    - file.hasTag("clippings")
views:
  - type: table
    name: "All Articles"
    sort:
      - property: date
        direction: DESC
```

### By Author

```yaml
filters:
  and:
    - file.hasTag("clippings")

formulas:
  first_author: author.first()

views:
  - type: table
    name: "By Author"
    groupBy:
      property: formula.first_author
      direction: ASC
    sort:
      - property: date
        direction: DESC
```

### Recently Added Clippings

```yaml
filters:
  and:
    - file.hasTag("clippings")
    - date >= today() - duration("14d")
views:
  - type: cards
    name: "Recent Reads"
    cardSize: medium
    sort:
      - property: date
        direction: DESC
```

### Clippings with Source Domain

```yaml
filters:
  and:
    - file.hasTag("clippings")
    - source != null

formulas:
  domain: source.replace(/https?:\/\/([^\/]+).*/, "$1")

views:
  - type: table
    name: "By Source"
    groupBy:
      property: formula.domain
      direction: ASC
```

---

## Research Bases

### All Research

```yaml
filters:
  and:
    - file.hasTag("research")
views:
  - type: table
    name: "All Research"
    sort:
      - property: date
        direction: DESC
```

### Research by Topic

```yaml
# Filter tags that start with "topic/" to group by topic
filters:
  and:
    - file.hasTag("research")
    - file.hasTag("topic/")
views:
  - type: cards
    name: "By Topic"
    groupBy:
      property: tags
      direction: ASC
    cardSize: medium
```

### AI-Generated Research

```yaml
filters:
  and:
    - file.hasTag("research")
    - file.hasTag("ai_generated")
views:
  - type: table
    name: "AI Research"
    sort:
      - property: date
        direction: DESC
```

### Research on Specific Topic

```yaml
filters:
  and:
    - file.hasTag("research")
    - file.hasTag("topic/knowledge-management")
views:
  - type: table
    name: "Knowledge Management"
    sort:
      - property: date
        direction: DESC
```

---

## Plans Bases

### All Plans

```yaml
filters:
  and:
    - file.hasTag("plan")
views:
  - type: table
    name: "All Plans"
    sort:
      - property: date
        direction: DESC
```

### Active/Draft Plans

```yaml
filters:
  and:
    - file.hasTag("plan")
    - status == "draft"
views:
  - type: table
    name: "In Progress"
    sort:
      - property: date
        direction: DESC
```

### Plans with JIRA Issues

```yaml
filters:
  and:
    - file.hasTag("plan")
    - jira_issue != null

formulas:
  jira_link: if(jira_issue, link("https://mintel.atlassian.net/browse/" + jira_issue, jira_issue), "")

views:
  - type: table
    name: "With JIRA"
    sort:
      - property: date
        direction: DESC
```

### Plans by Status

```yaml
filters:
  and:
    - file.hasTag("plan")

formulas:
  display_status: if(status, status.title(), "No Status")

views:
  - type: table
    name: "By Status"
    groupBy:
      property: formula.display_status
      direction: ASC
    sort:
      - property: date
        direction: DESC
```

---

## Cross-Content Bases

### Recently Modified Files

```yaml
filters:
  not:
    - file.inFolder("Templates")

views:
  - type: table
    name: "Recent Changes"
    sort:
      - property: file.mtime
        direction: DESC
    limit: 25
```

### Files by Folder

```yaml
filters:
  not:
    - file.inFolder(".obsidian")
    - file.inFolder("Templates")

formulas:
  folder: file.path.replace(/\/[^\/]+$/, "")

views:
  - type: table
    name: "By Folder"
    groupBy:
      property: formula.folder
      direction: ASC
```

### All Tagged Content

```yaml
filters:
  or:
    - file.hasTag("daily_note")
    - file.hasTag("clippings")
    - file.hasTag("plan")
    - file.hasTag("research")

formulas:
  content_type: if(file.hasTag("daily_note"), "Daily Note",
                if(file.hasTag("clippings"), "Clipping",
                if(file.hasTag("plan"), "Plan",
                if(file.hasTag("research"), "Research", "Other"))))

views:
  - type: table
    name: "All Content"
    groupBy:
      property: formula.content_type
      direction: ASC
    sort:
      - property: date
        direction: DESC
```

### Files Missing Required Properties

```yaml
filters:
  and:
    - or:
        - file.hasTag("plan")
        - file.hasTag("research")
    - or:
        - date == null
        - summary == null

views:
  - type: table
    name: "Needs Attention"
```

---

## Utility Patterns

### Exclude Templates and System Folders

```yaml
filters:
  and:
    - your_other_filters
    - not:
        - file.inFolder("Templates")
        - file.inFolder(".obsidian")
```

### Date Range (Custom)

```yaml
# Files from Q1 2024
filters:
  and:
    - date >= date("2024-01-01")
    - date < date("2024-04-01")
```

### Empty or Missing Property

```yaml
# Files without summary
filters:
  and:
    - file.hasTag("research")
    - or:
        - summary == null
        - summary == ""
```

### Files Linking to Specific Note

```yaml
filters:
  and:
    - file.hasLink("[[Index]]")
```
