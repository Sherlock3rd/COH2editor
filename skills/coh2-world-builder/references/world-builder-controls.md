# World Builder controls and fast operations

Verify status-bar hints for the active editor mode; some controls are mode-dependent.

## Global navigation and visibility

- `Ctrl+F5`: hide/show territory ownership colors.
- `Overlay > Toggle Show Playable Area`: show the playable boundary.
- Fog toolbar toggle: disable fog while blocking out.
- Use the 32 x 32 grid overlay when positioning starts and sectors.

## Objects

- Left-click and drag: move selected object.
- `Shift` + left-drag: rotate selected object in the official dressing tutorial.
- `C` then drag: copy selected building/object in the official tutorial.
- Community quick reference: hold `H` while moving to adjust height; press `R` for rotation gizmo. Verify against the current status bar before use.
- Place objects from `ebps > gameplay` with right-click after selecting the desired object.

## Splines

- Right-click several terrain points, then `Enter`: finish a spline.
- Select a spline and press `Space`: edit its control points.
- `Shift` + right-click: change spline width.
- `Shift` + left-drag: rotate a selected spline.
- Use `Fix tiling to Width` after changing a texture spline's width.
- Keep control-point counts modest and leave pathing gaps in wall splines.

## Heightmap

- With additive LMB and smoothing RMB modes, left-click raises and right-click smooths.
- Start with a large brush and low-risk edge shaping; avoid detailed elevation before gameplay routes are tested.
- Terrain editing is memory-heavy. Save, close, and reopen World Builder if performance degrades or errors begin.

## Automation discipline

- Prefer menu shortcuts, toolbar element names, and keyboard operations over pixel hunting.
- After any modal or layout change, re-observe the window before the next action.
- Do not reuse stale coordinates, screenshot IDs, or accessibility indexes.
- Save at graybox milestones and verify the title/path after each save.
