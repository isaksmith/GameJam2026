# 🐒💥 BABOOM

**BABOOM** is a 2D physics game built for the 2026 Game Jam around the theme
**“Reinvent the Wheel.”**

Monke has spotted a banana at the bottom of a mountain, but the banana cart is
missing something important: wheels. Draw your own wheel shape, attach it to the
cart, and discover which designs can overcome each level's terrain.

## Gameplay

- Draw custom wheels directly in the game.
- Use each wheel's physical shape to navigate slopes, gaps, ledges, and obstacles.
- Redraw and retry when a design does not work.
- Reach the banana to advance through the game's four levels and finale.

Large wheels can clear tall obstacles, smooth wheels roll quickly, and irregular
or spiky wheels can provide useful grip. There is no single best design—each
level asks you to reinvent the wheel.

## Controls

| Input | Action |
| --- | --- |
| Left mouse button | Draw a wheel and use menu buttons |
| Left / Right arrow keys | Drive and rotate the cart |
| Escape | Pause or resume |
| Retry button | Restart the current level |

Use the **Draw** button to open the drawing panel, **Clear** to erase the current
drawing, and **Done** to apply the new wheels to the cart.

## Running the game

### Requirements

- [Godot Engine 4.7.1](https://godotengine.org/)

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/isaksmith/GameJam2026.git
   cd GameJam2026
   ```

2. Import `project.godot` in Godot.
3. Open the project and press **F5** or click **Run Project**.

## Project structure

```text
assets/          Art, sprites, fonts, and audio
scenes/          Levels, the cart, menus, and UI scenes
scripts/         Gameplay, physics, UI, and game-flow scripts
project.godot    Godot project configuration
design.md        Original game concept and scope
team_workflow.md Team conventions and Git workflow
```

The global `Game` autoload manages level progression, cart spawning, retries,
goals, and transitions between the menu and gameplay. Drawn wheel textures are
converted into collision polygons so their silhouettes affect the cart's
physics.

## Team

Created by Team Monke for the 2026 Game Jam:

- Wesley, Keaton, and Joanna — development
- Tammy — art

Isak created a separate expanded minigame version:
[Banana Genesis Game Jam 2026](https://github.com/isaksmith/BananaGenesisGameJam2026).

## Play online

- [BABOOM! — original game jam submission](https://itch.io/jam/ict-game-jam-summer-2026/rate/4830541)
- [BaBoom: Banana Genesis — expanded minigame](https://isaksmith.itch.io/baboom-banana-genesis)

See [`design.md`](design.md) for the original pitch and
[`team_workflow.md`](team_workflow.md) for contribution conventions.
