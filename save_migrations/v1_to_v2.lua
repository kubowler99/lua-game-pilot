-- save_migrations/v1_to_v2.lua
-- Example migration: v1 -> v2
-- Return the migrated savedData table.

return function(savedData)
    savedData = savedData or {}
    -- Example: move savedData.player.score -> savedData.state.player.score
    if savedData.player and savedData.player.score and not (savedData.state and savedData.state.player) then
        savedData.state = savedData.state or {}
        savedData.state.player = savedData.state.player or {}
        savedData.state.player.score = savedData.player.score
        savedData.player.score = nil
    end
    savedData.schemaVersion = 2
    return savedData
end