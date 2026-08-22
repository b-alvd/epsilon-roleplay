-- ══════════════════════════════════════════════════════════════════
--  CONFIG S'ASSEOIR SUR LES PROPS
--  Modifie ce fichier pour ajuster les placements et les poses.
-- ══════════════════════════════════════════════════════════════════

-- ── POSES DISPONIBLES ──────────────────────────────────────────────
--
--  Les joueurs peuvent cycler entre ces poses avec ← et →.
--
--  Chaque pose peut avoir :
--    label    : nom affiché à l'écran (obligatoire)
--    type     : 'scenario' ou 'anim' (obligatoire)
--    name     : nom du scénario       (si type = 'scenario')
--    dict     : dictionnaire d'anim   (si type = 'anim')
--    name     : nom de l'animation    (si type = 'anim')
--
--  Offsets GLOBAUX (optionnels) — appliqués sur tous les props :
--    x = 0.0   gauche (négatif) / droite (positif)
--    y = 0.0   avant (négatif)  / arrière (positif)
--    z = 0.0   bas (négatif)    / haut (positif)
--
--  Offsets PAR PROP (optionnels) — surchargent les offsets globaux :
--    props = {
--        ['nom_du_prop'] = { x = 0.0, y = 0.0, z = 0.0 },
--    }
--

SIT_POSES = {
    {
        label = 'sitchair',
        type  = 'scenario',
        name  = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER',
        props = {
            ['prop_bench_02'] = { x = 0.23, z = 0.05 },
            ['prop_bench_05'] = { x = 0.28 },
        },
    },
    {
        label = 'sitkylie',
        type  = 'anim',
        dict  = 'sitkylie@queensisters',
        name  = 'kylie_clip',
        props = {
            ['prop_bench_02'] = { x = -0.09, z = -0.30 },
            ['prop_bench_05'] = { x = -0.35 },
        },
    },
    {
        label = 'sitchair4',
        type  = 'anim',
        dict  = 'timetable@ron@ig_3_couch',
        name  = 'base',
        props = {
            ['prop_bench_02'] = { x = -0.25, z = -0.01 },
            ['prop_bench_05'] = { x = -0.35, z = 0.15 },
        },
    },
    {
        label = 'sitchair3',
        type  = 'anim',
        dict  = 'timetable@reunited@ig_10',
        name  = 'base_amanda',
        props = {
            -- ['prop_bench_02']
            ['prop_bench_05'] = { x = -0.55 },
        },
    },
    {
        label = 'sitchair2',
        type  = 'anim',
        dict  = 'timetable@ron@ig_5_p3',
        name  = 'ig_5_p3_base',
        props = {
            ['prop_bench_02'] = { x = -0.50 },
            ['prop_bench_05'] = { x = -0.45 },
        },
    },
    {
        label = 'nekositchair10',
        type  = 'anim',
        dict  = 'misslester1aig_3main',
        name  = 'air_guitar_01_b',
        props = {
            ['prop_bench_02'] = { x = 0.10, z = 0.15 },
            ['prop_bench_05'] = { x = 0.00, z = 0.15 },
        },
    },
    {
        label = 'nekositpost4',
        type  = 'anim',
        dict  = 'anim@heists@fleeca_bank@hostages@intro',
        name  = 'intro_loop_ped_a',
        props = {
            ['prop_bench_02'] = { x = -0.15, z = -0.10 },
            ['prop_bench_05'] = { x = -0.30 },
        },
    },
    {
        label = 'nekositpost3',
        type  = 'anim',
        dict  = 'timetable@reunited@ig_10',
        name  = 'base_jimmy',
        props = {
            ['prop_bench_02'] = { x = -0.60, z = -0.45 },
            ['prop_bench_05'] = { x = -0.60, z = -0.45 },
        },
    },
}


-- ── PROPS AVEC PLUSIEURS PLACES ────────────────────────────────────
--
--  Props où plusieurs joueurs peuvent s'asseoir côte à côte.
--
--    count      : nombre de places
--    spacing    : écart en mètres entre chaque place (axe gauche/droite)
--    seatHeight : hauteur de l'assise au-dessus de l'origine du prop
--    yOff       : décalage avant/arrière du ped sur l'assise
--                 (négatif = vers l'avant, positif = vers le dossier)
--
SIT_MULTISEAT = {
    ['prop_bench_01'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_02'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_03'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_04'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_05'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_06'] = { count = 3, spacing = 0.48, seatHeight = 0.45, yOff = -0.20 },
    ['prop_bench_09'] = { count = 3, spacing = 0.55, seatHeight = 0.45, yOff = -0.20 },
    ['prop_couch_lg_1'] = { count = 3, spacing = 0.55, seatHeight = 0.40, yOff = -0.05 },
    ['prop_couch_01']   = { count = 2, spacing = 0.50, seatHeight = 0.40, yOff = -0.05 },
    ['prop_couch_02']   = { count = 2, spacing = 0.50, seatHeight = 0.40, yOff = -0.05 },
    ['prop_couch_03']   = { count = 2, spacing = 0.50, seatHeight = 0.40, yOff = -0.05 },
}


-- ── PROPS SUR LESQUELS ON PEUT S'ALLONGER ─────────────────────────
--
--  Animation utilisée pour s'allonger :
--    dict : dictionnaire de l'animation
--    name : nom de l'animation
--
--  Position du ped sur le prop :
--    yOff : décalage avant/arrière (négatif = vers l'avant du banc)
--    z    : hauteur au-dessus de l'origine du prop
--
SIT_LAYDOWN = {
    anim = { dict = 'timetable@ron@ig_3_p3', name = 'ig_3_p3_base' },

    props = {
        ['prop_bench_01'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_02'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_03'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_04'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_05'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_06'] = { yOff = -0.60, z = 0.0 },
        ['prop_bench_09'] = { yOff = -0.60, z = 0.0 },
    },
}
