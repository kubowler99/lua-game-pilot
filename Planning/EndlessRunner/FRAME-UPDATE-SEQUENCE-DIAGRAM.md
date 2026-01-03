# 🧩 **Pixel Runner — Sequence Diagram**

---

```mermaid
sequenceDiagram
    autonumber

    participant Player as Player System
    participant Obstacles as Obstacle System
    participant Background as Background System
    participant Score as Score System
    participant HUD as HUD UI
    participant Audio as Audio Manager
    participant Storage as Storage System
    participant Game as Game Scene (enterFrame)

    Note over Game: Frame Update Loop Begins

    Game->>Background: update(dt)
    Background-->>Game: parallax positions updated

    Game->>Player: update(dt)
    Player-->>Game: position, velocity, state

    Game->>Obstacles: update(dt)
    Obstacles-->>Game: spawn/despawn, movement

    Game->>Score: update(dt)
    Score-->>Game: new score value

    Game->>HUD: setScore(score)
    HUD-->>Game: score displayed

    Note over Player, Obstacles: Collision Check

    Player->>Obstacles: check collision
    Obstacles-->>Player: collision detected?

    alt Collision Occurs
        Player->>Audio: play("death")
        Game->>Storage: save(highScore)
        Game->>HUD: showGameOver()
        Game->>Game: transition to gameOver state
    else No Collision
        Note over Game: Continue running
    end

    Note over Game: Frame Update Loop Ends
```

---

# 🔍 **What This Diagram Shows**

### **1. The Game Scene orchestrates everything**
- `enterFrame` acts as the central update loop.
- Each system is updated in a predictable order.

### **2. Systems are modular and independent**
- Background scrolls.
- Player updates physics + state.
- Obstacles spawn/move/despawn.
- Score increments based on time.
- HUD reflects the score.

### **3. Collision detection is isolated**
- Player checks against obstacles.
- If collision → game over sequence triggers.

### **4. Game Over flow**
- Play death sound.
- Save high score.
- Show game over UI.
- Transition to gameOver state.

---
