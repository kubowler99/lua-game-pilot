local Entity = require("Assets.Entities.entity")

---@class AnimationBase : Entity
local AnimationBase = Class("animation", Entity)

function AnimationBase:create(parent)
  Entity.create(self, parent)
end

function AnimationBase:playAnimation(animation, params)
  -- To be overridden
end

function AnimationBase:stop()
  Entity.stop(self)
end

function AnimationBase:hardReset()
  Entity.hardReset(self)
end

return AnimationBase
