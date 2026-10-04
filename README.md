## Open and build

Open `lazarus/Bloczki.lpi` in Lazarus 4.8 configured for 32-bit Windows. The
project was compiled with Free Pascal 3.2.2. From PowerShell, it can also be
built with:

```powershell
D:\lazarus\lazbuild.exe "D:\path\to\repository\lazarus\Bloczki.lpi"
```

Replace `D:\path\to\repository` with the repository directory. The output
executable is written under `lazarus/` and is ignored by Git.

## What has changed

- Converted the Delphi project to Lazarus, including its project file,
  program entry point, and Lazarus form resources.
- Kept the original Delphi project files together in `delphi-original/`.
- Prevented horizontal movement and rotation from pushing the active piece
  beyond the playfield or into settled pieces. A new piece that overlaps the
  stack at spawn is discarded and ends the game.
- Added classic full-row clearing. Complete rows are removed together, cells
  above them shift down, and surviving disconnected parts are reconstructed
  as separate pieces. Reconstructed outlines omit redundant collinear points
  to fit the game's fixed polygon storage.
- Froze pieces after they settle so gravity does not keep dropping them.
  Clearing rows still shifts the rows above the cleared lines downward.
- Changed the score to count total completed lines removed. The on-screen
  score and game-over dialog use this same total. The four fruit images appear
  at the existing thresholds of 2, 4, 6, and 8 lines.
- Updated the “O grze” panel date to “22 Kwietnia 2003 roku - 4 Października
  2026”.
- Standardized the Lazarus Pascal units on UTF-8 and restored damaged Polish
  characters in the game unit. The original Delphi source files were left
  unchanged.
- Added a Polish game-over dialog that reports the displayed score.

## Work recorded on October 4–5, 2026

The Git history records the work in separate commits, including the Lazarus
conversion, movement and spawn collision protections, full-line clearing and
its outline/crash fix, settled-piece gravity behavior, the “O grze” panel
update, UTF-8 cleanup, and moving the original Delphi project files. These
changes were compiled with the Lazarus command-line builder during the work.
