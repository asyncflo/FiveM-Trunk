-- Trunk Inventory Script with UI for FiveM
-- Author: asyncflo

local trunkInventories = {} -- Speicher für die Kofferräume der Fahrzeuge
local MAX_ITEMS = 20 -- Maximale Anzahl an Gegenständen im Kofferraum
local TRUNK_KEY = 311 -- "K"-Taste

-- Hilfsfunktion: Prüfen, ob der Spieler hinter dem Fahrzeug steht
local function isPlayerBehindVehicle(player, vehicle)
    local playerCoords = GetEntityCoords(player)
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleHeading = GetEntityHeading(vehicle)

    -- Berechnung der Position direkt hinter dem Fahrzeug
    local backOffset = vector3(
        vehicleCoords.x - math.cos(math.rad(vehicleHeading)) * 2.0,
        vehicleCoords.y - math.sin(math.rad(vehicleHeading)) * 2.0,
        vehicleCoords.z
    )

    -- Prüfen, ob der Spieler nahe genug ist
    local distance = #(playerCoords - backOffset)
    return distance <= 2.0
end

-- Funktion: Öffne den Kofferraum
RegisterCommand("trunk", function(source, args, rawCommand)
    local player = GetPlayerPed(-1)
    local vehicle = GetClosestVehicle(GetEntityCoords(player), 5.0, 0, 71)

    if vehicle ~= 0 and isPlayerBehindVehicle(player, vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)

        -- Erstelle Inventar für das Fahrzeug, falls noch nicht vorhanden
        if not trunkInventories[plate] then
            trunkInventories[plate] = {}
        end

        -- Sende das Kofferraum-Inventar an das NUI-Frontend
        local items = trunkInventories[plate]
        SetNuiFocus(true, true) -- UI aktivieren
        SendNUIMessage({
            type = "openInventory",
            items = items,
            maxItems = MAX_ITEMS
        })
    else
        TriggerEvent("chat:addMessage", { args = { "[Kofferraum]", "Du bist nicht hinter einem Fahrzeug!" } })
    end
end, false)

-- Event: Neues Item hinzufügen
RegisterNUICallback("addItem", function(data, cb)
    local player = GetPlayerPed(-1)
    local vehicle = GetClosestVehicle(GetEntityCoords(player), 5.0, 0, 71)

    if vehicle ~= 0 and isPlayerBehindVehicle(player, vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        local items = trunkInventories[plate]

        if #items < MAX_ITEMS then
            table.insert(items, data.itemName)
            cb({ success = true, items = items })
        else
            cb({ success = false, message = "Der Kofferraum ist voll!" })
        end
    else
        cb({ success = false, message = "Kein Fahrzeug in der Nähe!" })
    end
end)

-- Event: Item entfernen
RegisterNUICallback("removeItem", function(data, cb)
    local player = GetPlayerPed(-1)
    local vehicle = GetClosestVehicle(GetEntityCoords(player), 5.0, 0, 71)

    if vehicle ~= 0 and isPlayerBehindVehicle(player, vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        local items = trunkInventories[plate]

        if #items > 0 then
            table.remove(items, data.itemIndex)
            cb({ success = true, items = items })
        else
            cb({ success = false, message = "Der Kofferraum ist leer!" })
        end
    else
        cb({ success = false, message = "Kein Fahrzeug in der Nähe!" })
    end
end)

-- Event: Kofferraum schließen
RegisterNUICallback("closeInventory", function(data, cb)
    SetNuiFocus(false, false) -- UI deaktivieren
    cb("ok")
end)

-- Taste registrieren
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, TRUNK_KEY) then
            ExecuteCommand("trunk")
        end
    end
end)

