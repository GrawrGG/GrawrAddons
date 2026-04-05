Update the WoW interface version template in CLAUDE.md.

Arguments: `$ARGUMENTS` — the new interface number (e.g. `120105`).

If `$ARGUMENTS` is not a number, stop and tell the user to run this in-game to get the current interface number, then re-invoke the command with it:
```
/run print(select(4, GetBuildInfo()))
```

Otherwise:
1. Update the `## Interface:` line in `CLAUDE.md` to the new value.
2. Commit the change with message `Update interface version to $ARGUMENTS`.
3. List all `.toc` files found in the repository and remind the user to update each one manually after testing that addon on the new patch.
