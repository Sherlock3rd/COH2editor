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

## Stopping conditions

- Stop rather than overwrite when the target scenario already exists and overwrite was not explicitly authorized.
- Stop and report if the game cannot load the map, a player lacks a base/start, sectors are disconnected, victory points do not tick, AI cannot leave base, or critical routes fail vehicle pathing.
- Never describe a blank terrain, generated start skeleton, or editor-only save as complete or playable.
