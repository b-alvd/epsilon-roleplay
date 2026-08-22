LOG = { INFO = false, DEBUG = false, WARNING = false, ERROR = false }

BACKGROUND = {
    TXD     = "customSprites",
    NAME    = "gradient",
    COLOR   = Colors.DarkGray,
    H_COLOR = Colors.LightGray,
    D_COLOR = Colors.Red,
}
TEXT = {
    FONT    = TextFont.Default,
    COLOR   = Colors.White,
    H_COLOR = Colors.White,
    D_COLOR = Colors.Grey,
}
BORDER = { COLOR = Colors.Grey }

-- Rang admin du joueur local (rempli à la connexion)
EpsilonAdminRank = nil

RegisterNetEvent('epsilon:admin:granted')
AddEventHandler('epsilon:admin:granted', function(rank)
    EpsilonAdminRank = rank
end)

function IsAdmin()
    return EpsilonAdminRank ~= nil
end

-- Vérifier le rang admin après le spawn du personnage
AddEventHandler('epsilon:spawn:complete', function()
    TriggerServerEvent('epsilon:admin:checkAdmin')
end)

-- Re-check si epsilon-context redémarre en cours de jeu
AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Citizen.CreateThread(function()
        Citizen.Wait(500)
        TriggerServerEvent('epsilon:admin:checkAdmin')
    end)
end)

function Notify(msg, color, icon)
    TriggerEvent('epsilon:ui:notifyLocal', {
        text     = msg,
        color    = color or 'rgba(147,51,234,0.85)',
        icon     = icon  or 'bi-cursor-fill',
        duration = 3,
    })
end

local function dist(a, b)
    local d = GetEntityCoords(a) - GetEntityCoords(b)
    return #d
end

function NearEnough(entity, maxDist)
    return dist(entity, PlayerPedId()) <= (maxDist or 3.5)
end
