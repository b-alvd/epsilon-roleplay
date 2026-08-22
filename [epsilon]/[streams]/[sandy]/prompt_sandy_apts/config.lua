-- ============================================================================
-- SANDY SHORES APARTMENTS - CONFIGURATION
-- ============================================================================
-- This file contains all configurable settings for the proximity loader
-- and entity set management system.
-- ============================================================================

Config = {}

-- ============================================================================
-- PROXIMITY LOADER SETTINGS
-- ============================================================================

-- Enable/disable proximity loader
-- Set to false to completely disable MLO APARTMENTS loading/unloading
Config.ProximityEnabled = true

-- Distance in units to load/unload MLO APARTMENTS
Config.ProximityDistance = 30.0

-- Maximum Z (height) difference to load an interior
-- If player's Z differs from interior's Z by more than this, skip loading
Config.ProximityZThreshold = 4.0

-- Base check interval in milliseconds (1000 = 1 second)
-- This is used when player is close to apartments
Config.CheckInterval = 1000

-- ============================================================================
-- DISTANCE-BASED CHECK SCALING
-- ============================================================================

-- Center point for distance scaling (used to calculate how far player is)
Config.ApartmentCenter = { x = 1653.054, y = 3644.21558, z = 57.76181 }

-- Distance thresholds and their check intervals (in milliseconds)
-- Format: { distance = X, interval = Y } - if player is further than X, use Y interval
-- Checked in order, first match wins
Config.CheckScaling = {
    { distance = 500, interval = 10000 },  -- 200+ units away = check every 10s
    { distance = 250, interval = 5000 },   -- 100+ units away = check every 5s
    { distance = 100, interval = 2000 },    -- 50+ units away = check every 2s
    -- Below 50 units = use Config.CheckInterval (1s)
}

-- ============================================================================
-- INTERIOR MODE
-- ============================================================================

-- Interior mode: "shell_only" or "furnished"
-- shell_only = empty interior (no furniture entity set)
-- furnished = loads "furnished" entity set
Config.InteriorMode = "furnished"

-- Entity set name for furniture (as defined in your MLO)
Config.EntitySetFurniture = "furnished"

-- ============================================================================
-- EXCLUSION ZONE (skip loading when player is behind this wall)
-- ============================================================================

-- Enable/disable exclusion zone check
Config.ExclusionZoneEnabled = true

-- Wall defined by 2 points (uses 2D check, ignores Z)
-- If player is on the "wrong" side of this line, IPLs won't load
Config.ExclusionWallPoint1 = { x = 1681.12, y = 3500.52 }
Config.ExclusionWallPoint2 = { x = 1593.68, y = 3656.5 }

-- Additional exclusion box (polygon, uses X/Y only; Z is reference data)
-- If player is inside this box, IPLs won't load
Config.ExclusionBoxEnabled = true
Config.ExclusionBoxPoints = {
    { x = 1639.68, y = 3600.8, z = 41.16 },
    { x = 1598.6, y = 3575.85, z = 35.99 },
    { x = 1607.52, y = 3560.74, z = 36.33 },
    { x = 1641.74, y = 3581.6, z = 35.88 }
}

-- ============================================================================
-- DEBUG SETTINGS
-- ============================================================================

-- Set to true to enable debug prints in console
Config.Debug = true

-- ============================================================================
-- IPL LOCATIONS (loaded/unloaded based on proximity)
-- ============================================================================

Config.IplLocations = {
    -- 1bdr IPLs
    { name = "bld2_prompt_sandy_apts_1bdr_1nd_1", x = 1421.58459, y = 3568.96973, z = 36.02586 },
    { name = "bld2_prompt_sandy_apts_1bdr_2nd_1", x = 1421.58459, y = 3568.96973, z = 42.52607 },
    { name = "bld2_prompt_sandy_apts_1bdr_2nd_3", x = 1402.23767, y = 3549.243, z = 42.52607 },
    { name = "dbld2_prompt_sandy_apts_1bdr_1nd_2", x = 1399.0022, y = 3565.22046, z = 36.02772 },
    { name = "ddbld2_prompt_sandy_apts_1bdr_1nd_3", x = 1402.2373, y = 3549.24561, z = 36.02772 },
    { name = "prompt_sandy_apts_1bdr_1nd_1", x = 1590.52673, y = 3634.08862, z = 36.19072 },
    { name = "prompt_sandy_apts_1bdr_1nd_2", x = 1578.45813, y = 3609.2373, z = 36.19072 },
    { name = "prompt_sandy_apts_1bdr_2nd_1", x = 1590.52673, y = 3634.08862, z = 42.6931839 },
    { name = "prompt_sandy_apts_1bdr_2nd_2", x = 1578.45813, y = 3609.2373, z = 42.6931839 },
    { name = "bld2_prompt_sandy_apts_1bdr_2nd_2", x = 1399.0022, y = 3565.22046, z = 42.52607 },
    { name = "dbld2_prompt_sandy_apts_1bdr_2nd_3", x = 1399.00159, y = 3565.22314, z = 42.52607 },
    -- 1bdr_inv IPLs
    { name = "inv_inv_prompt_sandy_apts_1bdr_2nd_3", x = 1570.31067, y = 3623.349, z = 36.19072 },
    { name = "inv_prompt_sandy_apts_1bdr_1nd_1", x = 1653.57581, y = 3524.38525, z = 36.1693077 },
    { name = "inv_prompt_sandy_apts_1bdr_1nd_3", x = 1634.16614, y = 3512.19653, z = 36.17069 },
    { name = "inv_prompt_sandy_apts_1bdr_1nd_4", x = 1625.99585, y = 3526.348, z = 36.17069 },
    { name = "inv_prompt_sandy_apts_1bdr_2nd_1", x = 1653.57581, y = 3524.38525, z = 42.6656151 },
    { name = "inv_prompt_sandy_apts_1bdr_2nd_2", x = 1570.31067, y = 3623.349, z = 42.6931839 },
    { name = "inv_prompt_sandy_apts_1bdr_2nd_3", x = 1634.14856, y = 3512.22681, z = 42.6656151 },
    { name = "inv_prompt_sandy_apts_1bdr_2nd_4", x = 1625.99841, y = 3526.34326, z = 42.6656151 },
    -- 2bdr IPLs
    { name = "bld2_prompt_sandy_apts_2bdr_1nd_1", x = 1429.21619, y = 3531.25928, z = 36.0 },
    { name = "bld2_prompt_sandy_apts_2bdr_1nd_2", x = 1425.04028, y = 3551.88037, z = 36.0 },
    { name = "bld2_prompt_sandy_apts_2bdr_2nd_1", x = 1429.21619, y = 3531.25928, z = 42.52418 },
    { name = "bld2_prompt_sandy_apts_2bdr_2nd_2", x = 1425.04163, y = 3551.87427, z = 42.52418 },
    { name = "prompt_sandy_apts_2bdr_1nd_1", x = 1609.76, y = 3600.76587, z = 36.191 },
    { name = "prompt_sandy_apts_2bdr_1nd_2", x = 1599.24329, y = 3618.98145, z = 36.191 },
    { name = "prompt_sandy_apts_2bdr_2nd_1", x = 1609.76, y = 3600.76587, z = 42.6912956 },
    { name = "prompt_sandy_apts_2bdr_2nd_2", x = 1599.24329, y = 3618.98145, z = 42.6912956 },
    -- 2bdr_inv IPLs
    { name = "inv_prompt_sandy_apts_2bdr_1nd_1", x = 1634.31226, y = 3557.69067, z = 36.16773 },
    { name = "inv_prompt_sandy_apts_2bdr_1nd_2", x = 1644.82935, y = 3539.47437, z = 36.1650543 },
    { name = "inv_prompt_sandy_apts_2bdr_2nd_1", x = 1634.31226, y = 3557.69067, z = 42.664875 },
    { name = "inv_prompt_sandy_apts_2bdr_2nd_2", x = 1644.82935, y = 3539.47437, z = 42.664875 }
}

-- Additional non-apartment IPLs
-- These use dedicated coordinates with the same default proximity/Z thresholds
-- as apartment IPLs, but do not apply apartment interior entity-set rules.
Config.AdditionalProximityIPLs = {
    { name = "sm_apa_lease_int", x = 1537.52747, y = 3547.89453, z = 36.4102936 },
    { name = "sm_apa_lease_lnge_int", x = 1546.83374, y = 3530.45654, z = 37.2220535 }
}

-- ============================================================================
-- STATIC INTERIORS (always loaded via ymap, only need entity set management)
-- These are spawned by default without proximity loader
-- ============================================================================

Config.StaticInteriors = {
    { name = "penthouse_1", x = 1590.27222, y = 3610.95068, z = 51.4376678 },
    { name = "penthouse_2", x = 1633.34241, y = 3535.84058, z = 51.3740654 },
    { name = "penthouse_3", x = 1414.00476, y = 3547.0896, z = 51.2922554 }
}

