-- ════════════════════════════════════════════════════════════════
--  epsilon-jobs / server/test.lua  (retirer en prod)
-- ════════════════════════════════════════════════════════════════

-- Commande console : job_test <playerId>
-- Exemple : job_test 1
--
-- Teste dans l'ordre :
--   1. Aide de l'État  (joueur sans job fixe)
--   2. RecordMissionAction  eboueur/collect
--   3. RecordMissionAction  eboueur/dump
--   4. Embauche LSPD grade 3
--   5. Cycle salaire forcé (juste pour ce joueur)
--   6. Promotion grade 5
--   7. Nouveau cycle salaire
--   8. Licenciement LSPD

-- Liste les joueurs connectés + leur état dans activeChars
RegisterCommand('job_who', function()
    print('\n[job_who] ── Joueurs connectés ──')
    for _, src in ipairs(GetPlayers()) do
        local s    = tonumber(src)
        local name = GetPlayerName(s) or '?'
        local data = activeChars[s]
        if data then
            print(string.format('  src=%-3d  %s  → charId=%d  jobs=%d', s, name, data.charId, #data.jobs))
        else
            print(string.format('  src=%-3d  %s  → PAS dans activeChars', s, name))
        end
    end
    print('')
end, true)

-- Force l'init jobs pour un joueur déjà spawné (si epsilon:spawn:complete raté)
-- Nécessite que le charId soit connu : job_init <src> <charId>
RegisterCommand('job_init', function(_, args)
    local src    = tonumber(args[1])
    local charId = tonumber(args[2])
    if not src or not charId then
        print('[job_init] Usage: job_init <src> <charId>')
        return
    end
    -- Reproduit exactement ce que fait RegisterNetEvent('epsilon:jobs:init')
    local jobs = exports['epsilon-database'] and MySQL.query.await(
        'SELECT jobs FROM characters WHERE id=?', { charId }
    ) or {}
    local parsedJobs = (jobs and jobs[1]) and (json.decode(jobs[1].jobs or '[]') or {}) or {}

    activeChars[src] = {
        charId           = charId,
        jobs             = parsedJobs,
        missionCooldowns = {},
        sessionEarned    = {},
    }
    for _, j in ipairs(parsedJobs) do
        if jobsDefs[j.id] then
            openSession(charId, j.id)
            activeChars[src].sessionEarned[j.id] = 0
        end
    end
    TriggerClientEvent('epsilon:jobs:data', src, {
        jobs     = parsedJobs,
        jobDefs  = getPublicJobDefs(),
        missions = getPublicMissions(),
    })
    print(string.format('[job_init] OK — src=%d charId=%d jobs=%d', src, charId, #parsedJobs))
end, true)

RegisterCommand('job_test', function(_, args)
    local src = tonumber(args[1])
    if not src then
        print('[job_test] Usage: job_test <playerId>')
        return
    end

    local charId = nil
    for s, data in pairs(activeChars) do
        if s == src then charId = data.charId; break end
    end

    if not charId then
        print('[job_test] Joueur ' .. src .. ' non trouvé dans activeChars (connecté ?)')
        return
    end

    print(string.format('\n[job_test] ── Début des tests pour src=%d charId=%d ──', src, charId))

    -- 1. Aide de l'État
    print('[job_test] 1. Aide de l\'État...')
    local aideDef = jobsDefs['chomeur']
    if aideDef then
        pay(src, charId, aideDef.aide_montant, "Aide de l'Etat [TEST]", 'chomeur', nil, 'aide')
        print('[job_test]    OK → +' .. aideDef.aide_montant .. '$')
    else
        print('[job_test]    ERREUR: job chomeur introuvable')
    end
    Wait(500)

    -- 2. Mission éboueur/collect
    print('[job_test] 2. RecordMissionAction eboueur/collect...')
    local ok, amount, err = exports['epsilon-jobs']:RecordMissionAction(src, charId, 'eboueur', 'collect')
    if ok then
        print('[job_test]    OK → +' .. amount .. '$')
    else
        print('[job_test]    ERREUR: ' .. tostring(err))
    end
    Wait(500)

    -- 3. Mission éboueur/dump
    print('[job_test] 3. RecordMissionAction eboueur/dump...')
    ok, amount, err = exports['epsilon-jobs']:RecordMissionAction(src, charId, 'eboueur', 'dump')
    if ok then
        print('[job_test]    OK → +' .. amount .. '$')
    else
        print('[job_test]    ERREUR: ' .. tostring(err))
    end
    Wait(500)

    -- 4. Test cooldown (re-collect immédiatement → doit échouer)
    print('[job_test] 4. Cooldown test (re-collect immédiat → doit échouer)...')
    ok, amount, err = exports['epsilon-jobs']:RecordMissionAction(src, charId, 'eboueur', 'collect')
    if not ok then
        print('[job_test]    OK (cooldown refusé comme attendu): ' .. tostring(err))
    else
        print('[job_test]    ERREUR: le cooldown n\'a pas bloqué!')
    end
    Wait(500)

    -- 5. Embauche LSPD grade 3
    print('[job_test] 5. AddJob lspd grade 3...')
    ok, err = exports['epsilon-jobs']:AddJob(src, charId, 'lspd', 3)
    if ok then
        print('[job_test]    OK → embauché LSPD Senior Officer')
    else
        print('[job_test]    ERREUR: ' .. tostring(err))
    end
    Wait(500)

    -- 6. Cycle salaire forcé (joueur seul)
    print('[job_test] 6. Cycle salaire forcé...')
    local data = activeChars[src]
    if data then
        local hasFixe = false
        for _, j in ipairs(data.jobs) do
            local def = jobsDefs[j.id]
            if def and def.type == 'fixe' then
                hasFixe = true
                local gradeInfo = gradesDefs[def.id] and gradesDefs[def.id][j.grade or 0]
                local salary = gradeInfo and gradeInfo.salary or 0
                if salary > 0 then
                    pay(src, charId, salary,
                        string.format('Salaire [TEST] — %s (%s)', def.label, gradeInfo.label),
                        def.name, nil, 'salary')
                    print('[job_test]    OK → +' .. salary .. '$ (' .. gradeInfo.label .. ')')
                end
            end
        end
        if not hasFixe then
            print('[job_test]    Pas de job fixe, aide versée à la place')
        end
    end
    Wait(500)

    -- 7. Promotion grade 5
    print('[job_test] 7. SetGrade lspd 5 (Sergeant)...')
    ok, err = exports['epsilon-jobs']:SetGrade(src, charId, 'lspd', 5)
    if ok then
        print('[job_test]    OK → promu Sergeant')
    else
        print('[job_test]    ERREUR: ' .. tostring(err))
    end
    Wait(500)

    -- 8. Cycle salaire avec nouveau grade
    print('[job_test] 8. Cycle salaire après promotion...')
    data = activeChars[src]
    for _, j in ipairs(data and data.jobs or {}) do
        local def = jobsDefs[j.id]
        if def and def.type == 'fixe' then
            local gradeInfo = gradesDefs[def.id] and gradesDefs[def.id][j.grade or 0]
            if gradeInfo and gradeInfo.salary > 0 then
                pay(src, charId, gradeInfo.salary,
                    string.format('Salaire [TEST] — %s (%s)', def.label, gradeInfo.label),
                    def.name, nil, 'salary')
                print('[job_test]    OK → +' .. gradeInfo.salary .. '$ (' .. gradeInfo.label .. ')')
            end
        end
    end
    Wait(500)

    -- 9. Gains du jour
    print('[job_test] 9. GetEarningsToday...')
    local earnings = exports['epsilon-jobs']:GetEarningsToday(charId)
    print(string.format('[job_test]    Total du jour: %d$', earnings.total))
    for ptype, info in pairs(earnings.byType) do
        print(string.format('[job_test]      %s: %d$ (%d paiements)', ptype, info.total, info.count))
    end
    Wait(500)

    -- 10. Licenciement
    print('[job_test] 10. RemoveJob lspd...')
    ok, err = exports['epsilon-jobs']:RemoveJob(src, charId, 'lspd')
    if ok then
        print('[job_test]    OK → licencié')
    else
        print('[job_test]    ERREUR: ' .. tostring(err))
    end

    print('[job_test] ── Tests terminés ──\n')
end, true)  -- true = console uniquement

-- Crée un contrat CDI actif pour un personnage (test solo sans autre joueur)
-- Usage console : testembauche <charId> [jobName] [grade] [salary]
-- Exemple      : testembauche 3 lspd 0 2500
RegisterCommand('testembauche', function(_, args)
    local charId  = tonumber(args[1])
    local jobName = args[2] or 'lspd'
    local grade   = tonumber(args[3]) or 0
    local salary  = tonumber(args[4]) or 2500

    if not charId then
        print('[testembauche] Usage: testembauche <charId> [jobName] [grade] [salary]')
        return
    end

    -- Vérifie que le personnage existe
    local charRow = MySQL.query.await('SELECT id, firstname, lastname FROM characters WHERE id=?', { charId })
    if not charRow or not charRow[1] then
        print('[testembauche] Personnage ' .. charId .. ' introuvable en DB')
        return
    end
    local char = charRow[1]

    -- Récupère le job
    local jobRow = MySQL.query.await('SELECT id, label FROM jobs WHERE name=? LIMIT 1', { jobName })
    if not jobRow or not jobRow[1] then
        print('[testembauche] Job "' .. jobName .. '" introuvable en DB')
        return
    end
    local job = jobRow[1]

    -- Vérifie qu'il n'y a pas déjà un contrat actif pour ce perso/job
    local existing = MySQL.scalar.await(
        "SELECT id FROM job_contracts WHERE character_id=? AND job_id=? AND status IN ('active','pending') LIMIT 1",
        { charId, job.id }
    )
    if existing then
        print('[testembauche] Contrat déjà existant (#' .. existing .. ') pour ce perso/job — annulé')
        return
    end

    -- Crée le contrat CDI actif
    local contractId = MySQL.insert.await([[
        INSERT INTO job_contracts (character_id, job_id, employer_id, type, salary, status, start_date)
        VALUES (?, ?, ?, 'cdi', ?, 'active', NOW())
    ]], { charId, job.id, charId, salary })

    if not contractId then
        print('[testembauche] Erreur lors de l\'insertion du contrat')
        return
    end

    -- Crée le document et donne l'item contrat
    local docData = {
        jobName = jobName, jobLabel = job.label,
        type = 'cdi', salary = salary,
        employer_id = charId, employee_id = charId,
    }
    local docId = exports['epsilon-documents']:CreateDocument(
        charId, 'contract', 'Contrat CDI — ' .. job.label, docData, 'document_contract', { charId }
    )
    if docId then
        MySQL.update('UPDATE job_contracts SET document_id=? WHERE id=?', { docId, contractId })
        local ok, err = exports['epsilon-inventory']:AddItem(charId, 'document_contract', 1, { document_id = docId })
        print('[testembauche] AddItem → ok=' .. tostring(ok) .. ' err=' .. tostring(err))
        -- Trouver le src du joueur pour pousser l'inventaire
        for _, s in ipairs(GetPlayers()) do
            local sn = tonumber(s)
            local d  = activeChars[sn]
            if d and d.charId == charId then
                exports['epsilon-inventory']:PushInventory(sn)
                print('[testembauche] PushInventory → src=' .. sn)
                break
            end
        end
    else
        print('[testembauche] CreateDocument a retourné nil — docId manquant')
    end

    -- Met à jour le grade dans le JSON jobs du personnage
    local jRow   = MySQL.query.await('SELECT jobs FROM characters WHERE id=?', { charId })
    local jobs   = json.decode((jRow and jRow[1] and jRow[1].jobs) or '[]') or {}
    local found  = false
    for _, j in ipairs(jobs) do
        if j.id == job.id then j.grade = grade; found = true; break end
    end
    if not found then jobs[#jobs+1] = { id = job.id, grade = grade } end
    MySQL.query.await('UPDATE characters SET jobs=? WHERE id=?', { json.encode(jobs), charId })

    print(string.format(
        '[testembauche] OK — %s %s embauché(e) en "%s" grade %d, salaire %d$ (contrat #%d)',
        char.firstname, char.lastname, jobName, grade, salary, contractId
    ))

    -- Synchro live si le joueur est connecté
    for _, s in ipairs(GetPlayers()) do
        local sn = tonumber(s)
        local d  = activeChars[sn]
        if d and d.charId == charId then
            -- Mettre à jour activeChars
            local found = false
            for _, j in ipairs(d.jobs) do
                if j.id == job.id then j.grade = grade; found = true; break end
            end
            if not found then d.jobs[#d.jobs+1] = { id = job.id, grade = grade } end

            TriggerClientEvent('epsilon:jobs:data', sn, {
                jobs    = d.jobs,
                jobDefs = getPublicJobDefs(),
                missions = getPublicMissions(),
            })
            print('[testembauche] Synchro live envoyée → src=' .. sn)
            break
        end
    end
end, true)
