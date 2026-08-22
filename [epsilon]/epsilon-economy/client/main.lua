-- epsilon-economy / client/main.lua

AddEventHandler('epsilon:spawn:complete', function(data)
    if data and data.id then
        TriggerServerEvent('epsilon:economy:setActiveChar', data.id)
    end
end)
