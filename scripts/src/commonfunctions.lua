-- Remove entity
GLOBAL.CustomRemoveEntity = function(inst, delay)
    if delay then
        TheWorld:DoTaskInTime(delay, function()
            if inst then
                inst:Remove()
                inst = nil
            end
        end)
    else
        if inst then
            inst:Remove()
            inst = nil
        end
    end
end

---------------------------------------------------------------------------------------------------------

-- Stop scheduled task
GLOBAL.CustomCancelTask = function(inst, delay)
    if delay then
        TheWorld:DoTaskInTime(delay, function()
            if inst then
                inst:Cancel()
                inst = nil
            end
        end)
    else
        if inst then
            inst:Cancel()
            inst = nil
        end
    end
end

---------------------------------------------------------------------------------------------------------

-- Freeze
local function StartFreezeCooldown(inst)
    inst:AddDebuff("postfreezeslowdown", "debuff_slowdown") -- Add slowdown debuff upon unfreeze
    inst.components.debuffable:GetDebuff("postfreezeslowdown"):SetDuration(TUNING.musha.freezecooldowntime)
    inst:DoTaskInTime(TUNING.musha.freezecooldowntime, function()
        inst:RemoveTag("freeze_cooldown")
        inst:RemoveEventCallback("unfreeze", StartFreezeCooldown)
    end)
end

GLOBAL.CustomOnFreeze = function(inst)
    inst:AddTag("freeze_cooldown")
    inst:ListenForEvent("unfreeze", StartFreezeCooldown)
end

---------------------------------------------------------------------------------------------------------

-- Attach fx to inst
local function SpawnFx(target, fx_name, duration, scale, offset)
    local a, b, c
    if scale then
        a, b, c = scale.x, scale.y, scale.z
    else
        a, b, c = 1, 1, 1
    end

    local x, y, z
    if offset then
        x, y, z = offset.x, offset.y, offset.z
    else
        x, y, z = 0, 0, 0
    end

    local fx = SpawnPrefab(fx_name)
    local dur = duration or 1

    fx.entity:SetParent(target.entity)
    fx.Transform:SetScale(a, b, c)
    fx.Transform:SetPosition(x, y, z)

    if dur ~= 0 then
        target:DoTaskInTime(dur, function()
            fx:Remove()
            fx = nil
        end)
    end
end

GLOBAL.CustomAttachFx = function(target, fx_list, duration, scale, offset) -- Set duration = 0 to make it permanent
    if type(fx_list) == "string" then
        SpawnFx(target, fx_list, duration, scale, offset)
    elseif type(fx_list) == "table" then
        for i, fx_name in pairs(fx_list) do
            SpawnFx(target, fx_name, duration, scale, offset)
        end
    end
end

---------------------------------------------------------------------------------------------------------
-- Area of effect
GLOBAL.CustomDoAOE = function(center, radius, must_tags, additional_ignore_tags, fn)
    local x, y, z = center.Transform:GetWorldPosition()
    local ignore_tags = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "isdead" }

    for _, v in ipairs(additional_ignore_tags) do
        table.insert(ignore_tags, v)
    end

    local targets = TheSim:FindEntities(x, y, z, radius, must_tags, ignore_tags) -- Note: FindEntities(x, y, z, range, must_tags, ignore_tags)

    if targets then
        for _, target in pairs(targets) do
            fn(target)
        end
    end
end
