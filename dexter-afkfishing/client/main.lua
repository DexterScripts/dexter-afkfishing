local isFishing = false
local isFishingTick = false
local tickStarted = false
local sellPed
local sellBlip
local fishingPromptVisible = false
local fishingPromptText
local fishingSessionId = 0

--------------------------- FUNCTIONS ---------------------------

local function notify(message, notifyType)
    exports.qbx_core:Notify(message, notifyType or 'inform')
end

local function hideFishingPrompt()
    if not fishingPromptVisible then
        return
    end

    lib.hideTextUI()
    fishingPromptVisible = false
    fishingPromptText = nil
end

local function showFishingPrompt()
    local text = isFishing and '[H] Stop Fishing' or '[E] Start Fishing'

    if fishingPromptVisible and fishingPromptText == text then
        return
    end

    lib.showTextUI(text, {
        position = 'right-center',
        icon = 'fish'
    })

    fishingPromptVisible = true
    fishingPromptText = text
end

local function isSkillsReady()
    return GetResourceState('mz-skills') == 'started'
end

local function getFishingLevel()
    if not isSkillsReady() then
        return 0
    end

    local ok, level = pcall(function()
        return exports['mz-skills']:GetCurrentLevel(Config.Skill.name)
    end)

    return ok and (tonumber(level) or 0) or 0
end

local function addFishingXp()
    if not isSkillsReady() then
        return
    end

    pcall(function()
        exports['mz-skills']:UpdateSkill(Config.Skill.name, Config.Skill.xp)
    end)
end

local function isInBlockedVehicle(ped)
    if not IsPedInAnyVehicle(ped, true) then
        return false
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return false
    end

    local vehicleClass = GetVehicleClass(vehicle)
    return vehicleClass ~= 14
end

local function cleanUpPed()
    local ped = PlayerPedId()

    fishingSessionId += 1
    isFishing = false
    isFishingTick = false

    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

    for _, object in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(ped, object) then
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
        end
    end

    ClearPedSecondaryTask(ped)
    ClearPedTasksImmediately(ped)
    hideFishingPrompt()
end

local function startFishingTick()
    if tickStarted then return end

    local sleep = 3000
    tickStarted = true

    CreateThread(function()
        while tickStarted do
            Wait(sleep)

            if GetPlayerZone() ~= 'None' then
                sleep = 1000
                showFishingPrompt()
            else
                sleep = 3000
                hideFishingPrompt()
            end
        end
    end)
end

local function startFishing()
    local ped = PlayerPedId()
    local sleep = Config.Delay * 1000
    local sessionId

    fishingSessionId += 1
    sessionId = fishingSessionId
    isFishingTick = true

    CreateThread(function()
        while isFishingTick and fishingSessionId == sessionId do
            Wait(sleep)

            if not isFishingTick or fishingSessionId ~= sessionId then
                return
            end

            local zone = GetPlayerZone()

            if zone == 'None' then
                notify('You need to stay inside a fishing zone.', 'error')
                cleanUpPed()
                return
            end

            if isInBlockedVehicle(ped) then
                notify('You cannot fish from cars or trucks. Boats are allowed.', 'error')
                cleanUpPed()
                return
            end

            if not IsPedUsingScenario(ped, 'WORLD_HUMAN_STAND_FISHING') then
                notify('You stopped fishing.', 'error')
                cleanUpPed()
                return
            end

            if not CheckForItem('Bait', zone == 'Illegal') then
                notify('You do not have any fishing bait.', 'error')
                cleanUpPed()
                return
            end

            if not isFishing then
                cleanUpPed()
                return
            end

            local level = getFishingLevel()
            TriggerServerEvent('dexter-afkfishing:server:GoFishing', level)
        end
    end)
end

local function reqMod(model)
    if type(model) == 'string' then
        model = joaat(model)
    end

    if HasModelLoaded(model) then return end

    RequestModel(model)
    repeat Wait(0) until HasModelLoaded(model)
end

local function createSellPed()
    if sellPed and DoesEntityExist(sellPed) then return end

    local start = Config.Selling
    local model = start.ped

    reqMod(model)

    local ped = CreatePed(4, model, start.coords, start.heading, false, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
    FreezeEntityPosition(ped, true)

    if tostring(start.scenario):find('SEAT') then
        local chair = GetClosestObjectOfType(start.coords, 5.0, start.chair, false, false, false)
        if DoesEntityExist(chair) then
            AttachEntityToEntity(chair, ped, GetPedBoneIndex(ped, 0x0), 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, false, false, false, false, 2, true)
        end
    end

    TaskStartScenarioInPlace(ped, start.scenario, 0, true)
    SetModelAsNoLongerNeeded(model)

    sellPed = ped

    exports.ox_target:addLocalEntity(sellPed, {
        {
            name = 'don_afkfishing_sell',
            icon = start.targetIcon,
            label = start.targetLabel,
            distance = 3.0,
            onSelect = function()
                TriggerServerEvent('dexter-afkfishing:server:SellFish')
            end
        }
    })
end

local function createSellBlip()
    local sellConfig = Config.Selling
    local blipConfig = sellConfig.blip

    if not blipConfig or blipConfig.enabled == false then return end
    if sellBlip and DoesBlipExist(sellBlip) then return end

    sellBlip = AddBlipForCoord(sellConfig.coords)
    SetBlipSprite(sellBlip, blipConfig.sprite or 356)
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, blipConfig.scale or 0.8)
    SetBlipColour(sellBlip, blipConfig.colour or 3)
    SetBlipAsShortRange(sellBlip, blipConfig.shortRange ~= false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipConfig.label or 'Fish Buyer')
    EndTextCommandSetBlipName(sellBlip)
end

local function removeSellPed()
    if sellPed and DoesEntityExist(sellPed) then
        exports.ox_target:removeLocalEntity(sellPed, 'don_afkfishing_sell')
        DeleteEntity(sellPed)
    end

    sellPed = nil
end

local function removeSellBlip()
    if sellBlip and DoesBlipExist(sellBlip) then
        RemoveBlip(sellBlip)
    end

    sellBlip = nil
end

local function initializeFishing()
    CreateFishingZones()
    CreateBlips()
    createSellPed()
    createSellBlip()
    startFishingTick()
end

--------------------------- KEYBINDS ---------------------------

RegisterCommand('fishing', function()
    local ped = PlayerPedId()
    local zone = GetPlayerZone()
    local level = getFishingLevel()

    if zone == 'None' then return end

    if isFishing then
        notify('You are already fishing.', 'error')
        return
    end

    if isInBlockedVehicle(ped) then
        notify('You cannot fish from cars or trucks. Boats are allowed.', 'error')
        return
    end

    if not CheckForItem('Rods') then
        notify('You do not have a fishing rod.', 'error')
        return
    end

    if not CheckForItem('Bait', zone == 'Illegal') then
        notify('You do not have any fishing bait.', 'error')
        return
    end

    local requiredLevel = GetRequiredLevel(zone)
    if level < requiredLevel then
        notify(('You need to be level %s to fish in this area. Your %s level is %s.'):format(requiredLevel, Config.Skill.name, level), 'error')
        return
    end

    isFishing = true
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_FISHING', 0, true)
    showFishingPrompt()
    startFishing()
end, false)

RegisterCommand('stopfishing', function()
    if not isFishing or not isFishingTick then return end
    cleanUpPed()
end, false)

RegisterKeyMapping('fishing', 'Fishing', 'keyboard', 'e')
RegisterKeyMapping('stopfishing', 'Fishing', 'keyboard', 'h')

--------------------------- HANDLERS ---------------------------

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    initializeFishing()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    tickStarted = false
    cleanUpPed()
    removeSellPed()
    removeSellBlip()
end)

--------------------------- EVENTS ---------------------------

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    initializeFishing()
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    cleanUpPed()
    removeSellPed()
    removeSellBlip()
end)

RegisterNetEvent('dexter-afkfishing:client:CatchSuccess', function()
    addFishingXp()
end)
