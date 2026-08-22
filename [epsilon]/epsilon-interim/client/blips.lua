local QUARTIER_COLORS = { 2, 3, 5, 1, 6, 7, 8 }
local devBlips  = {}
local devActive = false

function createStartBlips()
    for key, def in pairs(Config.Missions) do
        if def.depot then
            local b = AddBlipForCoord(def.depot.coords.x, def.depot.coords.y, def.depot.coords.z)
            SetBlipSprite(b, def.blip.sprite)
            SetBlipColour(b, def.blip.color)
            SetBlipScale(b, 0.6)
            SetBlipAsShortRange(b, true)
            SetBlipCategory(b, 254)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('[Interim] ' .. def.label)
            EndTextCommandSetBlipName(b)
            IS.startBlips[#IS.startBlips + 1] = b
        end
    end
end

function createDevBlips()
    for key, def in pairs(Config.Missions) do
        if key == 'eboueur' and def.quartiers then
            for qi, q in ipairs(def.quartiers) do
                local col = QUARTIER_COLORS[qi] or 2
                for si, coords in ipairs(q.spots) do
                    local b = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipSprite(b, 84)
                    SetBlipColour(b, col)
                    SetBlipScale(b, 0.55)
                    SetBlipAsShortRange(b, false)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString('[DEV] ' .. q.label .. ' #' .. si)
                    EndTextCommandSetBlipName(b)
                    devBlips[#devBlips + 1] = b
                end
            end
        elseif key == 'livreur_colis' and def.quartiers then
            for qi, q in ipairs(def.quartiers) do
                local col = QUARTIER_COLORS[qi] or 5
                for si, coords in ipairs(q.spots) do
                    local b = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipSprite(b, 501)
                    SetBlipColour(b, col)
                    SetBlipScale(b, 0.55)
                    SetBlipAsShortRange(b, false)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString('[DEV] ' .. q.label .. ' #' .. si)
                    EndTextCommandSetBlipName(b)
                    devBlips[#devBlips + 1] = b
                end
            end
        elseif def.stepPool then
            for si, step in ipairs(def.stepPool) do
                local b = AddBlipForCoord(step.coords.x, step.coords.y, step.coords.z)
                SetBlipSprite(b, def.blip and def.blip.sprite or 1)
                SetBlipColour(b, def.blip and def.blip.color or 2)
                SetBlipScale(b, 0.55)
                SetBlipAsShortRange(b, false)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString('[DEV] ' .. def.label .. ' #' .. si)
                EndTextCommandSetBlipName(b)
                devBlips[#devBlips + 1] = b
            end
        end
    end
    devActive = true
    TriggerEvent('epsilon:notify', {
        title = '[DEV] Interim',
        msg   = (#devBlips) .. ' blips créés.',
        type  = 'info',
    })
end

function clearDevBlips()
    for _, b in ipairs(devBlips) do
        if DoesBlipExist(b) then RemoveBlip(b) end
    end
    devBlips  = {}
    devActive = false
    TriggerEvent('epsilon:notify', { title='[DEV] Interim', msg='Blips supprimés.', type='info' })
end

RegisterCommand('interimdev', function()
    if devActive then clearDevBlips() else createDevBlips() end
end, false)
