local sharedItems = exports['qbr-core']:GetItems()

RegisterNetEvent('MR_CornerSelling:server:robCornerDrugs')
AddEventHandler('MR_CornerSelling:server:robCornerDrugs', function(item, amount, price)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(item)

        if item ~= nil then
            AvailableDrugs[#AvailableDrugs+1] = {
                item = item.name,
                amount = item.amount,
                label = item.namme
            }
        end
    end

    TriggerClientEvent('MR_CornerSelling:client:refreshAvailableDrugs', src, AvailableDrugs)
end)

RegisterNetEvent('MR_CornerSelling:server:sellCornerDrugs')
AddEventHandler('MR_CornerSelling:server:sellCornerDrugs', function(item, amount, price)
local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    local hasItem = Player.Functions.GetItemByName(item)
    local AvailableDrugs = {}
    --if hasItem.amount >= amount then

        --TriggerClientEvent('QBCore:Notify', src, 'Offer accepted!', 'success')
        Player.Functions.RemoveItem(item, amount)
        Player.Functions.AddMoney('cash', price, "sold-cornerdrugs")
        --TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")

        for i = 1, #Config.CornerSellingDrugsList, 1 do
            local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

            if item ~= nil then
                AvailableDrugs[#AvailableDrugs+1] = {
                    item = item.name,
                    amount = item.amount,
                    label = item.name
                }
            end
        end

        TriggerClientEvent('qb-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
    --else
        --TriggerClientEvent('qb-drugs:client:cornerselling', src)
    --end
end)

exports['qbr-core']:CreateCallback('MR_CornerSelling:server:cornerselling:getAvailableDrugs', function(source, cb)
    local AvailableDrugs = {}
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if Player then
        for i = 1, #Config.CornerSellingDrugsList, 1 do
            local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

            if item ~= nil then
                AvailableDrugs[#AvailableDrugs+1] = {
                    item = item.name,
                    amount = item.amount,
                    label = item.name
                }
            end
        end
        if next(AvailableDrugs) ~= nil then
            cb(AvailableDrugs)
        else
            cb(nil)
        end
    end
end)