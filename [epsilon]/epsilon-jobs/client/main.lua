-- epsilon-jobs / client/main.lua

local currentJobs = {}
local jobDefs     = {}

-- Init au spawn
AddEventHandler('epsilon:spawn:complete', function(data)
    if data and data.id then
        TriggerServerEvent('epsilon:jobs:init', data.id)
    end
end)

-- Re-init quand la ressource redémarre en jeu
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    currentJobs = {}
    jobDefs     = {}
    TriggerServerEvent('epsilon:jobs:clientReady')
end)

-- Réception des données initiales
RegisterNetEvent('epsilon:jobs:data', function(data)
    currentJobs = data.jobs or {}
    jobDefs     = data.defs or {}
end)

-- Mise à jour (embauche / licenciement)
RegisterNetEvent('epsilon:jobs:update', function(data)
    currentJobs = data.jobs or {}
end)

-- Notification de paiement
RegisterNetEvent('epsilon:jobs:paid', function(data)
    local icons = {
        action = '💼',
        salary = '💰',
        aide   = '🏛️',
    }
    local icon = icons[data.pay_type] or '💰'
    TriggerEvent('epsilon:ui:notifyLocal', {
        msg  = string.format('%s %s — +%s $', icon, data.label, data.amount),
        type = 'success',
    })
end)

-- Exports client (pour les autres ressources)
exports('GetCurrentJobs', function() return currentJobs end)
exports('HasJob',         function(jobName)
    for _, j in ipairs(currentJobs) do
        if j.name == jobName then return true end
    end
    return false
end)
exports('GetJobDefs',     function() return jobDefs end)
