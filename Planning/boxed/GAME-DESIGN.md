## Boxed — Game Design Document

### Overview
**Title:** Boxed  
**Author:** EndarianDev  
**Genre:** Single-player 2D puzzle-platform prototype  
**Engine:** Solar2D (Lua)  
**Target platforms:** Desktop (Windows/macOS) Only  
**Playtime:** ~5–15 minutes (short prototype)  
**Scope:** Minimal, polished vertical slice with 8 rooms across three acts: Introduction (3), Trickery (3), End (2). Focus on tight interactions, clear feedback, and playful misdirection.

**High-level goal:** The player must find and press the correct button in each room to open the next door. Rooms escalate from obvious to deceptive, culminating in a false ending and a true ending.

---

## Core Gameplay Mechanics

### Player
- **Movement:** Left, right, jump. Desktop-only controls using Arrow keys or A/D for movement and Space for jump.
- **Resolution:** Built for standard HD monitors (1920x1080 / 1080p). UI and Environment are scaled for 16:9 aspect ratio.
- **Physics:** Lightweight platformer physics using Solar2D `physics` module. Gravity moderate; jump arc tuned for short hops and one longer jump.
- **Collision:** Player collides with floor, walls, buttons, triggers, and hazards (non-lethal lava).

### Buttons
- **Types:**
  - **Real Button:** Pressable; triggers door open or next room. Visual: solid color, subtle glow when near.
  - **Fake Button:** Non-pressable; may animate or emit sound to mislead. Visual: desaturated or slightly offset; may be identical until player attempts to press.
  - **One-way Buttons:** Buttons that appear pressable but only respond from a specific side or after a condition.
- **Interaction:** Player must overlap button and press action key (or tap) to attempt press. Buttons have states: Idle, Hover (player nearby), Pressed, Disabled.
- **Feedback:** Visual press animation, sound effect, small particle burst, and door animation.

### Room Progression Rules
- Pressing the correct button advances to the next room. Pressing a fake button produces a failure cue (sound, shake, text hint) but does not reset the room.
- Some rooms require traversal or simple platforming to reach the real button.
- No lives; mistakes are non-punishing to encourage exploration.

### Accessibility
- **Assist Mode:** Optional highlight of interactive objects after a short idle time.
- **Controls:** Remappable keyboard keys. High-contrast cursor/focus for menu navigation.
- **Audio:** Subtitles for important audio cues; adjustable volume sliders.

---

## Rooms and Level Design

### Design Principles
- **Clarity first:** Early rooms teach mechanics; later rooms subvert expectations.
- **Economy of assets:** Reuse room geometry and props with different lighting and object placement.
- **Player guidance:** Use lighting, camera framing, and audio to suggest or mislead.

### Act 1 Introduction Rooms
#### Room 1
- **Layout:** Small box, button centered in front of player spawn.
- **Goal:** Press the obvious button.
- **Teaching:** Demonstrates basic press interaction.

#### Room 2
- **Layout:** Two buttons side by side; only one is pressable.
- **Trick:** The pressable button has a subtle affordance (slightly raised, different shadow).
- **Goal:** Teach that not all buttons are functional.

#### Room 3
- **Layout:** Two buttons; one is the wrong color.
- **Trick:** Color is a clue; player learns to use visual cues.

### Act 2 Trickery Rooms
#### Room 4
- **Layout:** Button-looking object in front is fake; real button behind player.
- **Trick:** Encourages looking around and exploring the room boundaries.

#### Room 5
- **Layout:** Long hall with bump in middle; fake button at far end; real button behind the player when they reach the end.
- **Mechanics:** Jump over bump; bump implemented as small collider requiring timed jump.
- **Trick:** Lures player forward then punishes forward-only thinking.

#### Room 6
- **Layout:** Parkour section over lava (non-lethal) leading to button.
- **Mechanics:** Falling into lava returns player to last safe platform; lava produces smoke and sound but no death.
- **Trick:** Creates tension without harsh penalty.

### Act 3 End Rooms
#### Room 7 False Ending
- **Layout:** Box with floating text “YOU WIN.” Behind the text is a discolored false wall.
- **Trick:** Walking through false wall reveals hidden button that leads to final room.
- **Feedback:** Subtle visual seam and different texture hint at false wall.

#### Room 8 True Ending
- **Layout:** Button in front; pressing it triggers walls to drop and reveals endless desert background.
- **Ending Text:** “You actually did it; YOU BECAME UNBOXED *cheering noises*” and credits box.
- **Closure:** Play celebratory audio and show credits overlay.

---

## Technical Implementation

### Project Structure
The project follows a structured architecture using global `Game` management, `Entity` inheritance, and `Chapter` (Story) progression.

```
/main.lua                -- Entry point, initializes Game
/Assets/
  /Audio/                -- SFX and Music loaders
  /Entities/             -- All game objects (Players, Buttons, etc.)
    /Boxed/              -- Game-specific entities
      player.lua
      button.lua
    entity.lua           -- Base Entity class
  /Scenes/               -- Composer scenes
    mainGame.lua         -- Main scene for room rendering
  /Story/                -- Story and Chapter management
    boxedStory.lua       -- Handles progression through rooms
    roomDefinitions.lua  -- Data for each room
/Plugins/
  loadSave.lua           -- State persistence
```

### Scene Management
- **Orchestration:** Controlled via `Assets/Story/boxedStory.lua`. The story module manages the `roomIndex` and high-level game logic.
- **Rendering Stage:** Uses a single generic scene `Assets/Scenes/room.lua` which remains active throughout the game session.
- **Transitions:** Handled by a smooth "fade-out/fade-in" overlay managed by the `boxedStory` (using `fadeOutIn` from `ChapterBasics`).
- **Flow:**
    1. `boxedStory` calls `game.goTo("room")` initially.
    2. `room.lua` (Scene) initializes the `BoxedEnvironment` entity and stores it in `game.shortcuts.environment`.
    3. When a room is completed, `boxedStory:nextRoom()` is triggered.
    4. The story performs a `fadeOutIn`. During the "dark" phase (`onLoading`), it increments `roomIndex`, saves progress, and calls `environment:refresh()`.
    5. `BoxedEnvironment:refresh()` clears current room entities and rebuilds the next room from `roomDefinitions.lua` without reloading the Composer scene.

### Code Modules & Responsibilities

#### 1. The Story (`Assets/Story/boxedStory.lua`)
- Inherits from `ChapterBasics`.
- Manages `roomIndex` and progression logic.
- Implements `nextRoom()`: Triggers `fadeOutIn` and instructs the environment to refresh.

#### 2. The Scene (`Assets/Scenes/room.lua`)
- Generic Composer scene that acts as a container for the game world.
- Responsibilities: Lifecycle management (create/show/remove) and initializing the primary `Environment` entity.

#### 3. The Environment (`Assets/Entities/Environments/Boxed/main.lua`)
- Inherits from `Entity`.
- The "Level Builder": Iterates through `roomDefinitions[roomIndex]` and spawns all necessary entities (Player, Button, Lava, False Walls).
- Implements `refresh()`: Cleans up the current room and builds the next one.

#### 4. Player Module (`Assets/Entities/Boxed/player.lua`)
- Inherits from `Entity`.
- Handles physics-based movement, jumping, and collision with hazards.

#### 5. Button Module (`Assets/Entities/Boxed/button.lua`)
- Inherits from `Entity`.
- `Button:create(parent, params)`: Defines visuals, sounds, and `isFake` state.
- `Button:onPress()`: Triggers `game.story:nextRoom()` if real; plays failure cues if fake.

### Technical Snippets (Architectural Alignment)
```lua
-- Assets/Story/boxedStory.lua snippet
function BoxedStory:nextRoom()
  self:fadeOutIn({
    onLoading = function()
      Game.state.roomIndex = Game.state.roomIndex + 1
      Game.save()
      
      -- Refresh the existing environment instead of reloading the scene
      if game.shortcuts.environment then
        game.shortcuts.environment:refresh()
      end
    end
  })
end
```

### Input Handling
The project uses a **Decentralized Keyboard Input** model. This ensures that movement logic remains encapsulated within the Player entity for maximum responsiveness.

- **Desktop (Keyboard):** The `Player` entity registers its own `Runtime` "key" listeners. This provides the lowest latency for platforming mechanics. Supported inputs: Arrow keys, WASD, and Spacebar.
- **Input Management:** The `Player` entity handles its own lifecycle for listener registration and removal during room transitions to prevent input leakage.

#### Input Snippet (Player Entity)
```lua
-- Assets/Entities/Boxed/player.lua
function Player:addListeners()
  local function onKey(event)
    if event.phase == "down" then
      if event.keyName == "space" then self:jump() end
    end
    -- Handle move left/right states...
  end
  Runtime:addEventListener("key", onKey)
  self._onKey = onKey -- Store for removal
end

function Player:remove()
  Runtime:removeEventListener("key", self._onKey)
  Entity.remove(self)
end
```

### Camera and UI
- `Game.shortcuts.environment` allows for camera tracking if needed.
- UI is managed by `GUIEntity` subclasses, separated from the game world layers.

### Save and Progress
- Leverages `_G.savedData` (Plugins/loadSave.lua).
- Progression is stored in `Game.state.roomIndex`.
- `Game.save()` is called on every successful room transition.

### Performance
- Target 60 FPS at 1080p resolution. Optimize for desktop GPU/CPU. Reuse display objects where possible to maintain high performance at 1920x1080.

---

## Art Audio UI

### Visual Style
- **Aesthetic:** Clean, low-poly 2D with strong color contrasts. Rooms are boxes with subtle variations in texture and lighting.
- **Palette:** Neutral walls, bright button colors (red, green, blue), desaturated fake objects.
- **UI:** Minimal HUD — small text for room number and optional hint toggle.

### Audio
- **SFX:** Button press, fake press (comedic boing), door open, jump, landing, lava sizzle, celebratory fanfare.
- **Music:** Light ambient loop that changes subtly between acts (calm → tense → triumphant). Music optional and toggleable.

### Text and Voice
- Floating text used sparingly (e.g., “YOU WIN” false ending). Credits displayed in a scrollable text box.

---

## Production Plan

### Milestones
1. **Prototype Core** (1 week)
  - Player movement, button press, composer scene switching, one sample room.
2. **Room Set Implementation** (1 week)
  - Implement all 8 rooms with mechanics and fake buttons.
3. **Polish and Feedback** (1 week)
  - Visual polish, audio, particle effects, accessibility options.
4. **Testing and Bugfixes** (1 week)
  - Playtesting, keyboard input tuning, 1080p performance optimization.
5. **Release Prep** (1 week)
  - Build targets, store metadata, short trailer/screenshots.

### Testing Checklist
- Button press detection reliable on keyboard (Space/WASD/Arrows).
- Fake buttons never trigger progression.
- Parkour bump and lava behavior consistent.
- False wall seam detectable but not obvious.
- Save/load restores last unlocked room.

### Metrics for Success
- Player reaches true ending in at least 60% of playtests without external hints.
- No major control or collision bugs on target devices.
- Prototype completed within 4–6 weeks.

---

## Additional Notes and Design Rationale
- **Why non-lethal lava:** Keeps the game friendly and focused on puzzle discovery rather than punishment.
- **Why false ending:** Adds a memorable twist and a short meta moment that rewards curiosity.
- **Replayability:** Minimal, but players may enjoy speedrunning or finding the false wall quickly.

---

### Deliverables for Implementation
- **Working prototype** with all rooms and transitions.
- **Asset list** (PNG sprites, SFX, music stems).
- **Code modules**: `Assets/Entities/Boxed/player.lua`, `Assets/Entities/Boxed/button.lua`, `Assets/Entities/Environments/Boxed/main.lua`, `Assets/Story/roomDefinitions.lua`, `Assets/Story/boxedStory.lua`, `Assets/Scenes/room.lua`.
- **Design doc** (this file) and a short README with build instructions.

If you want, I can now produce the `roomDefinitions.lua` schema and a starter `boxedStory.lua` template in Lua tailored for the project's architecture to jumpstart development.
