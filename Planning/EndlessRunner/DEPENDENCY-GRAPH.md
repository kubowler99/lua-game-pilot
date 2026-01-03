# 🧩 **Module Dependency Graph**

---

```mermaid
graph TD

    %% Root entry point
    MAIN[main.lua] --> MENU[scenes/menu.lua]
    MAIN --> GAME[scenes/game.lua]

    %% Menu scene dependencies
    MENU --> BUTTONS[ui/buttons.lua]
    MENU --> STORAGE[systems/storage.lua]

    %% Game scene dependencies
    GAME --> PLAYER[systems/player.lua]
    GAME --> OBSTACLES[systems/obstacles.lua]
    GAME --> BACKGROUND[systems/background.lua]
    GAME --> SCORE[systems/score.lua]
    GAME --> HUD[ui/hud.lua]
    GAME --> AUDIO[systems/audioManager.lua]
    GAME --> STORAGE

    %% Systems → Data
    OBSTACLES --> PATTERNS[data/patterns.json]
    SCORE --> DIFFICULTY[data/difficulty.json]
    STORAGE --> SAVEFILE[save.json]

    %% UI dependencies
    HUD --> BUTTONS
```

---

# 🔍 What This Diagram Shows

### **1. Entry Point**
- `main.lua` loads Composer and routes to the menu.

### **2. Scene Dependencies**
- `menu.lua` uses:
  - `buttons.lua` for UI
  - `storage.lua` to load high scores

- `game.lua` orchestrates:
  - Player system
  - Obstacle system
  - Background system
  - Score system
  - HUD
  - Audio
  - Storage

### **3. System → Data Relationships**
- Obstacle patterns come from `patterns.json`
- Difficulty curves come from `difficulty.json`
- Save data is persisted in `save.json`

### **4. UI Layer**
- HUD depends on the shared button module

---
