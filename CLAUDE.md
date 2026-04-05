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
- **No globals** — store all state in `ns`
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

## Dependencies

Avoid external libraries (LibStub, Ace3, etc.) unless genuinely necessary. Simple addons should be self-contained.
