# openthedoor — about

## Concept

A game with a physical toy home mirrored in a small digital world.
When characters arrive or leave in the toy home through the chimney, their character appears or disappears in the game.
The door opening causes trash to float into the in-game home.

## Hardware

An Arduino monitors three physical switches via pins 2, 3, and 4:

- Pin 2 — Shiny's sensor (detects when Shiny is home)
- Pin 3 — Fluffy's sensor (detects when Fluffy is home)
- Pin 4 — Door sensor (detects when the front door is open)

The switches use INPUT_PULLUP, so LOW = on (circuit closed).
The Arduino sends JSON over serial: `{"name":"shiny","on":true}`.
A bridge script forwards serial to UDP on port 4242.
The Arduino also heartbeats state every 500ms so Godot stays in sync if restarted.

## Architecture

```
Arduino (physical world)
    → serial
    → bridge script
    → UDP :4242
    → GameInput (autoload singleton)
    → signals → main.gd → spawn/despawn blobs
```

**GameInput** (`game_input.gd`) is a singleton that:
- Reads UDP packets and parses JSON
- Maintains state: `door_open`, `shiny_in_the_house`, `fluffy_in_the_house`
- Emits signals: `shiny_entered`, `shiny_left`, `fluffy_entered`, `fluffy_left`, `debug_toggled`
- Handles keyboard fallback for testing without hardware

**main.gd** connects to those signals and spawns/despawns blobs accordingly.
It never polls state — it only reacts to events.

## Characters

**Shiny** — blob character 1, linked to pin 2 / `spawn_shiny` key (2)
**Fluffy** — blob character 2, linked to pin 3 / `spawn_fluffy` key (3)

Blobs are instantiated from `shiny.tscn` and `fluffy.tscn`.
They spawn at a fixed SpawnPoint in the scene.
When despawned they play a vanish animation before being freed.
Double-spawn and double-despawn are guarded against.

## Trash

Trash spawns from the bottom of the scene when the door is open (every 1 second) and fly into the home.

## Scene structure (Main.tscn)

- World (Node2D) — main.gd
  - CanvasLayer (layer -1, behind game world)
    - ColorRect (black background)
    - DebugLabel (hidden by default, F1 to toggle)
  - TrashSpawner — trash_spawner.gd
  - Tiles
    - floor (TileMapLayer)
    - walls (TileMapLayer)
    - misc (TileMapLayer)
  - SpawnPoint (Marker2D)

## Debug

Press **F1** to toggle the debug overlay, which shows:
- Door status (open/closed)
- Who is home ("nobody is home" / "shiny is home" / etc.)

## Keyboard controls (for testing without hardware)

| Key | Action |
|-----|--------|
| 2   | Toggle shiny |
| 3   | Toggle fluffy |
| Space (hold) | Door closed; release = door open |
| F1  | Toggle debug overlay |
| Escape | Quit |

## Key files

| File | Purpose |
|------|---------|
| `game_input.gd` | Hardware + keyboard input, signals |
| `main.gd` | Blob lifecycle, debug label |
| `trash_spawner.gd` | Spawns trash when door open |
| `trash.gd` | Trash color, motion, rotation |
| `shiny.tscn` / `fluffy.tscn` | Blob scenes |
| `trash.tscn` | Trash scene |
| `arduino/openthedoor.ino` | Arduino firmware |