# Gameplay object catalog

Object names below are working references. Confirm them in the installed `ebps > gameplay` tree before placement.

## Player setup

- `starting_position_shared_territory`: creates/owns a multiplayer starting territory and base context for one player.
- `map_entry_point`: unit arrival/entry point; keep it in the matching player's starting territory and behind the base.
- `starting_territory_team`: team-territory anchor used by generated multiplayer starts.

When `Generate Starting Positions` succeeds, inspect and move the complete generated package instead of rebuilding it object by object.

## Sector creators

- `territory_point_mp`: standard strategic/resource territory point.
- `territory_fuel_point_mp`: fuel territory point.
- `territory_munitions_point_mp`: munition territory point; this plural spelling is verified in the installed COH2 editor/archive and current scenario.
- `victory_point`: victory objective used by VP win conditions.

## Placement invariants

- Every resource sector must connect through owned territory back to the HQ to provide income.
- Starting objects must use the correct player/team assignments.
- Capture zones must be reachable and should provide defensible space without forcing units to stand in a single exposed pixel.
- Do not place sector points outside the playable/interactivity boundary.
- Do not call the map playable until runtime confirms the objects behave as intended.
