# Boxed — Development Plan

This document outlines the sprint-based implementation plan for the **Boxed** prototype, following the architecture defined in `GAME-DESIGN.md`.

## Project Overview
- **Goal:** 8-room puzzle-platformer prototype.
- **Architecture:** Single Scene (`room.lua`) + Dedicated Story (`boxedStory.lua`) + Data-Driven Environment.
- **Platform:** Desktop-only (1080p).
- **Duration:** 5 Sprints (estimated 1 week per sprint).

---

## Sprint 1: Core Framework & Infrastructure
**Goal:** Establish the foundation of the Story-Scene-Environment lifecycle.

- **[BOX-1.1] Setup Project Structure:** 
  - Create directories: `Assets/Entities/Boxed/`, `Assets/Entities/Environments/Boxed/`.
- **[BOX-1.2] Implementation of `boxedStory.lua`:**
  - Inherit from `ChapterBasics`.
  - Initialize `Game.state.roomIndex`.
  - Implement basic `nextRoom()` logic with `fadeOutIn`.
- **[BOX-1.3] Implementation of `room.lua` (Scene):**
  - Create the generic Composer scene.
  - Initialize the `BoxedEnvironment` entity on `create`.
- **[BOX-1.4] Implementation of `BoxedEnvironment` (main.lua):**
  - Inherit from `Entity`.
  - Create the `refresh()` method skeleton.
- **[BOX-1.5] Room Data Schema:**
  - Define `Assets/Story/roomDefinitions.lua` with placeholder data for Room 1.

**Deliverable:** A black screen that transitions to an empty "Room" and can trigger a fade-out/in.

---

## Sprint 2: Movement & Basic Interactions
**Goal:** Implement the Player and the primary interaction mechanic (Buttons).

- **[BOX-2.1] Player Entity:**
  - Physics body setup (box/capsule).
  - Keyboard listeners (Desktop).
  - Public methods: `jump()`, `move(dir)`.
- **[BOX-2.2] Button Entity:**
  - Visual states (Idle, Pressed).
  - `onPress()` logic: check `isFake`.
  - Callback to `game.story:nextRoom()`.
- **[BOX-2.3] Simple Room Loading:**
  - `BoxedEnvironment` spawns the Player and one Real Button based on `roomDefinitions.lua`.
- **[BOX-2.4] Collision & Triggers:**
  - Ensure Player can stand on floor and "press" buttons.

**Deliverable:** A playable Room 1 where the player can move, jump, and press a button to "finish" the room.

---

## Sprint 3: Level Implementation (Introduction & Trickery)
**Goal:** Implement the logic for Rooms 1 through 6.

- **[BOX-3.1] Act 1 (Rooms 1-3):**
  - Implement "Two Buttons" logic.
  - Implement Color-coded clues.
- **[BOX-3.2] Act 2 (Rooms 4-6):**
  - Implement "Button Behind Player" (Room 4).
  - Implement the "Bump" obstacle and Hallway logic (Room 5).
  - Implement "Non-lethal Lava" and respawn logic (Room 6).
- **[BOX-3.3] Environment Refresh Logic:**
  - Polish `environment:refresh()` to cleanly remove old entities and rebuild the new room.
- **[BOX-3.4] Save/Load Integration:**
  - Ensure `Game.save()` is called and state persists across restarts.

**Deliverable:** Playable sequence of 6 rooms with functioning traps and progression.

---

## Sprint 4: The Twist & Visual Polish
**Goal:** Implement the final acts and add visual juice.

- **[BOX-4.1] Room 7 (False Ending):**
  - Implement the False Wall entity (non-colliding or specific collision).
  - Floating text "YOU WIN" setup.
- **[BOX-4.2] Room 8 (True Ending):**
  - "Walls Drop" animation sequence.
  - Transition to Desert background.
  - Credits overlay integration.
- **[BOX-4.3] Visual FX:**
  - Particle bursts on button press.
  - Sizzle effect for lava.
  - Screen shake on fake button failure.
- **[BOX-4.4] Lighting & Textures:**
  - Apply the "Clean, low-poly" color palette.

**Deliverable:** Complete game flow from Room 1 to the True Ending with all visual effects.

---

## Sprint 5: Audio, Polishing & Final QA
**Goal:** Finalize assets, optimize for desktop, and bug fixing.

- **[BOX-5.1] Audio Implementation:**
  - Hook up all SFX (jump, land, press, fail).
  - Ambient music loop with state-based variations.
- **[BOX-5.2] 1080p Optimization:**
  - Ensure all UI and Environment assets scale correctly to 1920x1080.
  - Finalize texture filtering settings for desktop displays.
- **[BOX-5.3] Balancing & Tuning:**
  - Tune jump height and movement speed for keyboard responsiveness.
  - Adjust timing for fake button cues.
- **[BOX-5.4] Final Testing:**
  - Verify "Assist Mode" (highlights).
  - Performance check on target desktop environments (Windows/macOS).

**Deliverable:** A release-ready vertical slice of **Boxed**.

---

## Technical Debt & Future Considerations
- **Localization:** Prepare strings for future translation.
- **Level Editor:** Potential for a simple JSON-based tool if more rooms are added.
- **Refactoring:** Consolidate any duplicate logic between `BoxedEnvironment` and `mainGame`.
