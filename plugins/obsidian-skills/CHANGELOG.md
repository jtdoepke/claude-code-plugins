# Changelog

All notable changes to the obsidian-skills plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-05

### Added

- Initial release as part of jtdoepke/claude-code-plugins marketplace
- **obsidian-bases** skill: Create and configure Obsidian Bases (database-like views)
  - Standalone `.base` files (YAML format)
  - Embedded base code blocks in markdown
  - Filter system with AND, OR, NOT operators
  - Formula expressions for computed properties
  - Multiple view types: table, list, cards, map
  - Reference documentation for syntax, functions, and views
- **obsidian-plan** skill: Create project implementation plans
  - Deep critical thinking workflow
  - Inevitable code philosophy integration
  - Structured frontmatter with status tracking
  - Topic management via `topic/` tag prefix
- **obsidian-research** skill: Create structured research notes
  - Multi-phase research workflow
  - Critical analysis framework
  - Parallel exploration support
  - Comprehensive vs simple research modes
- Shell script tests using bats framework
- Topic listing helper scripts for both plan and research skills

### Changed

- Migrated from mintel-claude-code-plugins to personal marketplace
- Updated author information with GitHub URL
- Added repository field to plugin manifest

[0.1.0]: https://github.com/jtdoepke/claude-code-plugins/releases/tag/obsidian-skills-v0.1.0
