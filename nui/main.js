// Shared Functions

const FORMATS = {
    Item: `           
        <div class="ab-item">
            <div>{ITEM_LABEL}</div>
            <div>{ITEM_PRICE}</div>
        </div>
    `,
    EditingItem: `
        <div class="ab-input">
            <div>
                <label for="item-label">Item</label>
                <input name="item-label" type="text" value="{ITEM_LABEL}">
            </div>
            <div>
                <label for="item-price">Price</label>
                <input name="item-price" type="number" value="{ITEM_PRICE}">
            </div>
            <div class="ab-input-options">
                <i class="fa-solid fa-floppy-disk"></i>
                <i class="fa-solid fa-trash"></i>
            </div>
        </div>
    `,
    DisplayEditItem: `
        <div class="ab-edit-display">
            <div>{ITEM_LABEL}</div>
            <div>{ITEM_PRICE}</div>
            <div class="ab-input-options">
                <i class="fa-solid fa-pen"></i>
                <i class="fa-solid fa-trash"></i>
            </div>
        </div>
    `
}

function FormatElement(format, data) {
    var format = FORMATS[format];
    for (const [key, value] of Object.entries(data)) {
        format = format.replace(key, value);
    }
    return format;
}

function FormatPrice(val)  {
    const formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    });
    return formatter.format(val);
}

function PriceToInput(val)  {
    return parseFloat(val.replace("$", "").replace(/,/g, ''));
}

function HideScreen() {
    $("#app-receipt").css("display", "none")
    $("#app-billing").css("display", "none")
}

// Billing App

function GetEntries() {
    var entries = $("#ab-middle").children()
    var list = []
    for (var i=0; i<entries.length; i++) {
        var entry = entries.eq(i)
        if (entry.hasClass("ab-edit-display")) {
            var name = entry.children().eq(0).html()
            var price = PriceToInput(entry.children().eq(1).html())
            list.push({name: name, price: price});
        }
    }
    return list;
}

function GetTotal() {
    var entries = $("#ab-middle").children()
    var total = 0;
    for (var i=0; i<entries.length; i++) {
        var entry = entries.eq(i)
        if (entry.hasClass("ab-edit-display")) {
            var price = PriceToInput(entry.children().eq(1).html())
            total += price
        }
    }
    return total;
}

function UpdateTotal() {
    var total = GetTotal();
    $("#ab-totalprice").html(`<b>Total: ${FormatPrice(total)}</b>`);
}

function EditListener(element) {
    UpdateTotal();
    $(element.find(".ab-input-options i")).click(function() {
        var parent = $(this).parent().parent()
        var index = $(this).index()
        if (index == 0) { // Edit / Save
            if (parent.hasClass('ab-edit-display')) {
                var content = FormatElement("EditingItem", {
                    "{ITEM_LABEL}": parent.children().eq(0).html(), 
                    "{ITEM_PRICE}": PriceToInput(parent.children().eq(1).html())
                });
                parent.before(content)
                EditListener(parent.prev())
                parent.remove()
            }
            else if (parent.hasClass('ab-input')) {
                var inputs = parent.children().children("input");
                var content = FormatElement("DisplayEditItem", {
                    "{ITEM_LABEL}": inputs.eq(0).val(), 
                    "{ITEM_PRICE}": FormatPrice(inputs.eq(1).val())
                });
                parent.before(content)
                EditListener(parent.prev())
                parent.remove()
            }
        }
        else if (index == 1) { // Delete
            parent.remove()
            UpdateTotal();
        }
    })
}

function GenerateBillData() {
    var data = {
        price: GetTotal(),
        entries: GetEntries()
    }
    return data
}

function DisplayBilling(bill) {
    $("#app-billing").css("display", "flex")
    $("#app-receipt").css("display", "none")
    $("#ab-top").html(`<div id="ab-rejectbill"> <i class="fa-solid fa-x"></i> </div><h3>${bill.label}</h3>`)
    $("#ab-rejectbill").click(function() {
        $.post(`https://pickle_payment/RejectBill`, JSON.stringify({}))
    })
    $("#ab-middle").html(`<div class="ab-input-button">Add Item</div>`)
    $(".ab-input-button").click(function() {
        var content = FormatElement("EditingItem", {
            "{ITEM_LABEL}": "Item Name", 
            "{ITEM_PRICE}": "0"
        });
        $(".ab-input-button").before(content)
        EditListener($(".ab-input-button").prev())
    })
}

function InitializeBilling() {
    $("#ab-sendbill").click(function() {
        var bill = GenerateBillData()
        $.post(`https://pickle_payment/CreateBill`, JSON.stringify(bill))
    })
}

// Receipt App

function DisplayReceipt(data) {
    var info = data.info;
    var receipt = data.receipt;
    var paymentNeeded = data.paymentNeeded
    $("#app-receipt").css("display", "flex")
    $("#app-billing").css("display", "none")
    var content = ""
    for (var i=0; i<receipt.entries.length; i++) {
        var entry = receipt.entries[i]
        content += FormatElement("Item", {
            "{ITEM_LABEL}": entry.name, 
            "{ITEM_PRICE}": FormatPrice(entry.price)
        })
    }
    $("#ar-top").html(`<div id="ar-rejectbill"> <i class="fa-solid fa-x"></i> </div><h3>${info.label}</h3>`)
    $("#ar-rejectbill").click(function() {
        $.post(`https://pickle_payment/RejectReceipt`, JSON.stringify({}))
    })
    $("#ar-middle").html(content)
    $("#ar-totalprice").html(`<b>Total Price: ${FormatPrice(receipt.price)}</b>`)
    if (paymentNeeded) {
        $("#ar-bottom").show()
    }
    else {
        $("#ar-bottom").hide()
    }
}

function InitializeReceipts() {
    $("#ar-paybill").click(function() {
        $.post(`https://pickle_payment/InteractReceipt`, JSON.stringify({}))
    })
}

// Script Initialized

$(document).ready(function() {
    InitializeBilling()
    InitializeReceipts()
})

window.addEventListener("message", function(ev) {
    if (ev.data.type == "showReceipt") {
        DisplayReceipt(ev.data.value)
    }
    else if (ev.data.type == "showBilling") {
        DisplayBilling(ev.data.value)
    }
    else if (ev.data.type == "hideScreen") {
        HideScreen()
    }
})