# GrawrAddons — Claude Context

WoW retail (The War Within) addon collection. Each addon lives in its own subdirectory and replaces one or more WeakAuras with a native addon.

## Addon structure

```
AddonName/
├── AddonName.toc      # manifest (required)
├── AddonName.lua      # entry point
└── modules/           # optional sub-modules
```

## TOC file

```
## Interface: 120001
## Title: AddonName
## Notes: Short description
## Version: 1.0.0
## Author: Grawr
## DefaultState: Enabled

AddonName.lua
```

- List files at the bottom with no leading `#`; they load in order

## Lua conventions

- **Namespace pattern** — first line of every file:
  ```lua
  local AddonName, ns = ...
  ```
  Drop `ns` if the file doesn't reference it: `local AddonName = ...`
- **Event handling** — use a frame, not OnUpdate polling:
  ```lua
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(self, event, ...)
      if event == "ADDON_LOADED" and ... == AddonName then
          -- init
      end
  end)
  ```
- **PascalCase functions** — use `PascalCase` for all function names to match the WoW API style
- **No globals** — store all state in `ns`
- **Unused params** — use bare `_` for unused leading callback params (e.g. `function(_, event, ...)`); omit trailing unused params entirely. Don't use `_name` style.
- **Delayed execution** — use `C_Timer.After(delay, fn)`, not OnUpdate
- **Hooking Blizzard functions** — use `hooksecurefunc`

## WeakAura replacement patterns

| Replacement target | API to use |
|--------------------|------------|
| Aura / buff / debuff tracking | `C_UnitAuras.GetAuraDataByIndex`, `UnitAura` |
| Cooldown tracking | `C_Spell.GetSpellCooldown`, `GetSpellCooldown` |
| Combat log events | `COMBAT_LOG_EVENT_UNFILTERED` + `CombatLogGetCurrentEventInfo()` |
| Custom HUD frames | `CreateFrame("Frame", nil, UIParent)` |

## Testing

- `/reload` — reload UI after changing files
- `/run <lua>` — quick API tests in-game

## Git workflow

- Do all development on a feature branch, not `main`
- Branch name should reflect the addon or feature being worked on (e.g. `addon/my-addon-name`)
- Open a PR to `main` when work is ready — do not merge it yourself

## Dependencies

Avoid external libraries (LibStub, Ace3, etc.) unless genuinely necessary. Simple addons should be self-contained.
