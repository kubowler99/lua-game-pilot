# 🧩 **Pixel Runner — Architecture Diagram**

---

```mermaid
flowchart TD

    %% ============================
    %% SCENES
    %% ============================
    subgraph Scenes
        MENU[menu.lua]
        GAME[game.lua]
    end

    %% ============================
    %% SYSTEMS
    %% ============================
    subgraph Systems
        PLAYER[player.lua]
        OBSTACLES[obstacles.lua]
        BACKGROUND[background.lua]
        SCORE[score.lua]
        AUDIO[audioManager.lua]
        STORAGE[storage.lua]
    end

    %% ============================
    %% UI
    %% ============================
    subgraph UI
        HUD[hud.lua]
        BUTTONS[buttons.lua]
    end

    %% ============================
    %% DATA
    %% ============================
    subgraph Data
        PATTERNS[patterns.json]
        DIFFICULTY[difficulty.json]
        SAVEFILE[save.json]
    end

    %% ============================
    %% SCENE FLOW
    %% ============================
    MENU -->|Play| GAME
    GAME -->|Game Over| MENU

    %% ============================
    %% GAME SCENE DEPENDENCIES
    %% ============================
    GAME --> PLAYER
    GAME --> OBSTACLES
    GAME --> BACKGROUND
    GAME --> SCORE
    GAME --> HUD
    GAME --> AUDIO

    %% ============================
    %% SYSTEM DEPENDENCIES
    %% ============================
    PLAYER --> AUDIO
    OBSTACLES --> PATTERNS
    SCORE --> DIFFICULTY
    STORAGE --> SAVEFILE
    HUD --> BUTTONS

    %% ============================
    %% SAVE/LOAD
    %% ============================
    MENU --> STORAGE
    GAME --> STORAGE
```

---

# 🔍 **How to Read This Diagram**

### **Scenes**
- `menu.lua` and `game.lua` are the entry points.
- Flow is simple: **Menu → Game → Menu**.

### **Systems**
Each system is modular and reusable:
- **player.lua** handles movement, jumping, physics.
- **obstacles.lua** manages pooling, spawning, patterns.
- **background.lua** handles parallax scrolling.
- **score.lua** manages scoring + difficulty curves.
- **audioManager.lua** centralizes SFX/BGM.
- **storage.lua** handles persistence.

### **UI**
- HUD displays score and game state.
- Buttons module provides reusable UI components.

### **Data**
- JSON files define obstacle patterns and difficulty curves.
- Save file stores high score + settings.

---
