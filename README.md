# GrawrAddons

Personal World of Warcraft addon collection for retail (The War Within), written to replace WeakAuras with lightweight, purpose-built addons.

## Addons

| Name | Purpose | Status |
|------|---------|--------|
| CombatTimer | A simple combat timer addon that shows time-in-combat | Ready for use |
| ServerName | Shows the name of the server the current player character is on | Ready for use |
| SoulstoneWhisperer | Whisper warlocks to apply a soulstone in raid | Ready for use |
| SoundControl | Minimap button to cycle master volume and sound output device | Ready for use |
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

### VS Code setup

Install the [ketho.wow-api](https://marketplace.visualstudio.com/items?itemName=ketho.wow-api) extension for Lua IntelliSense against the WoW API. The `.vscode/settings.json` in this repo configures the Lua LSP to use it automatically.

### Resources

- [WoW API reference](https://warcraft.wiki.gg/wiki/World_of_Warcraft_API)
- [TOC format](https://wowpedia.fandom.com/wiki/TOC_format)
- [12.0.0 API Changes](https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes)
- [12.0.1 API Changes](https://warcraft.wiki.gg/wiki/Patch_12.0.1/API_changes)
- [Midnight Secret Values discussion](https://warcraft.wiki.gg/wiki/Secret_Values)

## License

MIT — see [LICENSE](LICENSE)
