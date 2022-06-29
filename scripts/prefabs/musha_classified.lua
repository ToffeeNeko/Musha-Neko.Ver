local function SetValue(inst, name, value)
    assert(value >= 0 and value <= 65535, "Player "..tostring(name).." out of range: "..tostring(value))
    inst[name]:set(math.ceil(value))
end

local function SetDirty(netvar, val)
    --Forces a netvar to be dirty regardless of value
    netvar:set_local(val)
    netvar:set(val)
end

local function OnManaDelta(parent, data)
    if data.newpercent > data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ismanapulseup, true)
    elseif data.newpercent < data.oldpercent then
        --Force dirty, we just want to trigger an event on the client
        SetDirty(parent.player_classified.ismanapulsedown, true)
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for player")
    else
        inst._parent:AttachClassified(inst)
        for i, v in ipairs({ "mana" }) do
            if inst._parent.replica[v] ~= nil then
                inst._parent.replica[v]:AttachClassified(inst)
            end
        end
    end
end

local function OnManaDirty(inst)
    if inst._parent ~= nil then
        local oldpercent = inst._oldmanapercent
        local percent = inst.currentmana:value() / inst.maxmana:value()
        local data =
        {
            oldpercent = oldpercent,
            newpercent = percent,
            overtime =
                not (inst.ismanapulseup:value() and percent > oldpercent) and
                not (inst.ismanapulsedown:value() and percent < oldpercent),
        }
        inst._oldmanapercent = percent
        inst.ismanapulseup:set_local(false)
        inst.ismanapulsedown:set_local(false)
        inst._parent:PushEvent("manadelta", data)
        if oldpercent > 0 then
            if percent <= 0 then
                inst._parent:PushEvent("startconsumingmana")
            end
        elseif percent > 0 then
            inst._parent:PushEvent("stopconsumingmana")
        end
    else
        inst._oldmanapercent = 1
        inst.ismanapulseup:set_local(false)
        inst.ismanapulsedown:set_local(false)
    end
end

--------------------------------------------------------------------------

local function RegisterNetListeners(inst)
    if TheWorld.ismastersim then
        inst._parent = inst.entity:GetParent()
    else
        inst.ismanapulseup:set_local(false)
        inst.ismanapulsedown:set_local(false)
        inst:ListenForEvent("manadirty", OnManaDirty)
        
        if inst._parent ~= nil then
            inst._oldmanapercent = inst.maxmana:value() > 0 and inst.currentmana:value() / inst.maxmana:value() or 0
        end
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    --Mana variables
    inst._oldmanapercent = 1
    inst.currentmana = net_ushortint(inst.GUID, "mana.current", "manadirty")
    inst.maxmana = net_ushortint(inst.GUID, "mana.max", "manadirty")
    inst.ismanapulseup = net_bool(inst.GUID, "mana.dodeltaovertime(up)", "manadirty")
    inst.ismanapulsedown = net_bool(inst.GUID, "mana.dodeltaovertime(down)", "manadirty")
    inst.currentmana:set(100)
    inst.maxmana:set(100)

    --Delay net listeners until after initial values are deserialized
    inst:DoStaticTaskInTime(0, RegisterNetListeners)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("musha_classified", fn)
