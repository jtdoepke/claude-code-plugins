# Obsidian Bases Views Reference

Views define how base data renders. Each base can have multiple views with different layouts.

## Common View Options

All view types share these options:

```yaml
views:
  - type: table          # Required: table, list, cards, map
    name: "View Name"    # Required: display name

    # Row sorting (optional)
    sort:
      - property: date
        direction: DESC  # ASC or DESC

    # Column ordering (optional, list of property names)
    order:
      - file.name
      - date
      - status

    # Grouping (optional, object form with direction)
    groupBy:
      property: status
      direction: ASC

    # Result limit (optional)
    limit: 100

    # View-specific filter (optional, adds to base filters)
    filter:
      and:
        - status == "active"
```

**Note**: `sort:` and `order:` serve different purposes:
- `sort:` controls row sorting (which items appear first)
- `order:` controls column ordering (which properties display)

## Table View

Display files as rows with property columns. Best for structured data.

```yaml
views:
  - type: table
    name: "All Items"
    rowHeight: medium    # short, medium, tall, extra-tall
    sort:
      - property: date
        direction: DESC
    summaries:
      price:
        type: sum
      count:
        type: average
```

### Row Heights

| Height | Use Case |
|--------|----------|
| `short` | Compact lists, minimal content |
| `medium` | Default, balanced display |
| `tall` | More content visible |
| `extra-tall` | Long text, multiple properties |

### Column Summaries

Add calculations to column footers:

```yaml
views:
  - type: table
    name: "Products"
    summaries:
      price:
        type: sum
      quantity:
        type: average
      date:
        type: latest
```

Available types:
- **All properties**: `count`, `empty`, `unique`
- **Numbers**: `sum`, `average`, `min`, `max`, `median`, `range`, `stddev`
- **Dates**: `earliest`, `latest`, `range`
- **Checkboxes**: `checked`, `unchecked`

### Custom Summaries

```yaml
summaries:
  total_value: values.reduce((sum, v) => sum + (v.price * v.quantity), 0)

views:
  - type: table
    name: "Inventory"
    summaries:
      price:
        type: custom
        formula: formula.total_value
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Arrow keys | Navigate cells |
| Enter | Focus cell / Confirm edit |
| Escape | Exit edit mode |
| Ctrl/Cmd + C | Copy cell |
| Shift + Space | Select row |
| Ctrl/Cmd + A | Select all |

## List View

Display files as bulleted or numbered lists. Best for simple collections.

```yaml
views:
  - type: list
    name: "Reading List"
    markers: bullet       # bullet, number, none
    indentProperties: true
    separator: ", "       # Used when indentProperties: false
```

### Options

| Option | Values | Description |
|--------|--------|-------------|
| `markers` | `bullet`, `number`, `none` | List marker style |
| `indentProperties` | `true`, `false` | Show properties as nested items |
| `separator` | string | Character between inline properties |

### With Nested Properties

```yaml
views:
  - type: list
    name: "Tasks"
    markers: bullet
    indentProperties: true
    # Properties appear indented under each file
```

### Inline Properties

```yaml
views:
  - type: list
    name: "Quick List"
    markers: none
    indentProperties: false
    separator: " | "
    # Properties appear inline: "Note | status | date"
```

## Cards View

Display files in a gallery grid with optional cover images. Best for visual content.

```yaml
views:
  - type: cards
    name: "Gallery"
    cardSize: medium      # small, medium, large
    imageProperty: cover  # Property containing image
    imageFit: cover       # cover, contain
    imageRatio: 1:1       # Aspect ratio
```

### Options

| Option | Values | Description |
|--------|--------|-------------|
| `cardSize` | `small`, `medium`, `large` | Card width in grid |
| `imageProperty` | property name | Property with image path/URL |
| `imageFit` | `cover`, `contain` | How image fills space |
| `imageRatio` | ratio string | Image aspect ratio |

### Image Property Values

The image property can contain:
- Internal links: `"[[attachments/photo.jpg]]"`
- External URLs: `"https://example.com/image.png"`
- Hex colors: `"#3498db"` (solid color card)

### Image Fit

| Fit | Behavior |
|-----|----------|
| `cover` | Fill card, crop excess |
| `contain` | Fit within card, may have gaps |

### Image Ratio

Common ratios:
- `1:1` - Square (default)
- `16:9` - Widescreen
- `4:3` - Standard
- `3:2` - Photo
- `2:1` - Banner

### Grouping Cards

```yaml
views:
  - type: cards
    name: "By Category"
    groupBy: category
    cardSize: small
    imageProperty: thumbnail
```

## Map View

Display files as pins on an interactive map. Requires the Maps plugin.

```yaml
views:
  - type: map
    name: "Locations"
    coordinates: location    # Property with lat,lng
    icon: landmark           # Lucide icon name
    color: "#e74c3c"         # Pin color
```

### Requirements

1. Install Maps plugin from community plugins
2. Obsidian 1.10 or later
3. Notes with coordinate properties

### Coordinate Property Format

```yaml
# In note frontmatter
location: "51.5074, -0.1278"
# or as list
location:
  - 51.5074
  - -0.1278
```

### Options

| Option | Values | Description |
|--------|--------|-------------|
| `coordinates` | property name | Property with lat,lng |
| `icon` | Lucide icon name | Pin icon |
| `color` | CSS color | Pin color |
| `height` | pixels | Embedded map height |
| `zoom` | number | Initial zoom level |
| `center` | "lat, lng" | Initial center point |

### Dynamic Icons and Colors

Use formulas for conditional styling:

```yaml
formulas:
  pin_icon: if(type == "restaurant", "utensils", if(type == "hotel", "bed", "map-pin"))
  pin_color: if(visited, "#27ae60", "#e74c3c")

views:
  - type: map
    name: "Travel Map"
    coordinates: location
    icon: formula.pin_icon
    color: formula.pin_color
```

### Map Tiles

Customize map appearance with tile providers:

**OpenFreeMap (free)**:
- Positron (light)
- Dark
- Liberty (detailed)

**Commercial options**:
- MapTiler
- Mapbox
- Protomaps

Configure in view settings through the UI.

### Troubleshooting

**Blank map**: Update Obsidian installer version

**Missing pins**: Verify coordinate format is "lat, lng" as text

## Multiple Views Example

```yaml
filters:
  and:
    - file.hasTag("project")

formulas:
  days_active: (today() - date).days

views:
  - type: table
    name: "All Projects"
    sort:
      - property: date
        direction: DESC
    summaries:
      status:
        type: count

  - type: cards
    name: "Visual Grid"
    cardSize: medium
    imageProperty: cover
    groupBy:
      property: status
      direction: ASC

  - type: list
    name: "Quick List"
    markers: bullet
    indentProperties: false
    separator: " - "

  - type: map
    name: "Locations"
    coordinates: office_location
    icon: building
    color: "#3498db"
```

## Embedding Views

Reference specific views when embedding:

```markdown
<!-- Embed default view -->
![[projects.base]]

<!-- Embed specific view -->
![[projects.base#Visual Grid]]
```
