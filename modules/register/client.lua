function PayRegisterBill(billing_info, bill)
    TriggerServerEvent("pickle_payment:payRegisterBill", billing_info, bill)
end

function SendRegisterBill(billing_info, bill)
    TriggerServerEvent("pickle_payment:sendRegisterBill", billing_info, bill)
end

function RejectRegisterReceipt(billing_info, bill)
    TriggerServerEvent("pickle_payment:rejectRegisterBill", billing_info, bill)
end

function RejectRegisterBill(billing_info, bill)
    -- Doesn't need to do anything.
end

function SelectTargetMenu(cb)
    local players = GetPlayersInArea(nil, 3.0)
    if (players ~= nil and #players > 0) then 
        local options = {}
        for i=1, #players do
            options[#options + 1] = {label = GetPlayerName(players[i]) .. " (ID: " .. GetPlayerServerId(players[i]) .. ")", value = GetPlayerServerId(players[i])}
        end
        lib.registerMenu({
            id = 'pickle_payment_playerselect',
            title = _L("register_select_player"),
            position = 'top-right',
            options = options
        }, function(selected, scrollIndex, args)
            cb(options[selected].value)
        end)
        lib.showMenu("pickle_payment_playerselect")
    end
end

function OpenRegister(key)
    local register = Config.Registers[key]
    if not CanAccessGroup(register.AllowedGroups) then 
        return ShowNotification(_L("register_group_denied"))
    end
    SelectTargetMenu(function(targetID) 
        CreateBill({
            label = _L("register_title", register.Title, targetID),
            target = targetID,
            registerID = key
        })
    end)
end

RegisterNetEvent("pickle_payment:receiveRegisterBill", function(billing_info, bill) 
    if billing_info.source < 1 then return end
    CreateReceipt(billing_info, bill, true)
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k,v in pairs(Config.Registers) do 
            local dist = #(coords - v.Coords)
            if (dist < 20.0) then 
                wait = 0
                DrawMarker(2, v.Coords.x, v.Coords.y, v.Coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255, 255, 255, 127, false, true)
                if (dist < 0.5 and not ShowHelpNotification(_L("open_register")) and IsControlJustPressed(1, 51)) then 
                    OpenRegister(k)
                end
            end
        end
        Wait(wait)
    end
end)