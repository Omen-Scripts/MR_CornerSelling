local cornerselling = false
local hasTarget = false
local lastPed = {}
local availableDrugs = {}
local startLocation = nil
local stealingPed = nil
local stealData = {}
local drugAmount = nil
local EntityCoords = nil

RegisterCommand('newskin', function(source)
    EntityCoords = GetEntityCoords(source)
    TriggerEvent('qbr-clothing:client:newPlayer')
end)

RegisterCommand('selldrugs', function(source)
    TriggerEvent('MR_CornerSelling:StartSell')
end)

RegisterCommand('moveme', function(source)
    SetEntityCoords(PlayerPedId(),EntityCoords)
end)

RegisterNetEvent('MR_CornerSelling:StartSell')
AddEventHandler('MR_CornerSelling:StartSell', function()
    exports['qbr-core']:TriggerCallback('MR_CornerSelling:server:cornerselling:getAvailableDrugs', function(result)
        if result ~= nil then
            cornerselling = false
            availableDrugs = result
            if not cornerselling then
                cornerselling = true
                startLocation = GetEntityCoords(PlayerPedId())
            else
                cornerselling = false
            end
        else
        end
    end, 'pshroom')
end)


RegisterNetEvent('MR_CornerSelling:refreshAvailableDrugs')
AddEventHandler('MR_CornerSelling:refreshAvailableDrugs', function(items)
    availableDrugs = items
    if #availableDrugs <= 0 then
        cornerselling = false
    end
end)

SellToPed = function(ped)
    hasTarget = true
    for i = 1, #lastPed, 1 do
        if lastPed[i] == ped then
            hasTarget = false
            return
        end
    end

    local successChance = math.random(1,20)

    local scamChance = math.random(1,5)

    local getRobbed = math.random(1,20)

    if successChance <= 7 then
        hasTarget = false
    elseif successChance >= 19 then
        --Notify Police Here
        return
    end
    local drugType = math.random(1, #availableDrugs)
    local drugAmount = math.random(1, availableDrugs[drugType].amount)

    if drugAmount > 4 then
        drugAmount = math.random(4,6)
    end

    currentOfferDrug = availableDrugs[drugType]

    local ddata = Config.DrugsPrice[currentOfferDrug.item]
    local randomPrice = math.random(ddata.min, ddata.max) * drugAmount
    if scamChance == 5 then
        RandomPrice = math.random(1,2) * drugAmount
    end

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)

    local coords = GetEntityCoords(PlayerPedId(), true)
    local pedCoords = GetEntityCoords(ped)
    local pedDist = #(coords - pedCoords)

    if getRobbed == 18 or getRobbed == 9 then
        TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
    else
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
    end

    while pedDist > 1.5 do
        coords = GetEntityCoords(PlayerPedId(), true)
        pedCoords = GetEntityCoords(ped)
        if getRobbed == 18 or getRobbed == 9 then
            TaskGoStraightToCoord(ped, coords, 15.0, -1, 0.0, 0.0)
        else
            TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        end
        TaskGoStraightToCoord(ped, coords, 1.2, -1, 0.0, 0.0)
        pedDist = #(coords - pedCoords)

        Citizen.Wait(100)
    end

    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)
    --TaskStartScenarioInPlace(ped, --[[ADD ANIMATION DICT]], 0, false)

    if hasTarget then
        while pedDist < 1.5 and not IsPedDeadOrDying(ped) do
            coords = GetEntityCoords(PlayerPedId(), true)
            pedCoords = GetEntityCoords(ped)
            pedDist = #(coords - pedCoords)
            if getRobbed == 18 or getRobbed == 9 then
                TriggerServerEvent('MR_CornerSelling:server:robCornerDrugs', availableDrugs[drugType].item, drugAmount)
                --Notification of robbery for player
                stealingPed = ped
                stealData = {
                    item = availableDrugs[drugType].item,
                    amount = drugAmount,
                }
                hasTarget = false
                local rand = (math.random(6,9) / 100) + 0.3
                local rand2 = (math.random(6,9) / 100) + 0.3
                if math.random(10) > 5 then
                    rand = 0.0 - rand
                end
                if math.random(10) > 5 then
                    rand2 = 0.0 - rand2
                end
                local moveto = GetEntityCoords(PlayerPedId())
                local movetoCoords = {x = moveto.x + math.random(100, 500), y = moveto.y + math.random(100,500), z = moveto.z, }
                ClearPedTasks(ped)
                TaskGoStraightToCoord(ped, movetoCoords.x, movetoCoords.y, movetoCoords.z, 15.0, -1, 0.0, 0.0)
                lastPed[#lastPed+1] = ped
                break
            else
                if pedDist < 1.5 and cornerselling then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 0.3, "SellDrugs $" .. randomPrice)
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 0.15, "[G] Confirm")
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z, "[B] Decline")
                    if IsControlJustPressed(0, 0x5415BE48) then
                        TriggerServerEvent('MR_CornerSelling:server:sellCornerDrugs', availableDrugs[drugType].item, drugAmount, randomPrice)
                        SellAnim()

                        SetPedKeepTask(ped, false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasks(ped)
                        lastPed[#lastPed+1] = ped
                        break
                    end

                    if IsControlJustPressed(0,0x4CC0E2FE) then
                        hasTarget = false
                        SetPedKeepTask(ped,false)
                        SetEntityAsNoLongerNeeded(ped)
                        ClearPedTasksImmediately(ped)
                        lastPed[#lastPed+1] = ped
                        break
                    end
                else
                    hasTarget = false
                    pedDist = 5
                    SetPedKeepTask(ped,false)
                    SetEntityAsNoLongerNeeded(ped)
                    ClearPedTasks(ped)
                    lastPed[#lastPed+1] = ped
                    cornerselling = false
                end
            end
            Citizen.Wait(3)
        end
        Citizen.Wait(math.random(4000,7000))
    end
end

function SellAnim()
    local dict = "script_mp@emotes@handshake@male@unarmed@upper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    --local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")
    --local modelHash = GetHashKey("p_shovel01x")
    --LoadModel(modelHash)
    --entity2 = CreateObject(modelHash, coords.x+0.3, coords.y,coords.z, true, false, false)
    --SetEntityVisible(entity2, true)
    --SetEntityAlpha(entity2, 255, false)
    -- Citizen.InvokeNative(0x283978A15512B2FE, entity2, true)
    --SetModelAsNoLongerNeeded(modelHash)
    --AttachEntityToEntity(entity2,ped, boneIndex, 0.2, 0.0, -0.2, -100.0, -50.0, 0.0, false, false, false, true, 2, true)

    TaskPlayAnim(ped, dict, "intro", 1.0, 8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(1200)
    ClearPedTasks(ped)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        sleep = 1000
        if stealingPed ~= nil and stealData ~= nil then
            sleep = 0
            if IsEntityDead(stealingPed) then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local pedpos = GetEntityCoords(stealingPed)
                if #(pos - pedpos) < 1.5 then
                    DrawText3D(pedpos.x, pedpos.y, pedpos.z, "Pick up drugs")
                    if IsControlJustPressed(0, 0x018C47CF) then
                        ---INSERT PICKUP ANIMATION

                        TriggerServerEvent('MR_CornerSelling:server:AddItem', stealData.item, stealData.amount)
                        stealingPed = nil
                        stealData = {}
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        sleep = 1000
        if cornerselling then
            sleep = 0
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            if not hasTarget then
                local PlayerPeds = {}
                if next(PlayerPeds) == nil then
                    for _, player in ipairs(GetActivePlayers()) do
                        local ped = GetPlayerPed(player)
                        PlayerPeds[#PlayerPeds+1] = ped
                    end
                end
                local closestPed, closestDistance = exports['qbr-core']:GetClosestPed(coords, PlayerPeds)
                if closestDistance < 15.0 and closestPed ~= 0 and not IsPedInAnyVehicle(closestPed) then
                    SellToPed(closestPed)
                end
            end
            local startDist = #(startLocation - coords)
            if startDist > 10 then
                toFarAway()
            end
        end
        Citizen.Wait(sleep)
    end
end)

toFarAway = function()
    cornerselling = false
    hasTarget = false
    startLocation = nil
    availableDrugs = {}
    Citizen.Wait(5000)
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)

    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end