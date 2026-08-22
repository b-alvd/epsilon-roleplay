-- epsilon-spawn client: bloque le spawn par défaut de spawnmanager
-- Le spawn réel est géré par epsilon-characters

-- Empêche le spawn automatique de spawnmanager
AddEventHandler('playerSpawned', function()
    -- On annule et on laisse epsilon-characters prendre la main
    -- (epsilon-characters se charge de tout dans son propre thread)
    Epsilon.Debug.Debug('[Spawn] playerSpawned intercepté — délégué à epsilon-characters')
end)

-- Notifié quand le spawn est complet (depuis epsilon-characters)
AddEventHandler('epsilon:spawn:complete', function(spawnData)
    Epsilon.Debug.Success('[Spawn] Joueur spawné: %s %s', spawnData.firstname or '?', spawnData.lastname or '?')

    -- S'assurer que le ped est visible sur le réseau
    SetEntityVisible(PlayerPedId(), true, false)

    -- Notifier les autres ressources
    TriggerEvent('epsilon:ready', spawnData)
end)
