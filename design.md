# 🐒💥 BABOOM

**Theme:** Reinvent the Wheel · **Engine:** Godot · **Format:** 2D physics game (Mario-style look)

## The pitch
Monke sits at the peak of a mountain jungle and spots a banana *way* down at the
bottom. His ride: a **banana cart** with two wheels — except **the player draws the
wheels.** Every level throws a new obstacle at you, and you **redraw the wheels** to
get past it. Round wheel here, spiky wheel there, giant wheel to clear a boulder.
Redraw → roll → *baboom* → reach the banana.

**The hook:** "Reinvent the Wheel" isn't a metaphor — the player literally redraws
the wheel every single level.

## Core mechanic: draw-a-wheel
- Player draws a shape → it becomes a physics wheel on the banana cart.
- The **shape has consequences**, so each obstacle demands a different wheel:

| Obstacle | Wheel you need |
|----------|----------------|
| 🪨 Boulder / tall step | BIG wheel to clear it (but unwieldy) |
| 🕳️ Wide gap | Huge round wheel to roll across |
| ⛰️ Muddy slope | Spiky / toothed wheel for grip |
| 🌉 Narrow ledge | Small wheel to fit |
| ⚡ Speed section | Round & smooth = fast |

- You **redraw for every level** — that's the reinvention loop.

### De-risking the drawing (BUILD THIS FIRST)
Freehand → a wheel that actually rolls is the hard part. Constrain it:
- **Radial draw:** sample the drawn distance-from-center at each angle → always a
  closed loop around the axle → **always spins.** Player still shapes it (bumpy,
  spiky, huge) but can't make a broken tangle.
- **Fallback:** snap the drawing to a clean polygon, or pick from drawn presets.
- ⚠️ Prototype draw→roll on Day 1 before ANY levels are built.

### Optional depth (only if time allows)
- **Ink budget** — limited ink per wheel, so no free giant perfect circles.
- **Front & back wheels differ** — big back + small front = tilt / climb / wheelie.

## Flavor & juice
- **Opening:** camera starts on the banana far below, pans up the mountain to Monke.
- **Baboom moments:** cart flips → Monke gets flung in a spinning cartwheel. Fast
  redraw-and-retry loop.
- Wheel wobble, screen shake, monkey screams, triumphant banana grab at the bottom.
- Reuse last year's monkey sprites as stand-ins/finals.

## Godot 2D toolkit
| Element | Node |
|---------|------|
| Monke / cart body | `RigidBody2D` |
| Drawn wheels | `RigidBody2D` + generated `CollisionPolygon2D`, pinned with `PinJoint2D` |
| Level ground / terrain | `TileMap` or `StaticBody2D` |
| Goal (banana), triggers | `Area2D` |
| Drawing input | `_input()` capturing points → build the wheel polygon |

## Scope & build order (48h)
- **MVP (Day 1):** draw-a-wheel + banana cart + ONE test level, playable start to
  banana. That alone is a shippable game.
- **Day 2:** more levels + juice + intro pan + ending. Cut any level that isn't
  landing — level-based structure means dropping one breaks nothing.
- ⚠️ **The draw+cart backbone must be pushed to `main` BEFORE anyone builds levels**,
  or their obstacles won't match how the real wheels behave.

## Ownership (1 level = 1 scene = 1 branch → zero merge conflicts)
| Person | Owns |
|--------|------|
| **Joanna** | Backbone: draw-a-wheel system + banana cart (rider, joints, camera) |
| **Isak**   | Level 1 (gentle intro — one round wheel gets you down) |
| **Keaton** | Level 2 (boulder — needs a big wheel) |
| **Tammy**  | Level 3 (muddy slope — needs a spiky wheel) |
| **Wesley** | Final level + audio/juice + intro pan |
