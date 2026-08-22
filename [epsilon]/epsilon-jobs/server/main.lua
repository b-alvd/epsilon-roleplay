-- ════════════════════════════════════════════════════════════════
--  epsilon-jobs / server/main.lua
-- ════════════════════════════════════════════════════════════════

local SALARY_CYCLE = 30 * 60 * 1000   -- 30 minutes
local MAX_JOBS     = 3                 -- max jobs FIXES par personnage

-- ── Caches mémoire ───────────────────────────────────────────────────────────
--
--  jobsDefs     [name|id] = job row         (fixe + etat)
--  gradesDefs   [jobId][grade] = gradeInfo
--  missionsDefs [name|id] = mission row
--  missionActs  [missionId][actionName] = action row
--  sessionIds   [charId_jobId] = sessionId  (jobs fixes uniquement)
--  activeChars  [src] = { charId, jobs, missionCooldowns, sessionEarned }

jobsDefs     = {}
gradesDefs   = {}
missionsDefs = {}
missionActs  = {}
sessionIds   = {}
activeChars  = {}

-- ── Chargement des définitions ────────────────────────────────────────────────

local function loadDefs()
    -- Jobs fixes + état
    local jobs = MySQL.query.await('SELECT * FROM jobs WHERE is_active=1')
    jobsDefs = {}
    for _, j in ipairs(jobs or {}) do
        j.aide_montant = tonumber(j.aide_montant) or 0
        j.max_slots    = j.max_slots and tonumber(j.max_slots) or nil
        jobsDefs[j.name] = j
        jobsDefs[j.id]   = j
    end

    -- Grades (salaire par échelon)
    local grades = MySQL.query.await('SELECT * FROM job_grades ORDER BY job_id, grade')
    gradesDefs = {}
    for _, g in ipairs(grades or {}) do
        if not gradesDefs[g.job_id] then gradesDefs[g.job_id] = {} end
        gradesDefs[g.job_id][g.grade] = { label = g.label, salary = tonumber(g.salary) or 0 }
    end

    -- Missions intérim
    local missions = MySQL.query.await('SELECT * FROM missions WHERE is_active=1')
    missionsDefs = {}
    for _, m in ipairs(missions or {}) do
        missionsDefs[m.name] = m
        missionsDefs[m.id]   = m
    end

    -- Actions par mission
    local actions = MySQL.query.await('SELECT * FROM mission_actions')
    missionActs = {}
    for _, a in ipairs(actions or {}) do
        if not missionActs[a.mission_id] then missionActs[a.mission_id] = {} end
        missionActs[a.mission_id][a.name] = a
    end

    Epsilon.Debug.Info('[jobs] %d jobs, %d grades, %d missions chargés',
        #(jobs or {}), #(grades or {}), #(missions or {}))
end

-- ── Helpers DB ────────────────────────────────────────────────────────────────

local function readCharJobs(charId)
    local rows = MySQL.query.await('SELECT jobs FROM characters WHERE id=?', { charId })
    if not rows or not rows[1] then return {} end
    return json.decode(rows[1].jobs or '[]') or {}
end

local function writeCharJobs(charId, jobs)
    MySQL.update('UPDATE characters SET jobs=? WHERE id=?', { json.encode(jobs), charId })
end

local function openSession(charId, jobId)
    local key = charId .. '_' .. jobId
    if sessionIds[key] then return end
    sessionIds[key] = MySQL.insert.await(
        'INSERT INTO job_sessions (character_id, job_id) VALUES (?,?)',
        { charId, jobId }
    )
end

local function closeSession(charId, jobId)
    local key = charId .. '_' .. jobId
    local sid = sessionIds[key]
    if not sid then return end
    MySQL.update(
        'UPDATE job_sessions SET ended_at=NOW(), is_active=0 WHERE id=?',
        { sid }
    )
    sessionIds[key] = nil
end

local function logEarning(charId, sourceName, actionName, amount, payType)
    MySQL.insert(
        'INSERT INTO earnings_log (character_id, source_name, action_name, amount, pay_type) VALUES (?,?,?,?,?)',
        { charId, sourceName, actionName, amount, payType }
    )
end

-- ── Paiement ─────────────────────────────────────────────────────────────────

function pay(src, charId, amount, label, sourceName, actionName, payType)
    local ok, err = exports['epsilon-economy']:AddMoney(charId, amount, label, payType)
    if not ok then
        Epsilon.Debug.Warn('[jobs] Paiement échoué char %d: %s', charId, tostring(err))
        return false
    end
    logEarning(charId, sourceName, actionName, amount, payType)
    TriggerClientEvent('epsilon:jobs:paid', src, {
        amount   = amount,
        label    = label,
        pay_type = payType,
    })
    TriggerEvent('epsilon:log', {
        type      = 'jobs',
        source_id = src,
        action    = 'pay_' .. payType,
        details   = string.format('%s +%d$ (%s)', sourceName, amount, payType),
        metadata  = { charId=charId, source=sourceName, action=actionName, amount=amount },
    })
    return true
end

-- ── Cycle salaires + aide de l'État ──────────────────────────────────────────

local function runSalaryCycle()
    Epsilon.Debug.Info('[jobs] Cycle salaires/aide')
    for src, data in pairs(activeChars) do
        local charId  = data.charId
        local hasFixe = false

        for _, j in ipairs(data.jobs) do
            local def = jobsDefs[j.id]
            if def and def.type == 'fixe' then
                hasFixe = true
                local gradeInfo  = gradesDefs[def.id] and gradesDefs[def.id][j.grade or 0]
                local salary     = gradeInfo and gradeInfo.salary or 0
                local gradeLabel = gradeInfo and gradeInfo.label or ('Grade ' .. (j.grade or 0))
                if salary > 0 then
                    pay(src, charId, salary,
                        string.format('Salaire — %s (%s)', def.label, gradeLabel),
                        def.name, nil, 'salary')
                    data.sessionEarned[def.id] = (data.sessionEarned[def.id] or 0) + salary
                end
            end
        end

        if not hasFixe then
            local aideDef = jobsDefs['chomeur']
            if aideDef and aideDef.aide_montant > 0 then
                pay(src, charId, aideDef.aide_montant,
                    "Aide de l'Etat", 'chomeur', nil, 'aide')
            end
        end
    end
end

CreateThread(function()
    Wait(8000)
    loadDefs()
    while true do
        Wait(SALARY_CYCLE)
        runSalaryCycle()
    end
end)

-- ── Spawn / disconnect ────────────────────────────────────────────────────────

RegisterNetEvent('epsilon:jobs:init', function(charId)
    local src  = source
    local jobs = readCharJobs(charId)
    activeChars[src] = {
        charId            = charId,
        jobs              = jobs,
        missionCooldowns  = {},
        sessionEarned     = {},
    }
    for _, j in ipairs(jobs) do
        if jobsDefs[j.id] then
            openSession(charId, j.id)
            activeChars[src].sessionEarned[j.id] = 0
        end
    end
    TriggerClientEvent('epsilon:jobs:data', src, {
        jobs     = jobs,
        jobDefs  = getPublicJobDefs(),
        missions = getPublicMissions(),
    })
end)

-- Re-sync quand epsilon-jobs redémarre en cours de partie
RegisterNetEvent('epsilon:jobs:clientReady', function()
    local src = source

    -- Si le cache serveur est encore là, on renvoie directement
    local data = activeChars[src]
    if data then
        TriggerClientEvent('epsilon:jobs:data', src, {
            jobs     = data.jobs,
            jobDefs  = getPublicJobDefs(),
            missions = getPublicMissions(),
        })
        return
    end

    -- Sinon on relit depuis epsilon-characters + DB
    -- Attendre que loadDefs() soit terminé (max 3s)
    local waited = 0
    while not next(jobsDefs) and waited < 3000 do Wait(200); waited = waited + 200 end

    local charId = exports['epsilon-characters']:GetCharIdBySrc(src)
    if not charId then return end

    local jobs = readCharJobs(charId)
    activeChars[src] = {
        charId           = charId,
        jobs             = jobs,
        missionCooldowns = {},
        sessionEarned    = {},
    }
    for _, j in ipairs(jobs) do
        if jobsDefs[j.id] then
            openSession(charId, j.id)
            activeChars[src].sessionEarned[j.id] = 0
        end
    end

    TriggerClientEvent('epsilon:jobs:data', src, {
        jobs     = jobs,
        jobDefs  = getPublicJobDefs(),
        missions = getPublicMissions(),
    })

    Epsilon.Debug.Info('[jobs] clientReady re-sync: src=%d charId=%d jobs=%d', src, charId, #jobs)
end)

AddEventHandler('playerDropped', function()
    local src  = tonumber(source)
    local data = activeChars[src]
    if not data then return end
    for _, j in ipairs(data.jobs) do
        closeSession(data.charId, j.id)
    end
    activeChars[src] = nil
end)

-- ── Defs publiques ────────────────────────────────────────────────────────────

function getPublicJobDefs()
    local out, seen = {}, {}
    for _, j in pairs(jobsDefs) do
        if not seen[j.id] then
            seen[j.id] = true
            local grades = {}
            for grade, info in pairs(gradesDefs[j.id] or {}) do
                grades[#grades+1] = { grade=grade, label=info.label, salary=info.salary }
            end
            table.sort(grades, function(a, b) return a.grade < b.grade end)
            out[#out+1] = {
                id           = j.id,
                name         = j.name,
                label        = j.label,
                type         = j.type,
                description  = j.description,
                color        = j.color,
                max_slots    = j.max_slots,
                aide_montant = j.aide_montant,
                grades       = grades,
            }
        end
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

function getPublicMissions()
    local out, seen = {}, {}
    for _, m in pairs(missionsDefs) do
        if not seen[m.id] then
            seen[m.id] = true
            local acts = {}
            for _, a in pairs(missionActs[m.id] or {}) do
                acts[#acts+1] = { name=a.name, label=a.label }
            end
            table.sort(acts, function(a, b) return a.name < b.name end)
            out[#out+1] = {
                id          = m.id,
                name        = m.name,
                label       = m.label,
                description = m.description,
                color       = m.color,
                actions     = acts,
            }
        end
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

-- ── Exports jobs fixes ────────────────────────────────────────────────────────

exports('GetJobs', function(charId)
    for _, data in pairs(activeChars) do
        if data.charId == charId then return data.jobs end
    end
    return readCharJobs(charId)
end)

exports('HasJob', function(charId, jobName)
    for _, data in pairs(activeChars) do
        if data.charId == charId then
            for _, j in ipairs(data.jobs) do
                if j.name == jobName then return true end
            end
            return false
        end
    end
    local jobs = readCharJobs(charId)
    for _, j in ipairs(jobs) do
        if j.name == jobName then return true end
    end
    return false
end)

exports('GetJobDef',   function(jobName) return jobsDefs[jobName] end)
exports('GetAllDefs',  function() return getPublicJobDefs() end)
exports('GetMissions', function() return getPublicMissions() end)

exports('AddJob', function(targetSrc, charId, jobName, grade)
    local src  = tonumber(targetSrc)
    local data = activeChars[src]
    if not data or data.charId ~= charId then return false, 'Personnage non actif' end

    local def = jobsDefs[jobName]
    if not def              then return false, 'Job introuvable: ' .. tostring(jobName) end
    if def.type ~= 'fixe'  then return false, 'Seuls les jobs fixes sont assignables' end

    if #data.jobs >= MAX_JOBS then
        return false, 'Maximum ' .. MAX_JOBS .. ' jobs atteint'
    end
    for _, j in ipairs(data.jobs) do
        if j.id == def.id then return false, 'Job deja assigne' end
    end

    if def.max_slots then
        local count = tonumber(MySQL.scalar.await(
            "SELECT COUNT(*) FROM characters WHERE JSON_CONTAINS(jobs, JSON_OBJECT('id', ?))",
            { def.id }
        ) or 0)
        if count >= def.max_slots then
            return false, 'Plus de place (' .. def.max_slots .. ' max)'
        end
    end

    local entry = { id=def.id, name=def.name, grade=grade or 0, hired_at=os.date('!%Y-%m-%dT%H:%M:%SZ') }
    table.insert(data.jobs, entry)
    writeCharJobs(charId, data.jobs)
    openSession(charId, def.id)
    data.sessionEarned[def.id] = 0

    TriggerClientEvent('epsilon:jobs:update', src, { jobs = data.jobs })
    TriggerEvent('epsilon:log', {
        type='jobs', source_id=src, action='hire',
        details='Embauche: ' .. def.label,
        metadata={ charId=charId, jobId=def.id, jobName=def.name, grade=grade or 0 },
    })
    return true
end)

exports('RemoveJob', function(targetSrc, charId, jobName)
    local src  = tonumber(targetSrc)
    local data = activeChars[src]
    if not data or data.charId ~= charId then return false, 'Personnage non actif' end

    local def = jobsDefs[jobName]
    if not def then return false, 'Job introuvable' end

    local found = false
    for i, j in ipairs(data.jobs) do
        if j.id == def.id then table.remove(data.jobs, i); found = true; break end
    end
    if not found then return false, 'Job non assigne' end

    closeSession(charId, def.id)
    data.sessionEarned[def.id] = nil
    writeCharJobs(charId, data.jobs)

    TriggerClientEvent('epsilon:jobs:update', src, { jobs = data.jobs })
    TriggerEvent('epsilon:log', {
        type='jobs', source_id=src, action='fire',
        details='Depart: ' .. def.label,
        metadata={ charId=charId, jobId=def.id, jobName=def.name },
    })
    return true
end)

exports('SetGrade', function(targetSrc, charId, jobName, newGrade)
    local src  = tonumber(targetSrc)
    local data = activeChars[src]
    if not data or data.charId ~= charId then return false, 'Personnage non actif' end

    local def = jobsDefs[jobName]
    if not def             then return false, 'Job introuvable' end
    if def.type ~= 'fixe' then return false, 'Pas de grade sur ce type de job' end

    local gradeInfo = gradesDefs[def.id] and gradesDefs[def.id][newGrade]
    if not gradeInfo then return false, 'Grade ' .. newGrade .. ' inexistant' end

    for _, j in ipairs(data.jobs) do
        if j.id == def.id then
            local old = j.grade
            j.grade = newGrade
            writeCharJobs(charId, data.jobs)
            TriggerClientEvent('epsilon:jobs:update', src, { jobs = data.jobs })
            TriggerEvent('epsilon:log', {
                type='jobs', source_id=src, action='grade_change',
                details=string.format('%s: grade %d -> %d (%s)', def.label, old, newGrade, gradeInfo.label),
                metadata={ charId=charId, jobId=def.id, jobName=def.name, oldGrade=old, newGrade=newGrade },
            })
            return true, gradeInfo
        end
    end
    return false, 'Job non assigne'
end)

exports('GetGrades', function(jobName)
    local def = jobsDefs[jobName]
    if not def then return {} end
    local out = {}
    for grade, info in pairs(gradesDefs[def.id] or {}) do
        out[#out+1] = { grade=grade, label=info.label, salary=info.salary }
    end
    table.sort(out, function(a, b) return a.grade < b.grade end)
    return out
end)

-- ── Export missions intérim ───────────────────────────────────────────────────
-- Pas d'assignation nécessaire : n'importe quel joueur connecté peut enregistrer
-- une action de mission. La ressource responsable (ex: epsilon-mission-eboueur)
-- vérifie les conditions in-game (proximité, item, etc.) avant d'appeler cet export.

-- pay      : montant en $ versé au joueur (défini par la resource appelante)
-- cooldown : délai en secondes avant de pouvoir réeffectuer cette action (0 = aucun)
exports('RecordMissionAction', function(targetSrc, charId, missionName, actionName, pay_amount, cooldown_secs)
    local src  = tonumber(targetSrc)
    local data = activeChars[src]
    if not data or data.charId ~= charId then return false, 0, 'Personnage non actif' end

    local mission = missionsDefs[missionName]
    if not mission then return false, 0, 'Mission inconnue: ' .. tostring(missionName) end

    local action = missionActs[mission.id] and missionActs[mission.id][actionName]
    if not action then return false, 0, 'Action inconnue: ' .. tostring(actionName) end

    local amount   = tonumber(pay_amount)     or 0
    local cooldown = tonumber(cooldown_secs)  or 0

    -- Cooldown par joueur × mission × action
    if cooldown > 0 then
        local cdKey  = mission.id .. '_' .. actionName
        local now    = GetGameTimer()
        local lastAt = data.missionCooldowns[cdKey] or 0
        if now - lastAt < cooldown * 1000 then
            local rem = math.ceil((cooldown * 1000 - (now - lastAt)) / 1000)
            return false, 0, 'Cooldown: ' .. rem .. 's'
        end
        data.missionCooldowns[cdKey] = now
    end

    pay(src, charId, amount,
        action.label .. ' — ' .. mission.label,
        mission.name, actionName, 'mission')

    return true, amount
end)

exports('GetEarningsToday', function(charId)
    local rows = MySQL.query.await([[
        SELECT pay_type, SUM(amount) AS total, COUNT(*) AS cnt
        FROM earnings_log
        WHERE character_id=? AND DATE(created_at)=CURDATE()
        GROUP BY pay_type
    ]], { charId })
    local result = { total=0, byType={} }
    for _, r in ipairs(rows or {}) do
        result.byType[r.pay_type] = { total=tonumber(r.total), count=r.cnt }
        result.total = result.total + tonumber(r.total)
    end
    return result
end)

exports('GetCharIdBySrc', function(src)
    return activeChars[src] and activeChars[src].charId or nil
end)

-- ── Panel admin ───────────────────────────────────────────────────────────────

local function isAdmin(src)
    return IsPlayerAceAllowed(tostring(src), 'epsilon.admin')
        or IsPlayerAceAllowed(tostring(src), 'epsilon.superadmin')
end

RegisterNetEvent('epsilon:jobs:admin:getData', function()
    local src = source
    if not isAdmin(src) then return end

    local statsDay = MySQL.query.await([[
        SELECT pay_type, SUM(amount) AS total, COUNT(*) AS cnt
        FROM earnings_log WHERE DATE(created_at)=CURDATE()
        GROUP BY pay_type
    ]])

    local perSource = MySQL.query.await([[
        SELECT source_name, pay_type, SUM(amount) AS total, COUNT(*) AS cnt
        FROM earnings_log WHERE DATE(created_at)=CURDATE()
        GROUP BY source_name, pay_type
        ORDER BY total DESC
    ]])

    local recentLog = MySQL.query.await([[
        SELECT el.id, el.character_id, el.source_name, el.action_name,
               el.amount, el.pay_type, el.created_at,
               c.firstname, c.lastname
        FROM earnings_log el
        LEFT JOIN characters c ON c.id = el.character_id
        ORDER BY el.created_at DESC
        LIMIT 100
    ]])

    local sessions = MySQL.query.await([[
        SELECT js.id, js.character_id, js.job_id, js.started_at,
               c.firstname, c.lastname,
               j.label AS job_label, j.name AS job_name, j.color
        FROM job_sessions js
        LEFT JOIN characters c ON c.id = js.character_id
        LEFT JOIN jobs        j ON j.id = js.job_id
        WHERE js.is_active=1
        ORDER BY js.started_at DESC
    ]])

    local roster = {}
    for s, data in pairs(activeChars) do
        local pName = GetPlayerName(s) or '?'
        for _, j in ipairs(data.jobs) do
            local def = jobsDefs[j.id]
            local gi  = gradesDefs[j.id] and gradesDefs[j.id][j.grade or 0]
            roster[#roster+1] = {
                src        = s,
                charId     = data.charId,
                player     = pName,
                jobName    = j.name,
                jobLabel   = def and def.label or j.name,
                jobColor   = def and def.color or '#fff',
                grade      = j.grade,
                gradeLabel = gi and gi.label or ('Grade ' .. (j.grade or 0)),
                salary     = gi and gi.salary or 0,
                hiredAt    = j.hired_at,
                earned     = data.sessionEarned[j.id] or 0,
            }
        end
    end

    TriggerClientEvent('epsilon:jobs:admin:dataResult', src, {
        statsDay   = statsDay   or {},
        perSource  = perSource  or {},
        recentLog  = recentLog  or {},
        sessions   = sessions   or {},
        roster     = roster,
        jobDefs    = getPublicJobDefs(),
        missions   = getPublicMissions(),
    })
end)

RegisterNetEvent('epsilon:jobs:admin:hire', function(data)
    local src = source
    if not isAdmin(src) then return end
    local ok, err = exports['epsilon-jobs']:AddJob(data.targetSrc, data.charId, data.jobName, data.grade)
    TriggerClientEvent('epsilon:jobs:admin:result', src, { action='hire', ok=ok, err=err })
end)

RegisterNetEvent('epsilon:jobs:admin:fire', function(data)
    local src = source
    if not isAdmin(src) then return end
    local ok, err = exports['epsilon-jobs']:RemoveJob(data.targetSrc, data.charId, data.jobName)
    TriggerClientEvent('epsilon:jobs:admin:result', src, { action='fire', ok=ok, err=err })
end)

RegisterNetEvent('epsilon:jobs:admin:setGrade', function(data)
    local src = source
    if not isAdmin(src) then return end
    local ok, res = exports['epsilon-jobs']:SetGrade(data.targetSrc, data.charId, data.jobName, data.grade)
    TriggerClientEvent('epsilon:jobs:admin:result', src, { action='grade', ok=ok, err=not ok and res or nil, grade=ok and res or nil })
end)

RegisterNetEvent('epsilon:jobs:admin:reloadDefs', function()
    if not isAdmin(source) then return end
    loadDefs()
    TriggerClientEvent('epsilon:jobs:admin:result', source, { action='reload', ok=true })
end)
