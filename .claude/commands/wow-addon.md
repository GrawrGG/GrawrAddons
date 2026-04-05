Scaffold a new WoW addon in this repository.

Arguments: `$ARGUMENTS` — expected format: `AddonName Short description of what it does`

Steps:
1. Parse `$ARGUMENTS`: the first word is the addon name, the remainder is the description.
2. Create a feature branch named `addon/addon-name` (kebab-case of the addon name).
3. Create the directory `AddonName/` in the repo root.
4. Create `AddonName/AddonName.toc` using the template from CLAUDE.md, substituting the addon name and description.
5. Create `AddonName/AddonName.lua` with this boilerplate:
   ```lua
   local AddonName, ns = ...

   local frame = CreateFrame("Frame")
   frame:RegisterEvent("ADDON_LOADED")
   frame:SetScript("OnEvent", function(self, event, ...)
       if event == "ADDON_LOADED" and ... == "AddonName" then
           -- init
       end
   end)
   ```
6. Add a row for the new addon to the table in README.md (Name, short description, Status: "In development").
7. Commit the scaffold with message `Add AddonName scaffold`.
