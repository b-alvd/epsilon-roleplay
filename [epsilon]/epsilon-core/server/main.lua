-- epsilon-core server: bootstrap
-- Le cache joueurs est géré par epsilon-characters (env Lua isolé par ressource)
-- Utilisez exports['epsilon-characters']:GetPlayer(src) depuis les autres ressources

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Epsilon.Debug.Success('epsilon-core démarré — %s', Epsilon.Config.ServerName)
end)
