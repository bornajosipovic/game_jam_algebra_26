# Ashbound God

Arcade action roguelite built in **48 hours** for the **Algebra-Bernays Game Jam 2026** by a
four-person student team — in **Godot 4**, an engine none of us had used before the jam.

## The game

Collect **25 Ascensions** (yellow suns) scattered across the map — but picking one up isn't
enough: you have to carry it back to the **Eternal Fire** before you die, and banking your
Ascensions at the Fire **kills you on the spot**. Death is the price of progress.

Your HP is a **continuously draining timer**. Enemy hits knock time off it; time pickups on
the map add some back. You start with **3 lives** (extra ones can be found as items), and every
death — voluntary or not — costs one.

Each death **reincarnates you as one of four random classes**:

| Class | Orientation |
|---|---|
| Knight | combat |
| Priest | combat |
| Child | movement |
| Rat | movement |

Every class has its own speed, armor, attack power, primary attack (melee or ranged), a
passive, and a special ability on cooldown. On each reincarnation you also pick **one of three
random buffs** that last the whole run — some are class-specific and strong, others generic
and milder. Three enemy types stand between you and the Fire.

## Controls

| Input | Action |
|---|---|
| WASD | move |
| Left click | primary attack (melee/ranged, class-dependent) |
| Space | class special ability (cooldown) |

## How to play

**Option A — just run it (Windows):** download `AshboundGod.exe` and `AshboundGod.pck`
(both files, same folder) and run the exe.

**Option B — from source:** open the project in [Godot 4.x](https://godotengine.org/)
(`project.godot`) and press F5.

## Credits

Built in 48 hours at the Algebra-Bernays Game Jam 2026 by:

- **Borna Josipović** — programming
- **Matko Krnić** — programming, 2D art, sound
- **Istok Korkut** — programming, 2D art
- **Nikola Jelaska** — 2D art, animation

Music composed by **Ivan Rajačić**. Sound effects sourced from free online libraries.
