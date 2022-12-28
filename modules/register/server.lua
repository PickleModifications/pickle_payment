function IsPlayerCashier(source, billing_info)
    if not billing_info or not billing_info.registerID or not billing_info.target or billing_info.target < 1 then return end
    local cfg = Config.Registers[billing_info.registerID]
    if not cfg then return end
    if not CanAccessGroup(source, cfg.AllowedGroups) then return ShowNotification(source, _L("register_group_denied")) end
    return true
end

RegisterNetEvent("pickle_payment:sendRegisterBill", function(billing_info, bill) 
    local source = source
    if (not IsPlayerCashier(source, billing_info)) then return end
    if bill.price < 0 then return end
    billing_info.id = "bill_"..math.random(1, 1000)..os.time()
    billing_info.source = source
    TriggerClientEvent("pickle_payment:receiveRegisterBill", billing_info.target, billing_info, bill)
    -- Billing Support
    TriggerEvent("pickle_payment:onBillReceived", billing_info, bill)
end)

RegisterNetEvent("pickle_payment:payRegisterBill", function(billing_info, bill) 
    local source = source
    if (not IsPlayerCashier(billing_info.source, billing_info)) then return end
    if bill.price < 0 then return end
    local cfg = Config.Registers[billing_info.registerID]
    local success, targetMsg, cashierMsg = AttemptTransaction(cfg.Payment, {bill = bill, target = source, cashier = billing_info.source})
    ShowNotification(billing_info.source, cashierMsg)
    ShowNotification(source, targetMsg)
    -- Billing Support
    TriggerEvent("pickle_payment:onBillPaid", billing_info, bill)
end)

RegisterNetEvent("pickle_payment:rejectRegisterBill", function(billing_info, bill) 
    local source = source
    if (not IsPlayerCashier(billing_info.source, billing_info)) then return end
    if bill.price < 0 then return end
    ShowNotification(source, _L("bill_reject_target", bill.price, billing_info.source))
    ShowNotification(billing_info.source, _L("bill_reject_source", bill.price, source))
    -- Billing Support
    TriggerEvent("pickle_payment:onBillRejected", billing_info, bill)
end)