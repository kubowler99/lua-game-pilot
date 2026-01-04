# Technical Design Document
## Project: Pixel Runner (Endless Runner in Solar2D)

---

## 1. High-level overview

**Game Type:** 2D side-scrolling endless runner  
**Engine:** Solar2D (Lua)  
**Target Platforms:** iOS, Android  
**Perspective:** Side view, single-lane runner  
**Art Style:** Silhouette foreground with gradient/parallax backgrounds

**Core Pillars:**
- Simple, responsive controls (tap to jump, optional double jump)
- Increasing difficulty over time (speed + spawn rate)
- Short, replayable runs with clear feedback and juicy feel
- Lightweight, reusable architecture for future games

---

## 2. Core gameplay

### 2.1 Core loop
1. Player auto-runs to the right.
2. Obstacles spawn ahead based on patterns.
3. Player taps to jump (and optionally double-jump).
4. Colliding with an obstacle ends the run.
5. Score increases over time and with distance.
6. Player returns to main menu, can restart instantly.

### 2.2 Controls
- **Tap anywhere:** Jump
- **Optional:** Double-tap within a time window to double-jump

### 2.3 Win/lose conditions
- **Win:** Not applicable (endless). Player “wins” by beating their high score.
- **Lose:** Player collides with obstacle → game over state.

### 2.4 Difficulty progression
- Base speed increases over time.
- Obstacle spawn interval decreases over time.
- Optional: Introduce new obstacle patterns at score thresholds.

---

## 3. Game systems

### 3.1 Player system

**Responsibilities:**
- Handle input (jump/double-jump).
- Integrate with physics for movement and collisions.
- Trigger animations (if any) and effects.

**Key Data:**
- `state` (idle, running, jumping, falling, dead)
- `canDoubleJump` (bool)
- `jumpForce` (number)
- `gravityScale` (number)
- `runSpeed` (number, used for background/obstacle movement)

**Behaviors:**
- On tap:
  - If `state == running` → apply jump impulse, set `state = jumping`, `canDoubleJump = true`.
  - If `state == jumping` and `canDoubleJump` → apply second jump impulse, `canDoubleJump = false`.
- On landing:
  - `state = running`, `canDoubleJump = false`.

---

### 3.2 Obstacle system

**Responsibilities:**
- Spawn obstacles at runtime.
- Move obstacles leftward relative to player.
- Recycle obstacles (object pooling) to avoid GC spikes.

**Key Data:**
- `spawnInterval` (seconds, dynamic)
- `patterns` (list of pattern definitions from JSON)
- `pool` (table of inactive obstacle objects)

**Pattern Example (JSON):**
```json
{
  "patterns": [
    { "id": "single_low", "sequence": [ { "type": "low", "offset": 0 } ] },
    { "id": "triple_low", "sequence": [ { "type": "low", "offset": 0 }, { "type": "low", "offset": 150 }, { "type": "low", "offset": 300 } ] }
  ]
}
```

**Behaviors:**
- Timer or frame-based spawn:
  - Choose a pattern based on difficulty.
  - For each element in pattern, spawn or reuse obstacle from pool.
- When obstacle moves off-screen (left):
  - Deactivate and return to pool.

---

### 3.3 Background & parallax system

**Responsibilities:**
- Create illusion of forward motion.
- Provide visual depth with multiple layers.

**Layers:**
- `layer0`: Far background (slowest)
- `layer1`: Mid background
- `layer2`: Foreground decorations (fastest, behind player)

**Behaviors:**
- Each layer scrolls left at a fraction of `runSpeed`.
- When a sprite moves off-screen, reposition to the right to loop.

---

### 3.4 Scoring & progression system

**Responsibilities:**
- Track current score.
- Track high score (persistent).
- Adjust difficulty over time.

**Key Data:**
- `score` (number)
- `highScore` (number)
- `elapsedTime` (seconds)
- `difficultyLevel` (number)

**Scoring:**
- `score += deltaTime * scoreRate`
- Optional: bonus for pickups.

**Difficulty Curve:**
- Every X seconds or score threshold:
  - `runSpeed += speedIncrement`
  - `spawnInterval = max(minSpawnInterval, spawnInterval - spawnDecrement)`

---

### 3.5 Game state & scene flow

**States:**
- `menu`
- `playing`
- `paused`
- `gameOver`

**Scene Flow (using composer):**
- `menuScene` → `gameScene` → `gameOverOverlay` (or back to `menuScene`)

**Transitions:**
- From `menuScene`:
  - Tap “Play” → go to `gameScene`.
- From `gameScene`:
  - Player dies → show game over UI (overlay or in-scene).
- From `gameOver`:
  - Tap “Retry” → restart `gameScene`.
  - Tap “Menu” → go to `menuScene`.

---

### 3.6 Audio system

**Responsibilities:**
- Background music.
- Jump sound.
- Death sound.
- UI click sounds.

**Implementation:**
- Use `audio.loadSound` for SFX.
- Use `audio.loadStream` for BGM.
- Centralized `audioManager.lua` to play/stop channels.

---

### 3.7 Persistence system

**Responsibilities:**
- Save/load high score.
- Save basic settings (sound on/off).

**Implementation:**
- Use a small `storage.lua` module wrapping `system.DocumentsDirectory` and JSON encode/decode.

**Data Example:**
```json
{
  "highScore": 1234,
  "settings": {
    "sound": true,
    "music": true
  }
}
```

---

## 4. Architecture & modules

### 4.1 File structure

```text
/
├── main.lua              -- Entry point, bootstrap sequence
├── config.lua            -- App configuration (resolution, FPS)
├── build.settings        -- Platform-specific settings (orientation, plugins)
├── Assets/
│   ├── game.lua          -- Central game controller (lifecycle, scene management)
│   ├── Entities/         -- Base entity class and game objects
│   ├── Scenes/           -- Composer scene implementations
│   ├── Story/            -- Game flow, chapters, and object pool definitions
│   ├── Audio/            -- Audio loaders and assets
│   └── Environments/     -- Game world/background implementations
├── Libs/                 -- Core utility libraries (MiddleClass, Utils, State, etc.)
├── Plugins/              -- Reusable system plugins (loadSave, time, soundPlayer)
├── Debug/                -- Debug configurations and runtime features
└── data/                 -- (Optional) JSON definitions for patterns/difficulty
```

### 4.2 Module responsibilities

**`main.lua`**
- Initialize bootstrap sequence.
- Initialize save/load system.
- Start game via `_G.game.start()`.

**`Assets/game.lua`**
- Centralized game controller.
- Manage lifecycle (start, save, suspend, resume).
- Handle scene transitions and loading screens.

**`Assets/Entities/entity.lua`**
- Base class for all game objects.
- Manage positioning, transforms, visuals, and lifecycle (create/update/remove).

**`Assets/Scenes/mainGame.lua`**
- Primary game scene using Composer.
- Standard lifecycle (create/show/hide/destroy).

**`Libs/`**
- **`utils.lua`**: Math and string extensions.
- **`screen.lua`**: Screen dimension and layout management.
- **`objectPoolManager.lua`**: Performance optimization via object reuse.

**`Plugins/`**
- **`loadSave.lua`**: Persistent data management (JSON-based).
- **`time.lua`**: Frame-independent timing and time scaling (slow-mo).
- **`soundPlayer.lua`**: Audio playback management.

---

## 5. Data formats

### 5.1 Obstacle patterns (`patterns.json`)

```json
{
  "patterns": [
    {
      "id": "single_low",
      "difficulty": 1,
      "sequence": [
        { "type": "low", "offset": 0 }
      ]
    },
    {
      "id": "triple_low",
      "difficulty": 2,
      "sequence": [
        { "type": "low", "offset": 0 },
        { "type": "low", "offset": 150 },
        { "type": "low", "offset": 300 }
      ]
    }
  ]
}
```

### 5.2 Difficulty curve (`difficulty.json`)

```json
{
  "levels": [
    { "time": 0,   "runSpeed": 200, "spawnInterval": 1.5 },
    { "time": 30,  "runSpeed": 230, "spawnInterval": 1.3 },
    { "time": 60,  "runSpeed": 260, "spawnInterval": 1.1 },
    { "time": 90,  "runSpeed": 290, "spawnInterval": 1.0 }
  ]
}
```

---

## 6. Physics & performance

### 6.1 Physics

- Use **Box2D** via Solar2D physics.
- Gravity set globally in `gameScene` to `(0, 200)` for a snappy, high-speed feel.
- Player: dynamic body, fixed rotation, jump impulse `-2.0`.
- Obstacles: kinematic bodies, `isSensor = true`.
- Ground: static body.

### 6.2 Performance considerations

- Object pooling for obstacles and background elements.
- Avoid creating/destroying display objects every spawn.
- Use `enterFrame` listeners sparingly; centralize updates in `gameScene`.

---

## 7. UI & UX

### 7.1 HUD

- Score text (top-left or top-center).
- Pause button (top-right).
- Optional: High score indicator.

### 7.2 Menus

**Main Menu:**
- Game title.
- Play button.
- Settings button.
- High score display.

**Game Over UI:**
- Final score.
- High score (with “New!” badge if beaten).
- Buttons: Retry, Menu.

---

## 8. AI-assisted workflows

### 8.1 Asset generation

- Use AI to generate:
  - Background gradients.
  - Silhouette obstacles.
  - Player character silhouettes.
  - UI icons.

### 8.2 Pattern & difficulty generation

- Provide AI with pattern schema and ask it to generate:
  - 50–100 obstacle patterns with difficulty tags.
- Provide difficulty schema and ask AI to generate:
  - Smooth curves for speed and spawn intervals.

---

## 9. Milestones

### Milestone 1: Core Prototype (Week 1)
- Player runs and jumps.
- Obstacles spawn and collide.
- Game over triggers.

### Milestone 2: Playable Loop (Week 2)
- Parallax background.
- Score and difficulty progression.
- Basic HUD and game over UI.

### Milestone 3: Content & Polish (Week 3)
- AI-generated art integrated.
- Sound effects and music.
- High score persistence.

### Milestone 4: Release Candidate (Week 4)
- Bug fixes.
- Performance tuning.
- Store builds and metadata ready.

---
