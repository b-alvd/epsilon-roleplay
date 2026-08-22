-- ═══════════════════════════════════════════════════════════════════
-- epsilon-status / client/main.lua
-- ═══════════════════════════════════════════════════════════════════

local activeCharId = nil

AddEventHandler('epsilon:spawn:complete', function(data)
    activeCharId = data.id
    TriggerServerEvent('epsilon:status:activate', data.id)
end)

-- Ré-activation après restart de la resource (charId déjà connu)
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetTimeout(1500, function()
        if activeCharId then
            TriggerServerEvent('epsilon:status:activate', activeCharId)
        end
    end)
end)
