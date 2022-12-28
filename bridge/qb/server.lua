if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

function RegisterCallback(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function Search(source, name)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if (name == "money") then
        return xPlayer.PlayerData.money['cash']
    elseif (name == "bank") then
        return xPlayer.PlayerData.money['cash'] -- If anyone knows how to get bank balance for QBCore, let me know.
    else
        local item = xPlayer.Functions.GetItemByName(name)
        if item ~= nil then 
            return item.amount
        else
            return 0
        end
    end
end

function AddItem(source, name, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if (name == "money") then
        return xPlayer.Functions.AddMoney("cash", amount)
    elseif (name == "bank") then
        return xPlayer.Functions.AddMoney("cash", amount) -- If anyone knows how to add to bank balance for QBCore, let me know.
    else
        return xPlayer.Functions.AddItem(name, amount)
    end
end

function RemoveItem(source, name, amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if (name == "money") then
        return xPlayer.Functions.RemoveMoney("cash", amount)
    elseif (name == "bank") then
        return xPlayer.Functions.RemoveMoney("cash", amount) -- If anyone knows how to remove from bank balance for QBCore, let me know.
    else
        return xPlayer.Functions.RemoveItem(name, amount)
    end
end 

function CanAccessGroup(source, data)
    if not data then return true end
    local pdata = QBCore.Functions.GetPlayer(source).PlayerData
    for k,v in pairs(data) do 
        if (pdata.job.name == k and pdata.job.grade.level >= v) then return true end
    end
    return false
end 

function GetIdentifier(source)
    local xPlayer = QBCore.Functions.GetPlayer(source).PlayerData
    return xPlayer.citizenid 
end

function AttemptTransaction(paymentCFG, data)
    local targetMoney = Search(data.target, "money")
    local targetBank = Search(data.target, "bank")
    local paymentMethod = "money"
    local bill = data.bill
    if targetMoney - bill.price < 0 then 
        if targetBank - bill.price >= 0 then 
            paymentMethod = "bank"
        else
            return false, _L("cant_afford_target", data.cashier), _L("cant_afford_source", data.target)
        end
    end
    if (paymentCFG.Type == "society") then 
        if paymentMethod == "money" then 
            RemoveItem(data.target, "money", bill.price)
            exports["qb-management"]:AddMoney(paymentCFG.Society, bill.price)
        elseif paymentMethod == "bank" then 
            RemoveItem(data.target, "bank", bill.price)
            exports["qb-management"]:AddMoney(paymentCFG.Society, bill.price)
        end
        return true, _L("success_target", bill.price, _L("payment_method_".. paymentMethod), data.cashier), _L("success_source", bill.price, _L("payment_method_".. paymentMethod), data.target)
    elseif (paymentCFG.Type == "player") then
        if paymentMethod == "money" then 
            RemoveItem(data.target, "money", bill.price)
            AddItem(data.cashier, "money", bill.price)
        elseif paymentMethod == "bank" then 
            RemoveItem(data.target, "bank", bill.price)
            AddItem(data.cashier, "bank", bill.price)
        end
        return true, _L("success_target", bill.price, _L("payment_method_".. paymentMethod), data.cashier), _L("success_source", bill.price, _L("payment_method_".. paymentMethod), data.target)
    end
end