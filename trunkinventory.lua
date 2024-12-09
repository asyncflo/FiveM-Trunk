-- Trunk Inventory Script for FiveM
-- Author: asyncflo

local trunkInventories = {} -- Speicher für die Kofferräume der Fahrzeuge

-- Maximale Anzahl der Items, die ein Kofferraum speichern kann
local MAX_ITEMS = 20

-- Distanz, innerhalb der man sich hinter dem Fahrzeug befinden muss
local MAX_DISTANCE = 2.0

-- Tastenkonfiguration
local TRUNK_KEY = 311 -- "K" auf der Tastatur (311 entspricht der K-Taste)

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
    return distance <= MAX_DISTANCE
end

-- Öffnen des Kofferraums
RegisterCommand("trunk", function(source, args, rawCommand)
    local player = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle == 0 then
        -- Kein Fahrzeug, in dem der Spieler sitzt, prüfen ob er vor einem Fahrzeug steht
        vehicle = GetClosestVehicle(GetEntityCoords(player), 5.0, 0, 71)
    end

    if vehicle ~= 0 and isPlayerBehindVehicle(player, vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)

        -- Erstelle ein Kofferraum-Inventar, falls noch nicht vorhanden
        if not trunkInventories[plate] then
            trunkInventories[plate] = {}
        end

        -- Öffne das Kofferraum-Menü
        TriggerEvent("openTrunkMenu", plate)
    else
        TriggerEvent("chat:addMessage", { args = { "[Kofferraum]", "Du bist nicht hinter einem Fahrzeug!" } })
    end
end, false)

-- Event: Öffne das Kofferraum-Inventar
RegisterNetEvent("openTrunkMenu")
AddEventHandler("openTrunkMenu", function(plate)
    local items = trunkInventories[plate]
    local player = GetPlayerPed(-1)

    -- Zeige das Kofferraum-Inventar (hier mit einfachem Chat-System)
    TriggerEvent("chat:addMessage", {
        args = { "[Kofferraum]", "Kofferraum geöffnet! Aktuelle Items: " .. json.encode(items or {}) }
    })

    -- Testweise Logik für das Hinzufügen eines Gegenstands
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if IsControlJustPressed(0, 38) then -- E-Taste zum Hinzufügen eines Testitems
                if #items < MAX_ITEMS then
                    table.insert(items, "Item" .. math.random(1, 100))
                    TriggerEvent("chat:addMessage", {
                        args = { "[Kofferraum]", "Gegenstand hinzugefügt. Aktuelle Anzahl: " .. #items }
                    })
                else
                    TriggerEvent("chat:addMessage", {
                        args = { "[Kofferraum]", "Der Kofferraum ist voll!" }
                    })
                end
            elseif IsControlJustPressed(0, TRUNK_KEY) then
                -- Kofferraum schließen
                TriggerEvent("chat:addMessage", { args = { "[Kofferraum]", "Kofferraum geschlossen." } })
                break
            end
        end
    end)
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
