# Fast playable-map workflow

This sequence optimizes for a playable graybox before art polish.

## 1. Create safely

- Create a unique scenario folder beneath the active module's `Data\Scenarios` path.
- Keep folder name and `.sgb` basename identical, ASCII, short, and prefixed `2p_` for a two-player map.
- Project default starting size: terrain `384 x 384`, playable area `320 x 320`, cell size `1 m`, two generated starting positions. Adjust only with a recorded layout reason.
- Keep the playable area under `512 x 512`, as advised by the official dressing tutorial.

## 2. Place the start packages

- Move the two generated base packages to opposite sides.
- Keep the base circle, `map_entry_point`, and starting-team/shared-territory objects together and inside the correct starting territory.
- Leave build space around each base and a safe unit-exit route.
- Use the playable-area overlay and 32 m grid while aligning starts.

## 3. Place gameplay points before scenery

Practical 1v1 graybox baseline:

- 3 victory points: one central and two offset side objectives.
- 2 fuel points: one contestable point biased toward each side, with attack access from at least two directions.
- 2 munition points: mirrored travel time and comparable cover exposure.
- 8–10 standard territory points, including meaningful cutoff sectors.

Treat these counts as a starting layout, not an invariant. Symmetry means comparable timing and opportunity, not necessarily mirrored art.

## 4. Build sectors and routes

- Draw supply-connected territories from each HQ to its natural resources.
- Ensure at least three infantry routes between bases: center, left flank, right flank.
- Give important VPs and fuel points more than one approach; avoid single-door strongholds.
- Keep cutoff points contestable without letting one early capture isolate an entire side with no counter-route.

## 5. Block out combat

- Paint/lay the main road and two secondary lanes.
- Add sparse, readable green/yellow cover; reserve red cover/open ground for intentional risk corridors.
- Place line-of-sight blockers to prevent base-to-base firing and overly dominant long lanes.
- Leave gaps in walls and object splines for infantry and vehicles.
- Paint an interactivity-stage-5 border around the soft map edge.

## 6. Test before dressing

- Save and resolve World Builder errors.
- Generate required scenario/minimap artifacts.
- Load the map in a custom 1v1 match against AI.
- Verify both factions can spawn/build, AI exits base, all sectors capture, resources connect to HQ supply, VP drain works, and vehicles traverse all intended lanes.

Only then add detailed terrain, vegetation, buildings, lighting, splats, and ambient objects.
