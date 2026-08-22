-- État partagé entre tous les fichiers client
_G.IS = {
    STATE               = 'IDLE',
    activeMission       = nil,
    run                 = {},
    runStep             = 0,
    runEarned           = 0.0,
    spawnedVeh          = nil,
    startBlips          = {},
    localCharId         = nil,

    -- Eboueur
    garbageBagProp      = nil,
    garbageBagCarryDict = nil,
    collectedCount      = 0,
    dumpedCount         = 0,

    -- Navigation / cibles
    targetBlip          = nil,
    targetProp          = nil,
    missionBins         = {},
    navBlip             = nil,

    -- Livreur
    newspaperProp       = nil,
    parcelCarryDict     = nil,
    livreurLoaded       = false,
    nearTruck           = false,

    -- Général
    runStopTarget       = 0,
    activeQuartierLabel = '',
    arrivedAtQuartier   = false,
    helpNotifShown      = {},
}
