# GrawrAddons

Personal World of Warcraft addon collection for retail (The War Within), written to replace WeakAuras with lightweight, purpose-built addons.

## Addons

| Name | Purpose | Status |
|------|---------|--------|
| StanceAlert | UI for warning me when my warrior is in the wrong stance | Ready for use |

## Installation

1. Clone or download this repository
2. Copy the addon folder(s) you want into your WoW `Interface/AddOns/` directory
3. Reload your UI in-game (`/reload`) or restart WoW

Each addon is self-contained in its own subdirectory — install only the ones you want.

## Development

### Repository structure

```
GrawrAddons/
└── AddonName/
    ├── AddonName.toc      # addon manifest
    ├── AddonName.lua      # entry point
    └── modules/           # optional sub-modules
```

### Resources

- [WoW API reference](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [TOC format](https://wowpedia.fandom.com/wiki/TOC_format)
- [Widget API](https://wowpedia.fandom.com/wiki/Widget_API)

## License

MIT — see [LICENSE](LICENSE)
