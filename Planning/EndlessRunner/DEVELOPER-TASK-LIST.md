# 🏃‍♂️ **Pixel Runner — 4-Week Technical Implementation Plan**

This document outlines the technical tasks required to build the Endless Runner using the established project architecture. It focuses on leveraging existing `Libs/` and `Plugins/` to ensure a professional, performant implementation.

---

# ⭐ **Sprint 1 — Core Gameplay & Entity System (Week 1)**
**Goal:** Implement the player character and basic scene flow using the template's architecture.

### 📌 **Task Breakdown**

#### **Day 1–2: Scene & Story Integration**
- **Config Setup:** Define `mainMenu` and `mainGame` in `Config.Game.stories` within `Libs/config.lua`. ✓
- **Menu Scene:** Create `Assets/Scenes/menu.lua`. Use `_G.game.goTo("mainGame")` on play button tap. ✓
- **Story Implementation:** Implement `Assets/Story/mainStory.lua` (extending `chapterBasics`). ✓
- **Loading Flow:** Use `game.load()` in `mainStory:initialize()` to preload assets before transitioning to `mainGame`. ✓

#### **Day 2–3: Player Entity Development**
- **Entity Class:** Create `Assets/Entities/player.lua` extending `Assets/Entities/entity.lua`. ✓
- **Physics Integration:** Add dynamic physics body in `player:create()`. Set `fixedRotation = true`. ✓
- **Input Handling:** Implement `player:tap()` for jump logic. Use `self.group:applyLinearImpulse()` for the jump force. ✓
- **State Management:** Use `Libs/State/state.lua` to track `isGrounded` and `jumpCount` (for double jump). ✓

#### **Day 3–4: Obstacle System Foundation**
- **Obstacle Class:** Create `Assets/Entities/obstacle.lua` extending `Assets/Entities/entity.lua`. ✓
- **Object Pooling:** Define obstacle templates in `Assets/Story/ObjectPool/basic.lua`. ✓
- **Spawner Logic:** Implement a timer-based spawner in `Assets/Entities/Environments/mainGame.lua` using `_G.ObjectPool.get("obstacle")`. ✓
- **Recycling:** Implement off-screen detection in `obstacle:update()` and return to pool via `_G.ObjectPool.recycle(self)`. ✓

#### **Day 4–5: Frame-Independent Game Loop**
- **Time Subscription:** Subscribe `player` and `obstacles` to `Plugins/time.lua` for `enterFrame` updates. ✓
- **Movement:** Move obstacles leftward in `obstacle:update()` based on `Game.time.getDeltaTime()`. ✓
- **Collision Detection:** Implement `onLocalCollision` in the player entity. Trigger death state and `Game.time.pause()` on obstacle contact. ✓

---

# ⭐ **Sprint 2 — Environment, Scoring & HUD (Week 2)**
**Goal:** Create a "juicy" feel with parallax backgrounds and a functional HUD.

### 📌 **Task Breakdown**

#### **Day 1–2: Parallax Background System**
- **Background Layer:** Extend `Assets/Entities/Environments/MainGame/background.lua`. ✓
- **Layer Logic:** Create multiple `display.newGroup()` layers for Far, Mid, and Near. ✓
- **Scrolling:** Implement seamless looping logic: when a sprite's `x + width < 0`, reposition it to the right of the last sprite. ✓
- **Speed Scaling:** Tie scroll speed to `Game.state.runSpeed`. ✓

#### **Day 2–3: Scoring & Difficulty Progression**
- **State Definition:** Add `score` and `runSpeed` to the state definition in `Assets/game.lua`. ✓
- **Score Logic:** Increment `Game.state.score` in `mainGame:enterFrame` based on distance traveled. ✓
- **Difficulty Curve:** Implement a logic in `Assets/game.lua` that increases `runSpeed` and decreases spawn intervals every 30 seconds. ✓

#### **Day 3–4: GUI & HUD Implementation**
- **HUD Class:** Create `Assets/Entities/GUI/HUD.lua` extending `GUIEntity`. ✓
- **State Binding:** Use the Observer pattern (`Libs/State/subject.lua`) to update the score text whenever `Game.state.score` changes. ✓
- **Pause UI:** Implement a simple pause button that calls `Game.time.pause()`. ✓

#### **Day 4–5: Game Over Flow**
- **Death Sequence:** On collision, call `Game.time.pause()`, play death SFX via `Plugins/soundPlayer.lua`. ✓
- **Overlay:** Show a "Game Over" overlay with "Retry" and "Menu" buttons. ✓
- **Restart Logic:** Use `_G.game.goTo("mainGame")` to ensure a clean state reset. ✓

---

# ⭐ **Sprint 3 — Audio, Persistence & Data (Week 3)**
**Goal:** Add professional polish with persistent data and data-driven obstacle patterns.

### 📌 **Task Breakdown**

#### **Day 1–2: Audio System Integration**
- **Asset Loading:** Register SFX and BGM in `Assets/Audio/loader.lua`. ✓
- **Playback:** Use `Plugins/soundPlayer.lua` for jump, land, and crash sounds. ✓
- **BGM Management:** Use `Assets/Audio/music.lua` to handle looping background music with crossfades. ✓

#### **Day 2–3: Persistence & High Scores**
- **Save Logic:** Use `Plugins/loadSave.lua` to store `highScore` in `savedData.json`. ✓
- **State Persistence:** Call `Game.save()` when a new high score is achieved at the end of a run. ✓
- **Initialization:** Ensure `_G.savedData.getValue("state.highScore")` is loaded into the HUD on start. ✓

#### **Day 3–4: Data-Driven Obstacle Patterns**
- **JSON Definition:** Create `data/patterns.json` with various obstacle sequences. ✓
- **Parser:** Use `pl.data` or a simple JSON parser to load patterns into a Lua table. ✓
- **Pattern Spawner:** Update the obstacle spawner to pick a random pattern from the JSON list instead of a single obstacle. ✓

#### **Day 4–5: Debugging & Tuning**
- **Debug Settings:** Utilize `Debug/settings.lua` to toggle `SKIP_ERRORS` and `ENTITY_GROUPS` for visual collision testing. ✓
- **Profiling:** Use the performance monitor in `Debug/main.lua` to check for memory leaks or frame drops during heavy obstacle spawns. ✓

---

# ⭐ **Sprint 4 — Visual Polish & Release Prep (Week 4)**
**Goal:** Replace placeholders and prepare the build for distribution.

### 📌 **Task Breakdown**

#### **Day 1–2: Visual Asset Integration**
- **Spritesheets:** Use `Assets/Entities/Animated/spriteSheetAnimation.lua` for the player run/jump animations. ✓
- **Final Art:** Replace placeholder rectangles with silhouette sprites for obstacles and backgrounds. ✓

#### **Day 2–3: UX "Juice" & Effects**
- **Transitions:** Use `Libs/transition2.lua` for smooth UI entries and screen shakes on collision. ✓
- **Particles:** Add a dust particle effect behind the player when running on the ground. ✓

#### **Day 3–4: Optimization & Cleanup**
- **Object Pool Tuning:** Adjust pool sizes in `ObjectPool.load()` to prevent runtime allocations. ✓
- **Global Cleanup:** Ensure all event listeners are removed in `scene:hide` and `entity:stop`. ✓

#### **Day 4–5: Build & Deployment**
- **Build Settings:** Configure `build.settings` for iOS/Android (icons, splash screens, permissions). ✓
- **Final Validation:** Run the `make ci` suite to ensure no linting errors or broken tests exist before final export.

---

### ✔ **Definition of Done**
- [x] Game runs at stable 60 FPS on target devices.
- [x] High scores persist after app restart.
- [x] No Lua errors or memory leaks detected in 10-minute play sessions.
- [x] All code follows the project's Class and Entity patterns.
