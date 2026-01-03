# 🧩 **Pixel Runner — Game Flow Sequence Diagram**

---

```mermaid
sequenceDiagram
    autonumber

    participant User as Player
    participant Menu as menu.lua
    participant Game as game.lua
    participant PlayerSys as Player System
    participant Obstacles as Obstacle System
    participant Score as Score System
    participant HUD as HUD UI
    participant Storage as Storage System

    %% ============================
    %% MENU → GAME START
    %% ============================

    User->>Menu: Launch App
    Menu->>Storage: load(highScore)
    Storage-->>Menu: highScore data displayed

    User->>Menu: Tap "Play"
    Menu->>Game: composer.gotoScene("game")

    %% ============================
    %% GAME INITIALIZATION
    %% ============================

    Game->>PlayerSys: initialize()
    Game->>Obstacles: initialize()
    Game->>Score: reset()
    Game->>HUD: initialize()

    Game->>Game: start enterFrame loop
    Game->>Obstacles: start spawning

    %% ============================
    %% GAMEPLAY LOOP (Simplified)
    %% ============================

    loop Every Frame
        Game->>PlayerSys: update(dt)
        Game->>Obstacles: update(dt)
        Game->>Score: update(dt)
        Game->>HUD: setScore(score)
    end

    %% ============================
    %% COLLISION → GAME OVER
    %% ============================

    PlayerSys->>Obstacles: collision check
    Obstacles-->>PlayerSys: collision detected

    PlayerSys->>Game: notify death
    Game->>Obstacles: stop spawning
    Game->>Score: finalize score

    Game->>Storage: save(highScore)
    Storage-->>Game: confirm save

    Game->>HUD: showGameOver()

    %% ============================
    %% GAME OVER → RESTART OR MENU
    %% ============================

    User->>HUD: Tap "Retry"
    HUD->>Game: restart request
    Game->>Game: composer.gotoScene("game") (reload)

    User->>HUD: Tap "Menu"
    HUD->>Menu: composer.gotoScene("menu")
```

---

# 🔍 **What This Diagram Captures**

### **1. Full lifecycle of a run**
- App launch
- Menu load
- Game initialization
- Gameplay loop
- Collision → Game Over
- Restart or return to menu

### **2. Clear system responsibilities**
- `menu.lua` handles loading high score + navigation
- `game.lua` orchestrates systems
- Systems remain modular and independent

### **3. Persistence flow**
- High score loads on menu
- High score saves on game over

### **4. Clean restart logic**
- Restart simply reloads `game.lua`
- Ensures a clean state every run

---


