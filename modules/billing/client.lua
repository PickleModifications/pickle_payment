local Billing = {}

function HideScreen() 
    SendNUIMessage({
        type = "hideScreen"
    })
    SetNuiFocus(false, false)
end

RegisterNUICallback("InteractReceipt", function()
    local receipt = Billing.CURRENT_RECEIPT
    local receipt_info = Billing.CURRENT_RECEIPT_INFO
    Billing.CURRENT_RECEIPT_BILL = nil
    Billing.CURRENT_RECEIPT_INFO = nil
    HideScreen()
    if receipt_info.registerID then 
        PayRegisterBill(receipt_info, receipt)
    end
end)

RegisterNUICallback("CreateBill", function(bill)
    local bill = bill
    local billing_info = Billing.CURRENT_BILL_INFO
    Billing.CURRENT_BILL_INFO = nil
    HideScreen()
    if billing_info.registerID then 
        SendRegisterBill(billing_info, bill)
    end
end)

RegisterNUICallback("RejectReceipt", function()
    local receipt = Billing.CURRENT_RECEIPT
    local receipt_info = Billing.CURRENT_RECEIPT_INFO
    Billing.CURRENT_RECEIPT_BILL = nil
    Billing.CURRENT_RECEIPT_INFO = nil
    HideScreen()
    if receipt_info.registerID then 
        RejectRegisterReceipt(receipt_info, receipt)
    end
end)

RegisterNUICallback("RejectBill", function()
    local bill = bill
    local billing_info = Billing.CURRENT_BILL_INFO
    Billing.CURRENT_BILL_INFO = nil
    HideScreen()
    if billing_info.registerID then 
        RejectRegisterBill(billing_info, bill)
    end
end)

function CreateBill(info)
    Billing.CURRENT_BILL_INFO = info
    SendNUIMessage({
        type = "showBilling",
        value = info
    })
    SetNuiFocus(true, true)
end

function CreateReceipt(info, receipt, paymentNeeded)
    Billing.CURRENT_RECEIPT_INFO = info
    Billing.CURRENT_RECEIPT = receipt
    SendNUIMessage({
        type = "showReceipt",
        value = {
            info = info,
            receipt = receipt,
            paymentNeeded = (paymentNeeded or false)
        }
    })
    SetNuiFocus(true, true)
end

RegisterNetEvent("pickle_payment:displayBill", function(billing_info, bill)
    if billing_info.source < 1 then return end
    CreateReceipt(billing_info, bill, false)
end)

exports("CreateReceipt", CreateReceipt)
exports("CreateBill", CreateBill)
exports("HideScreen", HideScreen)