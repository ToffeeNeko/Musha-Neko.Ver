-- Inherit attributes from GLOBAL
GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })

-- Custom strings (i18n)
local modlanguage = GetModConfigData("modlanguage")

if modlanguage == "chinese" then
    modimport("scripts/i18n/strings_musha_cn.lua")
    STRINGS.CHARACTERS.MUSHA = require("i18n/speech_musha_cn")
elseif modlanguage == "english" then
    modimport("scripts/i18n/strings_musha_en.lua")
    STRINGS.CHARACTERS.MUSHA = require("i18n/speech_musha_en")
elseif modlanguage == "korean" then
    modimport("scripts/i18n/strings_musha_ko.lua")
    STRINGS.CHARACTERS.MUSHA = require("i18n/speech_musha_ko")
elseif modlanguage == "russian" then
    modimport("scripts/i18n/strings_musha_ru.lua")
    STRINGS.CHARACTERS.MUSHA = require("i18n/speech_musha_ru")
end

-- Replicable components (sync between server and client)
AddReplicableComponent("mana")
AddReplicableComponent("leveler")
AddReplicableComponent("stamina")
AddReplicableComponent("fatigue")

-- Run scripts
modimport("scripts/src/tuning.lua") -- Settings, values and parameters
modimport("scripts/src/commonfunctions.lua") -- Define global functions used in this mod
modimport("scripts/src/prefablist.lua") -- Prefab list
modimport("scripts/src/assetlist.lua") -- Asset list
modimport("scripts/src/skinbuild.lua") -- Redefine skin register functions
modimport("scripts/src/recipes.lua") -- Recipe list
modimport("scripts/src/entityscript.lua") -- AddClassPostConstruct
modimport("scripts/src/actions.lua") -- Redefine certain character actions (attack, eat, etc.)
modimport("scripts/src/hotkeys.lua") -- Add key handlers
modimport("scripts/src/stategraphs.lua") -- Add action modules and anims (smite,etc.)
modimport("scripts/src/player_classified.lua") -- Redefine prefabs/player_classified for replicable components (mana, leveler, fatigue, stamina, etc.)
modimport("scripts/src/statusdisplays.lua") -- AddClassPostConstruct: settings for mana/fatigue/stamina badges display
modimport("scripts/src/fueled.lua") -- Redefine components/fueled for musha's equipments
modimport("scripts/src/fuels.lua") -- Add fueltype for musha's equipments

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    ghost_skin = {
        type = "ghost_skin", -- When skin tab is setup, ghost skin will automatically be added, however you can change the zoom ratio using this option
        anim_bank = "ghost", -- "wilson" or "ghost" unless you are not using the default animation banks like werebeaver
        idle_anim = "idle", -- default animation to play such as "idle" or "idle_loop" for ghosts see SG_wilson
        play_emotes = false, -- enable or disable emotes, werebeaver and ghost cannot play emotes
        scale = 0.5, -- multiplier to change the size: zoom out 50%
        offset = { 0, -25 } -- x,y offset: move down
    },
}

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("musha", "FEMALE", skin_modes)
