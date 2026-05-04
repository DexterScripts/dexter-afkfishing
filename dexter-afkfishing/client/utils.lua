local zonesCreated = false
local activeZoneCounts = {
    Pier = 0,
    Fresh = 0,
    River = 0,
    Swamp = 0,
    Ocean = 0,
    Illegal = 0
}
local createdZones = {}
local zoneOrder = {'Pier', 'Fresh', 'River', 'Swamp', 'Ocean', 'Illegal'}

local Items = {
    Rods = Config.RodItems,
    Bait = Config.BaitItems,
    Fish = Config.CatchPools
}

function CreateFishingZones()
    if zonesCreated then return end

    for zoneName, zoneType in pairs(Config.Zones) do
        local index = 1

        for _, zoneData in pairs(zoneType) do
            local zone = lib.zones.sphere({
                name = zoneName .. index,
                coords = zoneData.coords,
                radius = zoneData.radius,
                debug = Config.Debug,
                zoneName = zoneName,
                onEnter = function(self)
                    local count = activeZoneCounts[self.zoneName] or 0
                    activeZoneCounts[self.zoneName] = count + 1
                end,
                onExit = function(self)
                    local count = activeZoneCounts[self.zoneName] or 0
                    activeZoneCounts[self.zoneName] = math.max(count - 1, 0)
                end
            })

            createdZones[#createdZones + 1] = zone
            index += 1
        end
    end

    zonesCreated = true
end

function RemoveFishingZones()
    for i = 1, #createdZones do
        if createdZones[i] then
            createdZones[i]:remove()
        end
    end

    createdZones = {}

    for k in pairs(activeZoneCounts) do
        activeZoneCounts[k] = 0
    end

    zonesCreated = false
end

---@return string 'Pier' | 'Fresh' | 'River' | 'Swamp' | 'Ocean' | 'Illegal' | 'None'
function GetPlayerZone()
    for i = 1, #zoneOrder do
        local zoneName = zoneOrder[i]
        if (activeZoneCounts[zoneName] or 0) > 0 then
            return zoneName
        end
    end

    local ped = PlayerPedId()
    if ped ~= 0 then
        local coords = GetEntityCoords(ped)
        local playerCoords = vec2(coords.x, coords.y)

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
    end

    return 'None'
end

---@return table {[1] = blipID, [2] = blipID, [3] = blipID, ...}
function GetFishingBlips()
    local blips = {}
    local blip = GetFirstBlipInfoId(210)

    while DoesBlipExist(blip) do
        blips[#blips + 1] = blip
        blip = GetNextBlipInfoId(210)
    end

    return blips
end

---@param coords vector3
---@return boolean
local function doesBlipExistAtCoords(coords)
    local blips = GetFishingBlips()

    for i = 1, #blips do
        local blipCoords = GetBlipCoords(blips[i])
        if #(blipCoords - coords) < 1.0 then
            return true
        end
    end

    return false
end

function CreateBlips()
    local function getZoneBlipLabel(name)
        local requiredLevel = GetRequiredLevel(name)

        if name == 'Illegal' then
            return ('Level %s Illegal Fishing'):format(requiredLevel)
        end

        return ('Level %s Fishing'):format(requiredLevel)
    end

    local function createBlipWith(name, coords, radius)
        local outer = AddBlipForRadius(coords, radius)
        local inner = AddBlipForRadius(coords, radius - 1)
        local icon = AddBlipForCoord(coords)

        SetBlipSprite(icon, 210)
        SetBlipDisplay(icon, 4)
        SetBlipScale(icon, 0.5)
        SetBlipAsShortRange(icon, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(getZoneBlipLabel(name))
        EndTextCommandSetBlipName(icon)

        SetBlipHighDetail(inner, true)
        SetBlipColour(inner, name == 'Illegal' and 76 or 40)
        SetBlipAlpha(inner, 128)

        SetBlipSprite(outer, 10)
        SetBlipHighDetail(outer, true)
        SetBlipColour(outer, 4)
        SetBlipAlpha(outer, 128)
    end

    for zoneName, zoneType in pairs(Config.Zones) do
        for _, zoneData in pairs(zoneType) do
            if not doesBlipExistAtCoords(zoneData.coords) then
                createBlipWith(zoneName, zoneData.coords, zoneData.radius)
            end
        end
    end
end

local function hasItem(itemName)
    return exports.ox_inventory:Search('count', itemName) > 0
end

local function hasAnyItem(itemNames)
    for i = 1, #itemNames do
        if hasItem(itemNames[i]) then
            return true
        end
    end

    return false
end

---@param index string
---@param illegal boolean|nil
---@param area string|nil
---@return boolean
function CheckForItem(index, illegal, area)
    if index == 'Rods' then
        return hasAnyItem(Items.Rods)
    end

    if index == 'Bait' then
        return hasAnyItem(Items.Bait[illegal and 'Illegal' or 'Legal'] or {})
    end

    if index == 'Fish' and area then
        local group = illegal and 'Illegal' or 'Legal'
        return hasAnyItem((Items.Fish[group] and Items.Fish[group][area]) or {})
    end

    return false
end

function GetRequiredLevel(zone)
    return Config.RequiredLevels[zone] or 0
end
