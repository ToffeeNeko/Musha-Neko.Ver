TUNING.musha = {
    -- Hotkeys from modinfo
    hotkey_valkyrie = GetModConfigData("hotkey_valkyrie") or 114, --R
    hotkey_berserk = GetModConfigData("hotkey_berserk") or 115, --G

    -- Stats related
    health = 200,
    hunger = 200,
    sanity = 200,

    maxmana = 50,
    manaregenspeed = -1,

    maxfatigue = 100,
    fatiguerate = 0,

    maxstamina = 100,
    staminarate = 1,

    damagemultiplier = 0.75,
    areahitdamagepercent = 0.5,

    maxpets = 100,

    maxexperience = 300,
    maxlevel = 30,
    exprate = 1,
    exp_to_level = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210,
        220, 230, 240, 250, 260, 270, 280, 290, 300 }, -- len = 30

    leveltounlockskill = {
        freezingspell      = 0,
        manashield         = 0,
        valkyrie           = 0,
        manashield_passive = 0,
        berserk            = 0,
        thunderspell       = 0,
        sneak              = 0,
        sporebomb          = 0,
        shadowshield       = 0,
        instantcast        = 0,
    },

    valkyrieattackboost = 1.2,
    valkyriedefenseboost = 0.2,

    activateberserkbasedamage = 5,
    sneaksanitycost = 50,
    sneakspeedboost = 2.5,
    sneakspeedboostduration = 5,
    backstabbasedamage = 200,

    freezecooldowntime = 2.5,
    debuffslowdownmult = 0.3,
    debuffslowdownduration = 4,

    weapon = {
        fuellevel = 1000,
        refueldelta = 200,
        fuelconsume_attack = -10,
        fuelconsume_cast = -50,
        fuelconsume_aura = -10,
        expdelta = 5,
        auraradius = 10,
        auraperiod = 2,
    }
}
