Deploy all addons in this repository to the WoW Addons directory.

The target directory is read from the environment variable `WOW_ADDONS_DIR`. If the variable is not set, detect the current OS and stop with platform-appropriate instructions:

**Windows** — run this in a terminal, then open a new terminal and re-run the command:
```
setx WOW_ADDONS_DIR "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
```

**macOS** — add this to `~/.zshrc` (or `~/.bash_profile`), then open a new terminal and re-run the command:
```
export WOW_ADDONS_DIR="/Applications/World of Warcraft/_retail_/Interface/AddOns"
```

Steps:
1. Read `WOW_ADDONS_DIR` from the environment. If it is empty or unset, stop with the message above.
2. Find all addon directories in the repo root — these are subdirectories that contain a `.toc` file matching the directory name (e.g. `AddonName/AddonName.toc`).
3. For each addon directory found, ensure the target directory exists with `mkdir -p`, then copy the contents using `cp -r AddonName/* WOW_ADDONS_DIR/AddonName/` to overwrite existing files without nesting.
4. After all copies complete, print a summary listing each addon that was deployed and the destination path.
