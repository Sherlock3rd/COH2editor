---
name: coh2-world-builder
description: Research, plan, build, and validate playable Company of Heroes 2 multiplayer maps in World Builder. Use for COH2 map layout, scenario objects, territory and resource setup, editor operation, packaging, or in-game acceptance. Do not treat a saved blank terrain or editor-only inspection as a playable map.
---

# COH2 World Builder

Produce a loadable, playable multiplayer scenario—not merely an `.sgb` file.

## Source order

1. Use the Relic/Essence Engine Wiki and the local game/module files as factual sources.
2. Use maintained project specs under `../../spec/coh2-world-builder/` for the current delivery standard.
3. Use community guides and public GitHub repositories only as secondary implementation evidence; label unverified details and check them against the installed editor.

Read [references/source-index.md](references/source-index.md) when researching or updating knowledge.

## Route the task

- For every World Builder implementation or repair, read [references/end-to-end-operations.md](references/end-to-end-operations.md) first; it defines the complete G0-G7 workflow, UI batching, recovery, and efficiency rules.
- For a new or repaired 1v1 map, read [references/fast-build-workflow.md](references/fast-build-workflow.md) and `../../spec/coh2-world-builder/playable-1v1-map-spec.md`.
- For UI operation or shortcuts, read [references/world-builder-controls.md](references/world-builder-controls.md).
- For the verified local toolbar map, Ardennes asset paths, and `2p_codex_crossroads` batch-placement coordinates, read [references/world-builder-efficiency-atlas.md](references/world-builder-efficiency-atlas.md).
- For required gameplay entities, read [references/gameplay-object-catalog.md](references/gameplay-object-catalog.md).
- Before claiming completion, read `../../spec/coh2-world-builder/acceptance-spec.md`.

## Non-negotiable outcomes

- Preserve existing maps; create a new scenario folder and basename unless the user explicitly selects an existing map to edit.
- A multiplayer map is not playable until both players have valid starts/base territories and entry points, territory sectors form supply-connected routes, resource and victory points work, the playable boundary and pathing are valid, and an in-game match loads successfully.
- Build gameplay structure before visual dressing. Do not spend time on detailed art before the map passes a graybox playtest.
- Keep evidence separate: editor screenshots prove editor state; a custom match against AI proves runtime playability.
- When Windows automation is interrupted or the user presses Escape, stop input immediately and report the exact unfinished stage.

## Working sequence

1. Confirm the installed game path and target scenario name.
2. Draft a compact lane/sector/resource layout and record assumptions.
3. Create the scenario in a dedicated folder under the module's allowed `Data\Scenarios` path.
4. Build the graybox using the fast workflow.
5. Save, generate required scenario artifacts, and resolve World Builder errors.
6. Launch a real 1v1 custom match with one AI and run the acceptance checks.
7. Only after graybox acceptance, add terrain, roads, cover, buildings, splines, lighting, and map-edge dressing.
8. Re-run runtime acceptance after material changes.

Report progress using the G0-G7 stages defined in the operations manual. Include the last saved stage, unsaved work, and the evidence type. “Opens”, “saved”, “correct dimensions”, and “generated starts” are intermediate facts, never completion claims.

## Execution priority

1. Advance the next graybox gate.
2. Resolve blockers that prevent that gate.
3. Generate and verify scenario artifacts.
4. Improve automation or documentation only when it directly removes the active blocker.
5. Add visual polish only after runtime graybox acceptance.

Batch repeated placements by object type. Re-observe after modal, mode, camera, or window changes; do not screenshot every identical placement. After two failures with the same UI method, switch to accessibility navigation, keyboard navigation, filtering, or another verified control path.

Prefer installed-archive evidence for exact asset names. `Archive.exe -a <AttribArchive.sga> -l` can enumerate EBP paths without extracting the archive; record the verified path once and reuse it instead of rediscovering the object tree during editing.

Treat packaging as a single-writer operation. Before export or `Archive.exe -c`, close every `RelicCoH2.exe` and duplicate World Builder process, then verify that exactly one target `.sga` remains live in `Documents\My Games\Company of Heroes 2\mods\scenarios`. Test the built archive with `Archive.exe -t` and list it with `-l`; the listed `.sgb`, `.info`, and `_mm.tga` sizes must match the intended source bundle.

Do not rename a scenario by editing only the generated `.info`. The front-end name, World Builder Scenario Properties identity, basename, archive TOC path, and packaged sidecars must remain a coherent set. If a new display identity is required, change it in World Builder and regenerate the sidecars; a hand-edited `.info` can be syntactically valid yet be skipped by the scenario indexer.

For this project's 320 × 320 playable 1v1 maps, the front-end minimap artifact is a 768 × 768, 32-bit, uncompressed BGRA TGA with opaque alpha. Verify the 18-byte header and exact byte size `2,359,314` before packaging. A PNG renamed to TGA, a 384 × 384 export, or a minimap with transparent alpha is not acceptable evidence.

Do not treat territory coloring, roads, or scenery as proof that terrain dressing is complete. Before visual acceptance, inspect the Texture Tile layers and require at least three materially distinct, visible surface languages appropriate to the map—for this project: base soil, grass/agricultural ground, and urban/road hardscape. Generate a fresh overhead map with fog disabled and reject it if the playable area still reads as one color. When clearing legacy alpha with an Exclusive base-layer pass, immediately rebuild the non-base layers before adding more scenery.

For an existing scenario that already contains a verified official entity of the desired type, `scripts/clone-sgb-entities.ps1` may batch-clone that exact entity chunk from a reviewed JSON placement list. Before this operation, back up the source `.sgb`; afterwards, reopen and save it in World Builder, rebuild territory if gameplay creators changed, export the `.sga`, and rerun the in-game checks. This shortcut is only for official assets already present in the scenario; it must never introduce placeholder cubes or guessed blueprint names.

When sculpting base terrain, use overlapping maximum-size `Set Value` stamps to create a broad spawn platform and exit apron, then smooth only the seams. The installed editor's effective maximum brush is about 64 map units, so large safe areas require tiled stamps rather than one assumed giant brush. Preserve tactical hills outside the platform, and inspect both spawn sides from the runtime camera because the editor's overhead view can hide bowls and occluding ridges.

## Stopping conditions

- Stop rather than overwrite when the target scenario already exists and overwrite was not explicitly authorized.
- Stop and report if the game cannot load the map, a player lacks a base/start, sectors are disconnected, victory points do not tick, AI cannot leave base, or critical routes fail vehicle pathing.
- Never describe a blank terrain, generated start skeleton, or editor-only save as complete or playable.
