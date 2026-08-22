-- ════════════════════════════════════════════════════════════════
--  Epsilon Roleplay — Schéma complet
-- ════════════════════════════════════════════════════════════════

-- ── Joueurs ───────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `players` (
    `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    `license`        VARCHAR(64)   NOT NULL,
    `steam`          VARCHAR(64)   DEFAULT NULL,
    `discord`        VARCHAR(64)   DEFAULT NULL,
    `ip`             VARCHAR(45)   DEFAULT NULL,
    `name`           VARCHAR(255)  DEFAULT NULL,
    `first_join`     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_join`      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `total_playtime` INT UNSIGNED  NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_license` (`license`),
    KEY `idx_last_join` (`last_join`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Personnages ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `characters` (
    `id`          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `player_id`   INT UNSIGNED     NOT NULL,
    `slot`        TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `firstname`   VARCHAR(64)      NOT NULL,
    `lastname`    VARCHAR(64)      NOT NULL,
    `dob`         DATE             NOT NULL,
    `gender`      TINYINT(1)       NOT NULL DEFAULT 0,
    `skin`        LONGTEXT         DEFAULT NULL,
    `outfit`      LONGTEXT         DEFAULT NULL,
    `cash`        DECIMAL(10,2)    NOT NULL DEFAULT 500.00,
    `jobs`        JSON             NOT NULL DEFAULT (JSON_ARRAY()),
    `pos_x`       FLOAT            NOT NULL DEFAULT -1037.0,
    `pos_y`       FLOAT            NOT NULL DEFAULT -2738.0,
    `pos_z`       FLOAT            NOT NULL DEFAULT 20.17,
    `pos_heading` FLOAT            NOT NULL DEFAULT 0.0,
    `hunger`      FLOAT            NOT NULL DEFAULT 100,
    `thirst`      FLOAT            NOT NULL DEFAULT 100,
    `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_played` TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_player_slot` (`player_id`, `slot`),
    KEY `idx_player_id` (`player_id`),
    CONSTRAINT `fk_char_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Logs serveur ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `server_logs` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `type`        VARCHAR(64)     NOT NULL,
    `source_id`   INT             DEFAULT NULL,
    `source_name` VARCHAR(255)    DEFAULT NULL,
    `target_id`   INT             DEFAULT NULL,
    `target_name` VARCHAR(255)    DEFAULT NULL,
    `action`      VARCHAR(255)    NOT NULL,
    `details`     TEXT            DEFAULT NULL,
    `metadata`    JSON            DEFAULT NULL,
    `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_type`       (`type`),
    KEY `idx_source_id`  (`source_id`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Logs admin ────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `admin_logs` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `admin_id`    INT UNSIGNED    DEFAULT NULL,
    `admin_name`  VARCHAR(255)    DEFAULT NULL,
    `target_id`   INT UNSIGNED    DEFAULT NULL,
    `target_name` VARCHAR(255)    DEFAULT NULL,
    `action`      VARCHAR(128)    NOT NULL,
    `reason`      TEXT            DEFAULT NULL,
    `metadata`    JSON            DEFAULT NULL,
    `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_admin_id`   (`admin_id`),
    KEY `idx_target_id`  (`target_id`),
    KEY `idx_action`     (`action`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Sanctions ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `admin_sanctions` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `type`          ENUM('warn','kick','ban') NOT NULL,
    `identifier`    VARCHAR(64)  NOT NULL,
    `player_name`   VARCHAR(64)  NOT NULL DEFAULT '',
    `reason`        VARCHAR(512) NOT NULL DEFAULT 'Aucune raison',
    `sanctioned_by` VARCHAR(64)  NOT NULL DEFAULT 'Admin',
    `sanctioned_at` INT UNSIGNED NOT NULL DEFAULT 0,
    `duration`      INT UNSIGNED NOT NULL DEFAULT 0,
    `expires_at`    INT UNSIGNED NOT NULL DEFAULT 0,
    `active`        TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    INDEX `idx_identifier`  (`identifier`),
    INDEX `idx_type_active` (`type`, `active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Grades admin ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `admin_grades` (
    `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`           VARCHAR(64)  NOT NULL,
    `label`          VARCHAR(64)  NOT NULL,
    `color`          VARCHAR(16)  NOT NULL DEFAULT '#ffffff',
    `perm_players`   TINYINT(1)   NOT NULL DEFAULT 1,
    `perm_teleport`  TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_spectate`  TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_health`    TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_effects`   TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_vehicle`   TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_sanctions` TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_message`   TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_weather`   TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_announce`  TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_tools`     TINYINT(1)   NOT NULL DEFAULT 0,
    `perm_grades`    TINYINT(1)   NOT NULL DEFAULT 0,
    `sort_order`     INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `admin_grades`
    (`name`, `label`, `color`,
     `perm_players`, `perm_teleport`, `perm_spectate`,
     `perm_health`, `perm_effects`, `perm_vehicle`,
     `perm_sanctions`, `perm_message`, `perm_weather`,
     `perm_announce`, `perm_tools`, `perm_grades`, `sort_order`)
VALUES
    ('moderateur',     'Modérateur',    '#cee400', 1,0,1, 0,0,0, 1,1,0, 0,0,0, 10),
    ('administrateur', 'Administrateur','#e67e22', 1,1,1, 1,1,1, 1,1,0, 1,1,0, 20),
    ('responsable',    'Responsable',   '#801aeb', 1,1,1, 1,1,1, 1,1,1, 1,1,0, 30),
    ('fondateur',      'Fondateur',     '#020101', 1,1,1, 1,1,1, 1,1,1, 1,1,1, 99);

CREATE TABLE IF NOT EXISTS `admin_players` (
    `license`     VARCHAR(128) NOT NULL,
    `grade_id`    INT UNSIGNED NOT NULL,
    `assigned_by` VARCHAR(128) NOT NULL DEFAULT '',
    `assigned_at` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`license`),
    INDEX `idx_grade` (`grade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Reports ───────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `reports` (
    `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `type`             VARCHAR(32)  NOT NULL DEFAULT 'report',
    `player_id`        INT UNSIGNED NOT NULL,
    `player_name`      VARCHAR(128) NOT NULL DEFAULT '',
    `player_license`   VARCHAR(128) NULL DEFAULT NULL,
    `license`          VARCHAR(128) NOT NULL DEFAULT '',
    `category`         VARCHAR(32)  NOT NULL DEFAULT 'autre',
    `target_name`      VARCHAR(128) NOT NULL DEFAULT '',
    `description`      TEXT         NOT NULL,
    `status`           ENUM('open','in_progress','closed') NOT NULL DEFAULT 'open',
    `assigned_name`    VARCHAR(128) NULL DEFAULT NULL,
    `assigned_license` VARCHAR(128) NULL DEFAULT NULL,
    `assigned_at`      DATETIME     NULL DEFAULT NULL,
    `closed_by_name`   VARCHAR(128) NULL DEFAULT NULL,
    `closed_at`        DATETIME     NULL DEFAULT NULL,
    `collaborators`    TEXT         NULL DEFAULT NULL,
    `created_at`       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_status`  (`status`),
    INDEX `idx_license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Inventaire ────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `items` (
    `name`   VARCHAR(50)  NOT NULL,
    `label`  VARCHAR(100) NOT NULL,
    `weight` FLOAT        NOT NULL DEFAULT 1,
    `data`   LONGTEXT     NOT NULL,
    `image`  VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `player_items` (
    `id`           INT  NOT NULL AUTO_INCREMENT,
    `character_id` INT  NOT NULL,
    `name`         VARCHAR(50)  NOT NULL,
    `quantity`     DECIMAL(10,2)  NOT NULL DEFAULT 1.00,
    `slot`         INT  NOT NULL,
    `category`     ENUM('items','keys','weapons','clothing') NOT NULL DEFAULT 'items',
    `data`         LONGTEXT NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_char` (`character_id`),
    UNIQUE KEY `idx_char_cat_slot` (`character_id`, `category`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `player_hotbar` (
    `character_id` INT     NOT NULL,
    `slot`         TINYINT NOT NULL,
    `item_name`    VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (`character_id`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ground_items` (
    `id`       INT NOT NULL AUTO_INCREMENT,
    `name`     VARCHAR(50) NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `data`     LONGTEXT    NOT NULL,
    `x`        FLOAT       NOT NULL,
    `y`        FLOAT       NOT NULL,
    `z`        FLOAT       NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ── Items consommables ────────────────────────────────────────────────────────

INSERT INTO `items` (`name`, `label`, `weight`, `data`, `image`) VALUES
    ('sandwich', 'Sandwich',        0.20, '{"thirst":-2,"type":"consumable","hunger":30}', 'https://imgg.fr/r/1W4X1O5a.png'),
    ('water',    "Bouteille d'eau", 0.50, '{"type":"consumable","thirst":40}',             'https://imgg.fr/r/V7tQKJ48.png')
AS new_row ON DUPLICATE KEY UPDATE label = new_row.label, weight = new_row.weight, data = new_row.data;

-- ── Items armes ───────────────────────────────────────────────────────────────

INSERT INTO `items` (`name`, `label`, `weight`, `data`, `image`) VALUES
    -- Mêlée
    ('weapon_dagger',        'Dague',                   0.20, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_bat',           'Batte de baseball',        0.50, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_bottle',        'Bouteille cassée',         0.30, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_crowbar',       'Pied-de-biche',            1.00, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_flashlight',    'Lampe torche',             0.30, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_golfclub',      'Club de golf',             0.50, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_hammer',        'Marteau',                  0.80, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_hatchet',       'Hachette',                 0.60, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_knuckle',       'Poing américain',          0.10, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_knife',         'Couteau',                  0.15, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_machete',       'Machette',                 0.50, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_switchblade',   'Couteau à cran d''arrêt',  0.10, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_nightstick',    'Matraque',                 0.40, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_wrench',        'Clé à molette',            0.60, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_battleaxe',     'Hache de guerre',          1.50, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_poolcue',       'Queue de billard',         0.50, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_stone_hatchet', 'Hachette en pierre',       0.70, '{"type":"weapon","category":"melee"}', NULL),
    ('weapon_candycane',     'Canne en sucre',           0.20, '{"type":"weapon","category":"melee"}', NULL),
    -- Pistolets
    ('weapon_pistol',        'Pistolet',                 0.60, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":12}',  NULL),
    ('weapon_pistol_mk2',    'Pistolet Mk II',           0.70, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":12}',  NULL),
    ('weapon_combatpistol',  'Pistolet de combat',       0.70, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":12}',  NULL),
    ('weapon_stungun',       'Pistolet à impulsion',     0.40, '{"type":"weapon","category":"pistol","ammoType":"AMMO_STUNGUN","maxAmmo":1}',   NULL),
    ('weapon_pistol50',      'Pistolet .50',             1.10, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":9}',    NULL),
    ('weapon_snspistol',     'Pistolet SNS',             0.50, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_snspistol_mk2', 'Pistolet SNS Mk II',       0.50, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_heavypistol',   'Pistolet lourd',           0.90, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":18}',  NULL),
    ('weapon_vintagepistol', 'Pistolet vintage',         0.70, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":7}',    NULL),
    ('weapon_flaregun',      'Pistolet de détresse',     0.50, '{"type":"weapon","category":"pistol","ammoType":"AMMO_FLARE","maxAmmo":1}',     NULL),
    ('weapon_marksmanpistol','Pistolet de précision',    0.90, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":1}',    NULL),
    ('weapon_revolver',      'Revolver',                 1.00, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_revolver_mk2',  'Revolver Mk II',           1.00, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_doubleaction',  'Revolver double action',   1.00, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_ceramicpistol', 'Pistolet céramique',       0.50, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":7}',    NULL),
    ('weapon_navyrevolver',  'Revolver naval',           1.20, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":6}',    NULL),
    ('weapon_pistolxm3',     'Pistolet WM 29',           0.70, '{"type":"weapon","category":"pistol","ammoType":"AMMO_PISTOL","maxAmmo":12}',  NULL),
    -- Pistolets mitrailleurs
    ('weapon_microsmg',      'Micro-mitraillette',       1.50, '{"type":"weapon","category":"smg","ammoType":"AMMO_SMG","maxAmmo":16}',       NULL),
    ('weapon_smg',           'Mitraillette',             2.00, '{"type":"weapon","category":"smg","ammoType":"AMMO_SMG","maxAmmo":30}',       NULL),
    ('weapon_smg_mk2',       'Mitraillette Mk II',       2.00, '{"type":"weapon","category":"smg","ammoType":"AMMO_SMG","maxAmmo":30}',       NULL),
    ('weapon_assaultsmg',    'Mitraillette d''assaut',   2.50, '{"type":"weapon","category":"smg","ammoType":"AMMO_SMG","maxAmmo":30}',       NULL),
    ('weapon_combatpdw',     'PDW de combat',            2.00, '{"type":"weapon","category":"smg","ammoType":"AMMO_SMG","maxAmmo":30}',       NULL),
    ('weapon_machinepistol', 'Pistolet-mitrailleur',     1.20, '{"type":"weapon","category":"smg","ammoType":"AMMO_PISTOL","maxAmmo":12}',    NULL),
    ('weapon_minismg',       'Mini-mitraillette',        1.30, '{"type":"weapon","category":"smg","ammoType":"AMMO_PISTOL","maxAmmo":14}',    NULL),
    ('weapon_tecpistol',     'Pistolet Tec',             1.50, '{"type":"weapon","category":"smg","ammoType":"AMMO_PISTOL","maxAmmo":30}',    NULL),
    -- Fusils à pompe
    ('weapon_pumpshotgun',     'Fusil à pompe',           3.00, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":8}',   NULL),
    ('weapon_pumpshotgun_mk2', 'Fusil à pompe Mk II',     3.00, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":8}',   NULL),
    ('weapon_sawnoffshotgun',  'Fusil à canon scié',      2.50, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":2}',   NULL),
    ('weapon_assaultshotgun',  'Fusil d''assaut à pompe', 3.50, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":8}',   NULL),
    ('weapon_bullpupshotgun',  'Fusil bullpup',           3.00, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":7}',   NULL),
    ('weapon_heavyshotgun',    'Fusil lourd',             4.00, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":7}',   NULL),
    ('weapon_dbshotgun',       'Fusil à deux coups',      2.00, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":2}',   NULL),
    ('weapon_autoshotgun',     'Fusil automatique',       4.50, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":20}', NULL),
    ('weapon_combatshotgun',   'Fusil de combat',         3.50, '{"type":"weapon","category":"shotgun","ammoType":"AMMO_SHOTGUN","maxAmmo":10}', NULL),
    -- Fusils d'assaut
    ('weapon_assaultrifle',       'Fusil d''assaut',          3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_assaultrifle_mk2',   'Fusil d''assaut Mk II',    3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_carbinerifle',       'Carabine',                 3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_carbinerifle_mk2',   'Carabine Mk II',           3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_advancedrifle',      'Fusil avancé',             3.00, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_specialcarbine',     'Carabine spéciale',        3.00, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_specialcarbine_mk2', 'Carabine spéciale Mk II',  3.00, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_bullpuprifle',       'Fusil bullpup',            3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_bullpuprifle_mk2',   'Fusil bullpup Mk II',      3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":30}', NULL),
    ('weapon_compactrifle',       'Carabine compacte',        2.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":20}', NULL),
    ('weapon_militaryrifle',      'Fusil militaire',          3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":20}', NULL),
    ('weapon_heavyrifle',         'Fusil lourd',              4.00, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":20}', NULL),
    ('weapon_tacticalrifle',      'Fusil tactique',           3.50, '{"type":"weapon","category":"rifle","ammoType":"AMMO_RIFLE","maxAmmo":25}', NULL),
    -- Fusils mitrailleurs
    ('weapon_mg',           'Mitrailleuse',                  7.00, '{"type":"weapon","category":"mg","ammoType":"AMMO_MG","maxAmmo":54}',   NULL),
    ('weapon_combatmg',     'Mitrailleuse de combat',        7.50, '{"type":"weapon","category":"mg","ammoType":"AMMO_MG","maxAmmo":100}', NULL),
    ('weapon_combatmg_mk2', 'Mitrailleuse de combat Mk II',  7.50, '{"type":"weapon","category":"mg","ammoType":"AMMO_MG","maxAmmo":100}', NULL),
    ('weapon_gusenberg',    'Mitrailleuse Gusenberg',        8.00, '{"type":"weapon","category":"mg","ammoType":"AMMO_MG","maxAmmo":100}', NULL),
    -- Fusils de précision
    ('weapon_sniperrifle',       'Fusil de sniper',               5.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":10}', NULL),
    ('weapon_heavysniper',       'Sniper lourd',                  8.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":5}',  NULL),
    ('weapon_heavysniper_mk2',   'Sniper lourd Mk II',            8.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":5}',  NULL),
    ('weapon_marksmanrifle',     'Fusil de tireur d''élite',      4.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":8}',  NULL),
    ('weapon_marksmanrifle_mk2', 'Fusil de tireur d''élite Mk II',4.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":8}',  NULL),
    ('weapon_precisionrifle',    'Fusil de précision',            6.00, '{"type":"weapon","category":"sniper","ammoType":"AMMO_SNIPER","maxAmmo":6}',  NULL),
    ('weapon_musket',            'Mousquet',                      4.50, '{"type":"weapon","category":"sniper","ammoType":"AMMO_MUSKET","maxAmmo":1}',  NULL),
    -- Armes lourdes
    ('weapon_rpg',             'Lance-roquettes',                   7.00, '{"type":"weapon","category":"heavy","ammoType":"AMMO_RPG","maxAmmo":1}',              NULL),
    ('weapon_grenadelauncher', 'Lance-grenades',                    5.50, '{"type":"weapon","category":"heavy","ammoType":"AMMO_GRENADE_LAUNCHER","maxAmmo":1}', NULL),
    ('weapon_firework',        'Lance-feux d''artifice',            3.00, '{"type":"weapon","category":"heavy","ammoType":"AMMO_FIREWORK","maxAmmo":1}',         NULL),
    ('weapon_hominglauncher',  'Lance-missiles à tête chercheuse',  8.00, '{"type":"weapon","category":"heavy","ammoType":"AMMO_HOMING_LAUNCHER","maxAmmo":1}',  NULL),
    -- Armes à lancer
    ('weapon_grenade',    'Grenade',           0.40, '{"type":"weapon","category":"throwable","ammoType":"AMMO_GRENADE","maxAmmo":1}',    NULL),
    ('weapon_molotov',    'Cocktail Molotov',  0.50, '{"type":"weapon","category":"throwable","ammoType":"AMMO_MOLOTOV","maxAmmo":1}',    NULL),
    ('weapon_bzgas',      'Gaz BZ',            0.30, '{"type":"weapon","category":"throwable","ammoType":"AMMO_BZGAS","maxAmmo":1}',      NULL),
    ('weapon_stickybomb', 'Bombe collante',    0.40, '{"type":"weapon","category":"throwable","ammoType":"AMMO_STICKYBOMB","maxAmmo":1}', NULL),
    ('weapon_proxmine',   'Mine de proximité', 0.50, '{"type":"weapon","category":"throwable","ammoType":"AMMO_PROXMINE","maxAmmo":1}',   NULL),
    ('weapon_snowball',   'Boule de neige',    0.05, '{"type":"weapon","category":"throwable","ammoType":"AMMO_SNOWBALL","maxAmmo":1}',   NULL),
    ('weapon_pipebomb',   'Bombe artisanale',  0.40, '{"type":"weapon","category":"throwable","ammoType":"AMMO_PIPEBOMB","maxAmmo":1}',   NULL),
    ('weapon_ball',       'Balle de tennis',   0.05, '{"type":"weapon","category":"throwable","ammoType":"AMMO_BALL","maxAmmo":1}',       NULL),
    ('weapon_flare',      'Fusée éclairante',  0.10, '{"type":"weapon","category":"throwable","ammoType":"AMMO_FLARE","maxAmmo":1}',      NULL)
AS new_row ON DUPLICATE KEY UPDATE label = new_row.label, weight = new_row.weight, data = new_row.data;

-- ── Munitions ─────────────────────────────────────────────────────────────────

INSERT INTO `items` (`name`, `label`, `weight`, `data`, `image`) VALUES
    ('ammo_pistol',           'Munitions pistolet',          0.05, '{"type":"ammo","ammoType":"AMMO_PISTOL","amount":12}',           NULL),
    ('ammo_smg',              'Munitions mitraillette',      0.10, '{"type":"ammo","ammoType":"AMMO_SMG","amount":30}',              NULL),
    ('ammo_rifle',            'Munitions fusil d''assaut',   0.15, '{"type":"ammo","ammoType":"AMMO_RIFLE","amount":30}',            NULL),
    ('ammo_shotgun',          'Munitions fusil à pompe',     0.10, '{"type":"ammo","ammoType":"AMMO_SHOTGUN","amount":8}',           NULL),
    ('ammo_sniper',           'Munitions sniper',            0.20, '{"type":"ammo","ammoType":"AMMO_SNIPER","amount":5}',            NULL),
    ('ammo_mg',               'Munitions mitrailleuse',      0.50, '{"type":"ammo","ammoType":"AMMO_MG","amount":100}',              NULL),
    ('ammo_musket',           'Poudre et balle',             0.05, '{"type":"ammo","ammoType":"AMMO_MUSKET","amount":1}',            NULL),
    ('ammo_stungun',          'Chargeur taser',              0.02, '{"type":"ammo","ammoType":"AMMO_STUNGUN","amount":1}',           NULL),
    ('ammo_flare',            'Fusée de détresse',           0.05, '{"type":"ammo","ammoType":"AMMO_FLARE","amount":1}',             NULL),
    ('ammo_rpg',              'Roquette RPG',                2.00, '{"type":"ammo","ammoType":"AMMO_RPG","amount":1}',               NULL),
    ('ammo_grenade_launcher', 'Grenade lance-grenades',      0.30, '{"type":"ammo","ammoType":"AMMO_GRENADE_LAUNCHER","amount":1}',  NULL),
    ('ammo_firework',         'Fusée d''artifice',           0.20, '{"type":"ammo","ammoType":"AMMO_FIREWORK","amount":1}',          NULL),
    ('ammo_homing_launcher',  'Missile à tête chercheuse',   2.00, '{"type":"ammo","ammoType":"AMMO_HOMING_LAUNCHER","amount":1}',   NULL)
AS new_row ON DUPLICATE KEY UPDATE label = new_row.label, weight = new_row.weight, data = new_row.data;

-- ── Économie ──────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `bank_accounts` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED    NOT NULL,
    `iban`         VARCHAR(30)     NULL,
    `balance`      DECIMAL(14,2)   NOT NULL DEFAULT 0.00,
    `savings`      DECIMAL(14,2)   NOT NULL DEFAULT 0.00,
    `credit_score` SMALLINT        NOT NULL DEFAULT 500,
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_char` (`character_id`),
    UNIQUE KEY `uk_iban` (`iban`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `savings_placements` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED    NOT NULL,
    `profile`      ENUM('secure','mixed','aggressive') NOT NULL DEFAULT 'secure',
    `amount`       DECIMAL(14,2)   NOT NULL,
    `deposited_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_tick_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_char` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `savings_ticks` (
    `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `profile`    ENUM('secure','mixed','aggressive') NOT NULL,
    `rate`       DECIMAL(8,5)    NOT NULL,
    `ticked_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `from_account` BIGINT UNSIGNED NULL,
    `to_account`   BIGINT UNSIGNED NULL,
    `amount`       DECIMAL(14,2)   NOT NULL,
    `type`         VARCHAR(32)     NOT NULL DEFAULT 'transfer',
    `label`        VARCHAR(255)    NOT NULL DEFAULT '',
    `metadata`     JSON            NULL,
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_from`    (`from_account`),
    KEY `idx_to`      (`to_account`),
    KEY `idx_type`    (`type`),
    KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `economy_markets` (
    `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    `name`            VARCHAR(64)   NOT NULL,
    `label`           VARCHAR(128)  NOT NULL,
    `icon`            VARCHAR(64)   NOT NULL DEFAULT 'bi-graph-up',
    `base_price`      DECIMAL(12,2) NOT NULL,
    `current_price`   DECIMAL(12,2) NOT NULL,
    `supply`          DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    `demand`          DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    `sensitivity`     DECIMAL(5,3)  NOT NULL DEFAULT 0.400,
    `min_multiplier`  DECIMAL(5,3)  NOT NULL DEFAULT 0.400,
    `max_multiplier`  DECIMAL(5,3)  NOT NULL DEFAULT 3.000,
    `last_update`     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `economy_price_history` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `market_id`   INT UNSIGNED    NOT NULL,
    `price`       DECIMAL(12,2)   NOT NULL,
    `supply`      DECIMAL(10,2)   NOT NULL,
    `demand`      DECIMAL(10,2)   NOT NULL,
    `recorded_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_market_time` (`market_id`, `recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `economy_markets` (`name`, `label`, `icon`, `base_price`, `current_price`, `sensitivity`, `min_multiplier`, `max_multiplier`) VALUES
    ('fuel',        'Carburant',          'bi-fuel-pump-fill',  2.50,     2.50,    0.500, 0.400, 4.000),
    ('food',        'Alimentation',       'bi-basket2-fill',    10.00,    10.00,   0.300, 0.500, 2.500),
    ('materials',   'Matières premières', 'bi-boxes',           50.00,    50.00,   0.600, 0.300, 5.000),
    ('vehicles',    'Véhicules',          'bi-car-front-fill',  15000.00, 15000.00,0.350, 0.500, 2.000),
    ('real_estate', 'Immobilier',         'bi-house-fill',      80000.00, 80000.00,0.200, 0.600, 1.800);

-- ── Cartes bancaires ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `bank_cards` (
    `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED NOT NULL,
    `number`       VARCHAR(19)  NOT NULL,
    `cvv`          VARCHAR(3)   NOT NULL,
    `pin`          VARCHAR(4)   DEFAULT NULL,
    `tier`         VARCHAR(32)  NOT NULL DEFAULT 'classique',
    `expires`      DATE         NOT NULL,
    `created_at`   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_character` (`character_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── Jobs & Missions ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `jobs` (
    `id`           INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    `name`         VARCHAR(64)       NOT NULL,
    `label`        VARCHAR(128)      NOT NULL,
    `type`         ENUM('fixe','etat') NOT NULL DEFAULT 'fixe',
    `description`  TEXT              DEFAULT NULL,
    `color`        VARCHAR(16)       NOT NULL DEFAULT '#a78bfa',
    `max_slots`    SMALLINT UNSIGNED DEFAULT NULL,
    `aide_montant` DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
    `is_active`    TINYINT(1)        NOT NULL DEFAULT 1,
    `created_at`   TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `job_grades` (
    `id`     INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `job_id` INT UNSIGNED     NOT NULL,
    `grade`  TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `label`  VARCHAR(64)      NOT NULL,
    `salary` DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_job_grade` (`job_id`, `grade`),
    FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `job_sessions` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED    NOT NULL,
    `job_id`       INT UNSIGNED    NOT NULL,
    `started_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ended_at`     TIMESTAMP       DEFAULT NULL,
    `is_active`    TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `idx_char_active` (`character_id`, `is_active`),
    KEY `idx_started`     (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `earnings_log` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED    NOT NULL,
    `source_name`  VARCHAR(64)     NOT NULL,
    `action_name`  VARCHAR(64)     DEFAULT NULL,
    `amount`       DECIMAL(10,2)   NOT NULL,
    `pay_type`     ENUM('salary','aide','mission') NOT NULL,
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_char`    (`character_id`),
    KEY `idx_created` (`created_at`),
    KEY `idx_type`    (`pay_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `missions` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(64)  NOT NULL,
    `label`       VARCHAR(128) NOT NULL,
    `description` TEXT         DEFAULT NULL,
    `color`       VARCHAR(16)  NOT NULL DEFAULT '#94a3b8',
    `is_active`   TINYINT(1)   NOT NULL DEFAULT 1,
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mission_actions` (
    `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `mission_id` INT UNSIGNED NOT NULL,
    `name`       VARCHAR(64)  NOT NULL,
    `label`      VARCHAR(128) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_mission_action` (`mission_id`, `name`),
    FOREIGN KEY (`mission_id`) REFERENCES `missions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mission_sessions` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id`  INT UNSIGNED    NOT NULL,
    `mission_name`  VARCHAR(64)     NOT NULL,
    `started_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ended_at`      TIMESTAMP       DEFAULT NULL,
    `actions_count` INT UNSIGNED    NOT NULL DEFAULT 0,
    `total_earned`  DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    PRIMARY KEY (`id`),
    KEY `idx_char`    (`character_id`),
    KEY `idx_started` (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `jobs` (`name`, `label`, `type`, `description`, `color`, `max_slots`, `aide_montant`) VALUES
('chomeur', 'Chomeur',                 'etat', 'Aide de l''Etat versee toutes les 30 minutes.', '#94a3b8', NULL, 60),
('lspd',    'Los Santos Police Dept.', 'fixe', 'Police municipale de Los Santos.',              '#3b82f6', 40,   0),
('bcsd',    'Blaine County Sheriff',   'fixe', 'Sheriff du comte de Blaine.',                   '#b45309', 25,   0);

INSERT IGNORE INTO `job_grades` (`job_id`, `grade`, `label`, `salary`) VALUES
((SELECT id FROM jobs WHERE name='lspd'), 0, 'Cadet',           450),
((SELECT id FROM jobs WHERE name='lspd'), 1, 'Officer I',        600),
((SELECT id FROM jobs WHERE name='lspd'), 2, 'Officer II',       750),
((SELECT id FROM jobs WHERE name='lspd'), 3, 'Senior Officer',   900),
((SELECT id FROM jobs WHERE name='lspd'), 4, 'Detective',       1050),
((SELECT id FROM jobs WHERE name='lspd'), 5, 'Sergeant',        1200),
((SELECT id FROM jobs WHERE name='lspd'), 6, 'Lieutenant',      1400),
((SELECT id FROM jobs WHERE name='lspd'), 7, 'Captain',         1650),
((SELECT id FROM jobs WHERE name='lspd'), 8, 'Commander',       2000),
((SELECT id FROM jobs WHERE name='lspd'), 9, 'Chief of Police', 2500);

INSERT IGNORE INTO `job_grades` (`job_id`, `grade`, `label`, `salary`) VALUES
((SELECT id FROM jobs WHERE name='bcsd'), 0, 'Deputy Trainee',  400),
((SELECT id FROM jobs WHERE name='bcsd'), 1, 'Deputy I',         550),
((SELECT id FROM jobs WHERE name='bcsd'), 2, 'Deputy II',        700),
((SELECT id FROM jobs WHERE name='bcsd'), 3, 'Senior Deputy',    850),
((SELECT id FROM jobs WHERE name='bcsd'), 4, 'Corporal',        1000),
((SELECT id FROM jobs WHERE name='bcsd'), 5, 'Sergeant',        1200),
((SELECT id FROM jobs WHERE name='bcsd'), 6, 'Lieutenant',      1400),
((SELECT id FROM jobs WHERE name='bcsd'), 7, 'Captain',         1700),
((SELECT id FROM jobs WHERE name='bcsd'), 8, 'Undersheriff',    2100),
((SELECT id FROM jobs WHERE name='bcsd'), 9, 'Sheriff',         2600);

INSERT IGNORE INTO `missions` (`name`, `label`, `description`, `color`) VALUES
('eboueur',       'Eboueur',          'Collecte des ordures menageres en ville.', '#84cc16'),
('livreur_colis', 'Livreur de colis', 'Livraison de colis dans les quartiers.',   '#3b82f6');

INSERT IGNORE INTO `mission_actions` (`mission_id`, `name`, `label`) VALUES
((SELECT id FROM missions WHERE name='eboueur'),       'collect', 'Collecte d''une poubelle'),
((SELECT id FROM missions WHERE name='eboueur'),       'dump',    'Chargement dans le camion'),
((SELECT id FROM missions WHERE name='livreur_colis'), 'pickup',  'Chargement des colis'),
((SELECT id FROM missions WHERE name='livreur_colis'), 'deliver', 'Depot d''un colis');

-- ── Items monétaires & cartes ─────────────────────────────────────────────────

INSERT INTO `items` (`name`, `label`, `weight`, `data`) VALUES
    ('mooney',     'Argent liquide',  0.01, '{"type":"money","usable":false}'),
    ('black_money', 'Argent sale',    0.01, '{"type":"money","usable":false}'),
    ('bank_card',  'Carte bancaire',  0.01, '{"type":"card","usable":true}')
AS new_row ON DUPLICATE KEY UPDATE label = new_row.label, data = new_row.data;

-- ── Migrations ────────────────────────────────────────────────────────────────

ALTER TABLE `characters` MODIFY COLUMN `cash` DECIMAL(10,2) NOT NULL DEFAULT 500.00;
ALTER TABLE `player_items` MODIFY COLUMN `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1.00;
ALTER TABLE `ground_items` MODIFY COLUMN `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1.00;

-- ── Emotes ────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `emote_binds` (
    `identifier` VARCHAR(60) NOT NULL,
    `slots`      JSON        NOT NULL DEFAULT ('{}'),
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

