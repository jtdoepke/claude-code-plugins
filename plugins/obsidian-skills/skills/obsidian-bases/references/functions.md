# Obsidian Bases Functions Reference

Functions manipulate data from properties in filters and formulas.

## Global Functions

These work without a specific data type.

| Function | Description | Example |
|----------|-------------|---------|
| `if(condition, true_val, false_val?)` | Conditional logic | `if(status, status, "None")` |
| `now()` | Current date and time | `now()` |
| `today()` | Today at midnight | `today()` |
| `date(string)` | Parse date from string | `date("2024-01-15")` |
| `duration(string)` | Parse duration | `duration("7d")` |
| `file(path)` | Get file object | `file("Notes/example.md")` |
| `link(path, display?)` | Create link | `link(file.path, title)` |
| `list(value)` | Wrap as list | `list(tag)` |
| `number(value)` | Convert to number | `number("42")` |
| `max(a, b, ...)` | Largest value | `max(price, 0)` |
| `min(a, b, ...)` | Smallest value | `min(count, 100)` |
| `image(path)` | Render image | `image(cover)` |
| `icon(name)` | Lucide icon | `icon("star")` |
| `html(string)` | Render HTML | `html("<b>Bold</b>")` |
| `escapeHTML(string)` | Escape HTML chars | `escapeHTML(content)` |

### Duration Strings

Used with `duration()` and date arithmetic:

| Unit | Examples |
|------|----------|
| Days | `"1d"`, `"7d"`, `"30d"` |
| Weeks | `"1w"`, `"2w"` |
| Months | `"1M"`, `"3M"`, `"12M"` |
| Years | `"1y"`, `"5y"` |
| Hours | `"1h"`, `"24h"` |
| Minutes | `"30m"`, `"90m"` |
| Seconds | `"60s"` |
| Milliseconds | `"1000ms"` |
| Combined | `"1d12h"`, `"2w3d"` |

## Date Functions

Methods on date values.

| Function | Returns | Example |
|----------|---------|---------|
| `.year` | number | `date.year` |
| `.month` | number (1-12) | `date.month` |
| `.day` | number (1-31) | `date.day` |
| `.hour` | number (0-23) | `date.hour` |
| `.minute` | number (0-59) | `date.minute` |
| `.second` | number (0-59) | `date.second` |
| `.millisecond` | number | `date.millisecond` |
| `.weekday` | number (1-7) | `date.weekday` |
| `.format(pattern)` | string | `date.format("YYYY-MM-DD")` |
| `.relative()` | string | `date.relative()` → "3 days ago" |

### Format Patterns

Uses Moment.js patterns:

| Pattern | Description | Example |
|---------|-------------|---------|
| `YYYY` | 4-digit year | 2024 |
| `YY` | 2-digit year | 24 |
| `MM` | Month (01-12) | 03 |
| `MMM` | Short month | Mar |
| `MMMM` | Full month | March |
| `DD` | Day (01-31) | 15 |
| `ddd` | Short weekday | Fri |
| `dddd` | Full weekday | Friday |
| `HH` | Hour (00-23) | 14 |
| `hh` | Hour (01-12) | 02 |
| `mm` | Minute | 30 |
| `ss` | Second | 45 |
| `A` | AM/PM | PM |

Example: `date.format("ddd, MMM D YYYY")` → "Fri, Mar 15 2024"

### Date Arithmetic

```yaml
formulas:
  days_ago: (today() - date).days
  due_in_week: date + duration("7d")
  is_overdue: date < today()
  next_month: date + duration("1M")
```

## String Functions

Methods on string values.

| Function | Returns | Example |
|----------|---------|---------|
| `.length` | number | `title.length` |
| `.contains(substr)` | boolean | `title.contains("TODO")` |
| `.startsWith(prefix)` | boolean | `title.startsWith("Draft")` |
| `.endsWith(suffix)` | boolean | `file.name.endsWith(".md")` |
| `.lower()` | string | `status.lower()` |
| `.upper()` | string | `status.upper()` |
| `.title()` | string | `status.title()` → "In Progress" |
| `.trim()` | string | `title.trim()` |
| `.replace(old, new)` | string | `title.replace("-", " ")` |
| `.split(delim)` | list | `tags.split(",")` |
| `.slice(start, end?)` | string | `title.slice(0, 50)` |
| `.padStart(len, char)` | string | `id.padStart(5, "0")` |
| `.padEnd(len, char)` | string | `code.padEnd(10, " ")` |

## Number Functions

Methods on numeric values.

| Function | Returns | Example |
|----------|---------|---------|
| `.abs()` | number | `diff.abs()` |
| `.ceil()` | number | `rating.ceil()` |
| `.floor()` | number | `rating.floor()` |
| `.round()` | number | `average.round()` |
| `.toFixed(decimals)` | string | `price.toFixed(2)` → "19.99" |
| `.sign()` | number (-1, 0, 1) | `change.sign()` |

## List Functions

Methods on array values (tags, links, etc.).

| Function | Returns | Example |
|----------|---------|---------|
| `.length` | number | `tags.length` |
| `.first()` | any | `tags.first()` |
| `.last()` | any | `tags.last()` |
| `.at(index)` | any | `tags.at(0)` |
| `.contains(item)` | boolean | `tags.contains("research")` |
| `.join(delim)` | string | `tags.join(", ")` |
| `.sort()` | list | `tags.sort()` |
| `.reverse()` | list | `items.reverse()` |
| `.unique()` | list | `tags.unique()` |
| `.flatten()` | list | `nested.flatten()` |
| `.map(fn)` | list | `prices.map(p => p * 1.1)` |
| `.filter(fn)` | list | `items.filter(i => i > 0)` |
| `.reduce(fn, init)` | any | `nums.reduce((a, b) => a + b, 0)` |
| `.some(fn)` | boolean | `tags.some(t => t == "urgent")` |
| `.every(fn)` | boolean | `scores.every(s => s > 50)` |
| `.find(fn)` | any | `items.find(i => i.active)` |
| `.findIndex(fn)` | number | `items.findIndex(i => i.id == 5)` |
| `.includes(item)` | boolean | `list.includes("value")` |
| `.slice(start, end?)` | list | `items.slice(0, 5)` |

### Map/Filter Examples

```yaml
formulas:
  # Double all prices
  doubled: prices.map(p => p * 2)

  # Keep only high scores
  passing: scores.filter(s => s >= 70)

  # Sum all values
  total: amounts.reduce((sum, a) => sum + a, 0)

  # Check if any urgent
  has_urgent: tags.some(t => t.contains("urgent"))
```

## File Functions

Methods on `file.file` objects.

| Function | Returns | Example |
|----------|---------|---------|
| `.name` | string | `file.file.name` |
| `.path` | string | `file.file.path` |
| `.ext` | string | `file.file.ext` |
| `.size` | number | `file.file.size` |
| `.mtime` | date | `file.file.mtime` |
| `.ctime` | date | `file.file.ctime` |
| `.tags` | list | `file.file.tags` |
| `.links` | list | `file.file.links` |
| `.inFolder(name)` | boolean | `file.file.inFolder("Daily Notes")` |
| `.hasTag(tag)` | boolean | `file.file.hasTag("research")` |
| `.hasLink(link)` | boolean | `file.file.hasLink("[[Index]]")` |

### Filter by Tag

Use the `.hasTag()` method in filters:

```yaml
filters:
  and:
    - file.hasTag("plan")
```

This checks if a file has the specified tag.

## Link Functions

Methods on link values.

| Function | Returns | Example |
|----------|---------|---------|
| `.path` | string | `link.path` |
| `.display` | string | `link.display` |
| `.asFile()` | file | `link.asFile()` |

## Object Functions

For working with object properties.

| Function | Returns | Example |
|----------|---------|---------|
| `.keys()` | list | `metadata.keys()` |
| `.values()` | list | `metadata.values()` |
| `.entries()` | list | `metadata.entries()` |

## RegExp Functions

For pattern matching.

| Function | Returns | Example |
|----------|---------|---------|
| `.matches(pattern)` | boolean | `title.matches(/^Draft/)` |
| `.match(pattern)` | list | `text.match(/\d+/)` |
| `.replace(pattern, repl)` | string | `text.replace(/\s+/, " ")` |
