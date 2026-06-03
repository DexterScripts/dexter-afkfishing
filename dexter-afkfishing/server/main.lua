math.randomseed(os.time())

--------------------------- FUNCTIONS ---------------------------

local function notify(source, message, notifyType)
    exports.qbx_core:Notify(source, message, notifyType or 'inform')
end

local function getFishLabel(itemName)
    local ok, item = pcall(function() return exports.ox_inventory:Items(itemName) end)
    return (ok and item and item.label) or itemName
end

local function sendZPhoneNotif(src, message)
    if not Config.ZPhoneNotifications then return end
    if GetResourceState('z-phone') ~= 'started' then return end
    TriggerClientEvent('z-phone:client:sendNotifInternal', src, {
        type = 'Notification',
        from = 'Fishing',
        message = message
    })
end

---@param min number
---@param max number
---@return number
local function randomNum(min, max)
    return math.floor((math.random() * (max - min) + min) + 0.5)
end

local function getPlayerZone(source)
    local ped = GetPlayerPed(source)
    if ped == 0 then return 'None' end

    local coords = GetEntityCoords(ped)
    local playerCoords = vec2(coords.x, coords.y)
    local zoneOrder = {'Pier', 'Fresh', 'River', 'Swamp', 'Ocean', 'Illegal'}

    for i = 1, #zoneOrder do
        local zoneName = zoneOrder[i]
        local areas = Config.Zones[zoneName] or {}

        for j = 1, #areas do
            local zoneCoords = areas[j].coords
            local areaCoords = vec2(zoneCoords.x, zoneCoords.y)

            if #(playerCoords - areaCoords) <= areas[j].radius then
                return zoneName
            end
        end
    end

    return 'None'
end

local function getFirstOwnedItem(source, items)
    for i = 1, #items do
        local itemName = items[i]
        if exports.ox_inventory:GetItemCount(source, itemName) > 0 then
            return itemName
        end
    end
end

---@param zone string
---@param level number
---@return string
local function getFish(zone, level)
    local fish = Config.CatchPools.Legal[zone] or Config.CatchPools.Illegal.ocean
    local fishChances = {}
    local total = 0

    level = math.max(level, 1)

    for i = 1, #fish do
        local chance = 1 / (i / 100)
        total += chance
        fishChances[i] = total / (level / 100)
    end

    local num = randomNum(1, total / (level / 100))

    for i = 1, #fishChances do
        if num <= fishChances[i] then
            return fish[i]
        end
    end

    return fish[#fish]
end

local function logToDiscord(source, info)
    if not Config.DiscordLogs or Config.DiscordWebhook == '' then return end

    local embed = {
        {
            title = 'Fishing | Fish Sold',
            color = 65280,
            description = ('**%s** (CitizenID: %s | ID: %s) sold %s fish for $%s'):format(
                GetPlayerName(source),
                info.player,
                source,
                info.amount,
                info.price
            ),
            footer = {
                text = os.date('%Y-%m-%d %H:%M:%S')
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        username = 'dexter-afkfishing',
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

--------------------------- EVENTS ---------------------------

RegisterNetEvent('dexter-afkfishing:server:GoFishing', function(level)
    local src = source
    local zone = getPlayerZone(src)
    local illegal = zone == 'Illegal'
    local requiredLevel = Config.RequiredLevels[zone] or 0
    local rod = getFirstOwnedItem(src, Config.RodItems)
    local bait = getFirstOwnedItem(src, Config.BaitItems[illegal and 'Illegal' or 'Legal'])

    level = tonumber(level) or 0

    if zone == 'None' then
        notify(src, 'You need to be inside a fishing zone.', 'error')
        return
    end

    if not rod then
        notify(src, 'You do not have a fishing rod.', 'error')
        return
    end

    if not bait then
        notify(src, 'You do not have the correct bait.', 'error')
        return
    end

    if level < requiredLevel then
        notify(src, ('You need to be level %s to fish in this area. Your %s level is %s.'):format(requiredLevel, Config.Skill.name, level), 'error')
        return
    end

    local fish = getFish(zone:lower(), level)

    if not exports.ox_inventory:CanCarryItem(src, fish, 1) then
        notify(src, 'You cannot carry any more fish.', 'error')
        return
    end

    local removedBait = exports.ox_inventory:RemoveItem(src, bait, 1)
    if not removedBait then
        notify(src, 'You do not have the correct bait.', 'error')
        return
    end

    local success = exports.ox_inventory:AddItem(src, fish, 1)
    if not success then
        exports.ox_inventory:AddItem(src, bait, 1)
        notify(src, 'You could not carry the fish.', 'error')
        return
    end

    TriggerClientEvent('dexter-afkfishing:client:CatchSuccess', src)
    sendZPhoneNotif(src, ('You caught a %s!'):format(getFishLabel(fish)))

    if Config.Debug then
        print(('Fish received: %s | Zone: %s'):format(fish, zone))
    end
end)

RegisterNetEvent('dexter-afkfishing:server:SellFish', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local price = 0
    local fish = 0

    if not player then return end

    for itemName, saleData in pairs(Config.FishPrices) do
        local amount = exports.ox_inventory:GetItemCount(src, itemName)

        if amount > 0 then
            local removed = exports.ox_inventory:RemoveItem(src, itemName, amount)
            if removed then
                price += saleData.price * amount
                fish += amount
            end
        end
    end

    if fish == 0 then
        notify(src, 'You have no fish to sell.', 'error')
        return
    end

    exports.qbx_core:AddMoney(src, Config.SellMoneyType, price, 'sold-fish')
    notify(src, ('You sold %s fish for $%s.'):format(fish, price), 'success')
    sendZPhoneNotif(src, ('You sold %s fish for $%s!'):format(fish, price))

    if Config.DiscordLogs then
        logToDiscord(src, {
            player = player.PlayerData.citizenid,
            amount = fish,
            price = price
        })
    end
end)
