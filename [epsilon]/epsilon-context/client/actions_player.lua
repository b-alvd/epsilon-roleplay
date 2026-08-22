-- Actions sur un joueur (Alt+clic sur un ped joueur)

ECM_Register(function(screenPos, hitSomething, worldPos, hitEntity, normalDir)
    if not DoesEntityExist(hitEntity) then return end
    if not IsPedAPlayer(hitEntity) then return end

    local targetNet  = NetworkGetPlayerIndexFromPed(hitEntity)
    local targetSrc  = GetPlayerServerId(targetNet)
    local targetName = GetPlayerName(targetNet)
    local myName     = GetPlayerName(PlayerId())
    local isSelf     = PlayerPedId() == hitEntity

    -- ── Animations (autrui uniquement) ───────────────────────────────────────
    if not isSelf then
        local subAnim = ECM_AddSubmenu(0, "Animations")
        local animCheck = ECM_AddItem(subAnim, "Faire un check")
        local animHug   = ECM_AddItem(subAnim, "Faire un câlin")
        ECM_OnActivate(animCheck, function()
            if NearEnough(hitEntity) then
                ExecuteCommand("e sbro")
                Notify('Check avec ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-hand-index-fill')
            else Notify('Trop loin de ' .. targetName, '#ef4444', 'bi-x-circle-fill') end
        end)
        ECM_OnActivate(animHug, function()
            if NearEnough(hitEntity) then
                ExecuteCommand("e shug")
                Notify('Câlin avec ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-heart-fill')
            else Notify('Trop loin de ' .. targetName, '#ef4444', 'bi-x-circle-fill') end
        end)

        -- ── Suggérer un niveau de voix ────────────────────────────────────────
        local subVoice  = ECM_AddSubmenu(0, "Suggérer une voix")
        local vChuchote = ECM_AddItem(subVoice, "Chuchoté")
        local vParler   = ECM_AddItem(subVoice, "Parler")
        local vCrier    = ECM_AddItem(subVoice, "Crier")
        ECM_OnActivate(vChuchote, function()
            TriggerServerEvent('epsilon:context:notifyPlayer', targetSrc, myName .. " vous suggère de chuchoter.")
            Notify('Suggestion envoyée à ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-chat-dots-fill')
        end)
        ECM_OnActivate(vParler, function()
            TriggerServerEvent('epsilon:context:notifyPlayer', targetSrc, myName .. " vous suggère de parler normalement.")
            Notify('Suggestion envoyée à ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-chat-dots-fill')
        end)
        ECM_OnActivate(vCrier, function()
            TriggerServerEvent('epsilon:context:notifyPlayer', targetSrc, myName .. " vous suggère de crier.")
            Notify('Suggestion envoyée à ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-chat-dots-fill')
        end)

        -- ── Report ────────────────────────────────────────────────────────────
        local subReport = ECM_AddSubmenu(0, "Report (" .. targetSrc .. ")")
        local reasons   = { "HRP", "Vocal HRP", "Troll", "Freekill", "Chicken run", "Free loot" }
        for _, reason in ipairs(reasons) do
            local item = ECM_AddItem(subReport, reason)
            ECM_OnActivate(item, function()
                ExecuteCommand("report ID:" .. targetSrc .. " | " .. reason)
                Notify('Report envoyé : ' .. reason, '#f59e0b', 'bi-flag-fill')
            end)
        end
    end

    -- ── Admin uniquement ──────────────────────────────────────────────────────
    if not IsAdmin() then return end

    ECM_AddSeparator(0)

    local label    = isSelf and "(admin) Moi-même" or ("(admin) " .. targetName)
    local subAdmin = ECM_AddSubmenu(0, label)

    local iHeal   = ECM_AddItem(subAdmin, "Heal")
    local iRevive = ECM_AddItem(subAdmin, "Revive")
    local iKill   = not isSelf and ECM_AddItem(subAdmin, "Kill")
    local iFreeze = ECM_AddItem(subAdmin, "Freeze / Unfreeze")
    local iBring  = not isSelf and ECM_AddItem(subAdmin, "Bring")
    local iGoto   = not isSelf and ECM_AddItem(subAdmin, "Goto")
    local iKick   = not isSelf and ECM_AddItem(subAdmin, "Kick")
    local iWarn   = not isSelf and ECM_AddItem(subAdmin, "Warn")
    local iMsg    = not isSelf and ECM_AddItem(subAdmin, "Message staff")

    local function logPlayer(action) TriggerServerEvent('epsilon:admin:logAction', action, targetSrc) end

    ECM_OnActivate(iHeal,   function() TriggerServerEvent('epsilon:admin:healPlayer',   targetSrc); logPlayer('heal')   end)
    ECM_OnActivate(iRevive, function() TriggerServerEvent('epsilon:admin:revivePlayer', targetSrc); logPlayer('revive') end)
    if iKill   then ECM_OnActivate(iKill,   function() TriggerServerEvent('epsilon:admin:killPlayer',   targetSrc); logPlayer('kill')   end) end
    ECM_OnActivate(iFreeze, function() TriggerServerEvent('epsilon:admin:freezePlayer', targetSrc); logPlayer('freeze') end)
    if iBring  then ECM_OnActivate(iBring,  function() TriggerServerEvent('epsilon:admin:bringPlayer',  targetSrc); logPlayer('bring')  end) end
    if iGoto   then ECM_OnActivate(iGoto,   function() TriggerServerEvent('epsilon:admin:teleportTo',   targetSrc); logPlayer('goto')   end) end
    if iKick   then ECM_OnActivate(iKick,   function() TriggerServerEvent('epsilon:admin:kick', targetSrc, 'Context menu'); logPlayer('kick') end) end
    if iWarn   then ECM_OnActivate(iWarn,   function() TriggerServerEvent('epsilon:admin:warnPlayer', targetSrc, 'Context menu'); logPlayer('warn') end) end
    if iMsg    then ECM_OnActivate(iMsg,    function() TriggerServerEvent('epsilon:context:notifyPlayer', targetSrc, "[STAFF] Message reçu."); logPlayer('staff_message'); Notify('Message envoyé à ' .. targetName, 'rgba(147,51,234,0.85)', 'bi-chat-dots-fill') end) end
end)
