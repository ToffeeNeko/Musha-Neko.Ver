local assets = {
    Asset("ANIM", "anim/inventories/frosthammer.zip"),
    Asset("ANIM", "anim/inventories/frosthammer2.zip"),
    Asset("ANIM", "anim/inventories/swap_frosthammer.zip"),
    Asset("ANIM", "anim/inventories/swap_frosthammer2.zip"),
    Asset("ATLAS", "images/inventoryimages/frosthammer.xml"),
    Asset("IMAGE", "images/inventoryimages/frosthammer.tex"),
}

local prefabs = {}

-- Check weapon status and set damage
local function update_damage(inst)
    if inst.components.fueled:IsEmpty() then
        inst.broken = true
        inst.components.weapon:SetDamage(1)
    else
        inst.broken = false
        local level_to_damage = { 75, 77, 79, 81, 83, 85, 87, 89, 91, 93, 95, 97, 99, 101, 103, 105, 107, 109, 111, 113,
            115, 120, 127, 134, 141, 148, 155, 162, 170, 200 } -- len = 30
        inst.components.weapon:SetDamage(level_to_damage[inst.level])
    end
end

-- Exp to level
local function update_level(inst)
    if inst.exp >= 4000 then
        inst.level = 30
        inst.components.talker:Say("-[" ..
            STRINGS.MUSHA_WEAPON_FROSTHAMMER .. "] \n[" .. STRINGS.MUSHA_ITEM_GROWPOINTS .. "]\n" .. "[ LEVEL MAX ]")
    else
        local exp_to_level = { 10, 30, 50, 70, 90, 120, 150, 180, 210, 250, 350, 450, 550, 650, 750, 850, 950, 1050, 1200,
            1400, 1600, 1800, 2000, 2200, 2400, 2600, 2800, 3000, 4000 } -- len = 29
        for i, v in ipairs(exp_to_level) do
            if inst.exp < v then
                inst.level = i
                inst.required_exp = v
                break
            end
        end
        inst.components.talker:Say("-[" ..
            STRINGS.MUSHA_WEAPON_FROSTHAMMER ..
            "] \n[" .. STRINGS.MUSHA_ITEM_GROWPOINTS .. "]\n" .. (inst.exp) .. "/" .. exp_to_level[inst.level])
    end
    update_damage(inst)
end

-- Broken effects
local function fx_broken(inst)
    local owner = inst.components.inventoryitem.owner
    local fx = SpawnPrefab("weaponsparks")
    if owner then
        fx.entity:AddFollower():FollowSymbol(owner.GUID, "swap_object", 1, -350, 1)
    else
        local offset = Vector3(0, 2.4, 0)
        fx.Transform:SetPosition((inst:GetPosition() + offset):Get())
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst.components.talker:Say(STRINGS.MUSHA_WEAPON_BROKEN .. " \n" .. STRINGS.MUSHA_WEAPON_DAMAGE .. " (1)")
end

-- Add fuel effects
local function fx_addfuel(inst)
    local owner = inst.components.inventoryitem.owner
    if owner then
        local fx = SpawnPrefab("firesplash_fx")
        fx.Transform:SetScale(0.3, 0.3, 0.3)
        fx.Transform:SetPosition(owner:GetPosition():Get())
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end
end

-- Dynamic anime when boost mode is on
local function fx_boost(inst)
    local owner = inst.components.inventoryitem.owner
    if owner then
        inst.boost_fx = SpawnPrefab("lantern_winter_fx_held")
        inst.boost_fx.entity:AddFollower():FollowSymbol(owner.GUID, "swap_object", 1, -350, 1)

        local fx = SpawnPrefab("weaponsparks")
        fx.entity:AddFollower():FollowSymbol(owner.GUID, "swap_object", 1, -350, 1)
    end
end

-- Words to declare on boost
local function speak_boost_on(inst)
    local str1 = "[" .. STRINGS.MUSHA_WEAPON_FROSTHAMMER .. "]\n"
        .. STRINGS.MUSHA_WEAPON_DAMAGE .. " (" .. inst.components.weapon.damage .. ")\n"

    local str2 = inst.level < 30 and "EXP ( " .. inst.exp .. "/" .. inst.required_exp .. " )\n" or ""

    local str3 = STRINGS.MUSHA_WEAPON_AREA .. "\n"
        .. STRINGS.MUSHA_WEAPON_FREEZESLOW .. "\n"

    local str4 = STRINGS.MUSHA_WEAPON_TENTACLE_FROST .. "\n"

    local str5 = STRINGS.MUSHA_WEAPON_COOLER .. "\n"

    local str6 = inst.level < 30 and "LV ( " .. inst.level .. "/30 )\n" or "LV ( " .. inst.level .. "/30 ) [ MAX ]\n"

    local declaration = str1 .. str6 .. str2 .. str3 .. str4 .. str5
    return declaration
end

-- Words to declare on boost off
local function speak_boost_off(inst)
    local str1 = "[" .. STRINGS.MUSHA_WEAPON_FROSTHAMMER .. "]\n"
        .. STRINGS.MUSHA_WEAPON_DAMAGE .. " (" .. inst.components.weapon.damage .. ")\n"

    local str2 = inst.level < 30 and "EXP ( " .. inst.exp .. "/" .. inst.required_exp .. " )\n" or ""

    local str6 = inst.level < 30 and "LV ( " .. inst.level .. "/30 )\n" or "LV ( " .. inst.level .. "/30 ) [ MAX ]\n"

    local declaration = str1 .. str6 .. str2
    return declaration
end

-- Reticule (gamepad support)
local function reticuletargetfn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
end

-- On attack
local function onattack(inst, attacker, target, data)
    if target and not inst.broken then
        inst.components.fueled:DoDelta(-50)

        if inst.boost then
            local fx = SpawnPrefab("groundpoundring_fx")
            fx.Transform:SetScale(0.45, 0.45, 0.45)
            fx.Transform:SetPosition(target:GetPosition():Get())

            if target.components.freezable then
                target.components.freezable:AddColdness(1.65)
                target.components.freezable:SpawnShatterFX()
                local prefab = "icespike_fx_" .. math.random(1, 4)
                local fx = SpawnPrefab(prefab)
                fx.Transform:SetScale(1.0, 2, 1.0)
                fx.Transform:SetPosition(target:GetPosition():Get())
            end

            local range = 2
            local excludetags = { "INLIMBO", "notarget", "noattack", "invisible", "playerghost", "companion", "wall",
                "musha_companion" }
            attacker.components.combat:DoAreaAttack(target, range, inst, nil, nil, excludetags)
        end

    elseif target and inst.broken then
        fx_broken(inst)
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable and target.components.burnable:IsBurning() then
        target.components.burnable:Extinguish()
    end
end

-- On put in inventory
local function onputininventory(inst)
end

-- On dropped to ground
local function ondropped(inst)
    if inst.boost then
        inst.AnimState:SetBuild("frosthammer2")
    else
        inst.AnimState:SetBuild("frosthammer")
    end
end

-- On pick up
local function onpickup(inst)
end

-- On equip
local function onequip(inst, owner)
    if not inst.boost then
        inst.components.talker:Say(speak_boost_off(inst))
        owner.AnimState:OverrideSymbol("swap_object", "swap_frosthammer", "frosthammer")
    else
        fx_boost(inst)
        inst.components.talker:Say(speak_boost_on(inst))
        owner.AnimState:OverrideSymbol("swap_object", "swap_frosthammer2", "frosthammer")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.frost = true
    owner.frosthammer_equipped = true
end

-- On unequip
local function onunequip(inst, owner)
    owner.frost = false
    owner.frosthammer_equipped = false

    if inst.components.heater then
        inst:RemoveComponent("heater")
    end
    if inst.components.reticule then
        inst:RemoveComponent("reticule")
    end
    if inst.components.spellcaster then
        inst:RemoveComponent("spellcaster")
    end
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if inst.boost_fx then
        inst.boost_fx:Remove()
    end
end

-- Boost mode on (right click)
local function boost_on(inst)
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner.AnimState:OverrideSymbol("swap_object", "swap_frosthammer2", "frosthammer")
    else
        inst.AnimState:SetBuild("frosthammer2")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst.components.talker:Say(speak_boost_on(inst))
    inst.components.equippable.walkspeedmult = 0.75
    inst.boost = true
    fx_boost(inst)
end

-- Boost mode off (right click)
local function boost_off(inst, data)
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner.AnimState:OverrideSymbol("swap_object", "swap_frosthammer", "frosthammer")
    else
        inst.AnimState:SetBuild("frosthammer")
    end

    if inst.components.heater then
        inst:RemoveComponent("heater")
    end
    if inst.components.spellcaster then
        inst:RemoveComponent("spellcaster")
    end
    if inst.boost_fx then
        inst.boost_fx:Remove()
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    inst.components.talker:Say(speak_boost_off(inst))
    inst.components.equippable.walkspeedmult = 1
    inst.boost = false
end

-- On fuel deplete
local function ondepleted(inst, data)
    update_damage(inst)
end

-- On add fuel
local function ontakefuel(inst, fuelvalue, fuel_obj)
    local fuel = fuel_obj.prefab

    if not inst.forgelab_on then
        inst.exp = inst.exp + 1995
        inst.components.talker:Say("-" ..
            STRINGS.MUSHA_WEAPON_FROSTHAMMER ..
            " \n" .. STRINGS.MUSHA_ITEM_LUCKY .. " +(2)\n[" .. STRINGS.MUSHA_ITEM_GROWPOINTS .. "]" .. (inst.level))
    end
    inst.components.fueled:DoDelta(500)
    fx_addfuel(inst)
    update_level(inst)
end

---------------------------------------------------------------------------------------------------------

-- On save
local function onsave(inst, data)
    data["local_attributes"] = {
        exp = inst.exp
    }
end

-- On preload
local function onpreload(inst, data)
    -- Reserved for possible future use
end

-- On load
local function onload(inst, data)
    if data.local_attributes then
        for k, v in pairs(data.local_attributes) do
            if v then
                inst[k] = v
            end
        end
    end

    update_level(inst)
    update_damage(inst)
end

---------------------------------------------------------------------------------------------------------

-- Main function
local function fn()
    local inst = CreateEntity()

    inst:AddTag("musha_items")
    inst:AddTag("musha_equipment")
    inst:AddTag("frosthammer")
    inst:AddTag("attackmodule_smite")
    inst:AddTag("levelerattached")

    inst.entity:AddTransform() -- Allows the entity to have a position in the world
    inst.entity:AddAnimState() -- Allows the entity to have a sprite and animate it
    inst.entity:AddSoundEmitter() -- Allows the entity to play sounds
    inst.entity:AddNetwork() -- For networking the entity
    inst.entity:AddMiniMapEntity() -- Allows the entity to be shown on the minimap    

    MakeInventoryPhysics(inst) -- Sets entity physics (radius, collisions, etc.)
    MakeInventoryFloatable(inst, "small", 0.07, 0.73) -- Sets the inventory floatable

    inst.AnimState:SetBank("frosthammer") -- The name of the anime file
    inst.AnimState:SetBuild("frosthammer") -- The name of the build
    inst.AnimState:PlayAnimation("idle") -- Play idle animation on creation

    inst.MiniMapEntity:SetIcon("frosthammer.tex")

    inst:AddComponent("talker") -- Added on client side in order to work for clients
    inst.components.talker.fontsize = 20
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(0.7, 0.85, 1, 1)
    inst.components.talker.offset = Vector3(200, -250, 0)
    inst.components.talker.symbol = "swap_object"

    inst:AddComponent("reticule") -- for gampad support
    inst.components.reticule.targetfn = reticuletargetfn
    inst.components.reticule.ease = true

    inst.entity:SetPristine() -- Initialize. All engine level components (Transform, AnimState, Physics, etc.) should be added before a call to SetPristine for a matter of reducing network usage

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/frosthammer.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "musha"

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)

    inst:AddComponent("weapon")
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetRange(1.6)
    inst.components.weapon:SetDamage(75)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "BURNABLE"
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(1000)
    inst.components.fueled:SetDepletedFn(ondepleted)
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:StopConsuming()

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = boost_on
    inst.components.machine.turnofffn = boost_off
    inst.components.machine.cooldowntime = 0

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(boost_on)

    MakeHauntableLaunch(inst) -- Sets the entity to be hauntable

    -- Saving required
    inst.exp = 0

    -- Don't need to be saved
    inst.level = 1
    inst.required_exp = 10
    inst.boost = false

    inst.OnSave = onsave
    inst.OnPreLoad = onpreload
    inst.OnLoad = onload

    return inst
end

return Prefab("common/inventory/frosthammer", fn, assets, prefabs)
