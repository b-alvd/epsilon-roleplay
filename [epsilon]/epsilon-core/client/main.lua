-- epsilon-core client: bootstrap

Epsilon       = Epsilon or {}
Epsilon.Local = {
    playerId   = nil,
    characterId = nil,
    spawned    = false,
}

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Epsilon.Local.playerId = PlayerId()
    Epsilon.Debug.Success('epsilon-core client ready (player %d)', Epsilon.Local.playerId)
end)
