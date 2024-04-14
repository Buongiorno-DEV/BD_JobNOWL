RegisterNetEvent("buongiornodev:daiitemprocesso")
AddEventHandler("buongiornodev:daiitemprocesso", function(lavoroId)
    local ID = source
    local lavoro = Config.Lavori[lavoroId]
    local jobName = ESX.GetPlayerData(ID).job.name
    if jobName == lavoro.jobRequired then
        exports.ox_inventory:RemoveItem(ID, lavoro.itemDaRaccogliere, lavoro.quantitaProcesso)
        exports.ox_inventory:AddItem(ID, lavoro.itemProcessato, lavoro.quantitaProcessoFrutto)
        TriggerClientEvent('esx:showNotification', ID, 'Materiale processato con successo')
    else
        TriggerClientEvent('esx:showNotification', ID, 'Devi essere ' .. lavoro.jobRequired .. ' per eseguire questa azione!')
    end
end)

RegisterNetEvent("buongiornodev:daiitemlavoro")
AddEventHandler("buongiornodev:daiitemlavoro", function(lavoroId)
    local ID = source
    local lavoro = Config.Lavori[lavoroId]
    local jobName = ESX.GetPlayerData(ID).job.name
    if jobName == lavoro.jobRequired then
        exports.ox_inventory:AddItem(ID, lavoro.itemDaRaccogliere, lavoro.quantitaRaccolta)
    else
        TriggerClientEvent('esx:showNotification', ID, 'Devi essere ' .. lavoro.jobRequired .. ' per eseguire questa azione!')
    end
end)

RegisterNetEvent("buongiornodev:venditalavoro")
AddEventHandler("buongiornodev:venditalavoro", function(lavoroId)
    local ID = source
    local lavoro = Config.Lavori[lavoroId]
    local jobName = ESX.GetPlayerData(ID).job.name
    if jobName == lavoro.jobRequired then
        local haMateriale = exports.ox_inventory:GetItemCount(ID, lavoro.itemProcessato)
        if haMateriale >= 1 then
            local prezzoTotale = lavoro.prezzoUnitario * haMateriale
            exports.ox_inventory:RemoveItem(ID, lavoro.itemProcessato, haMateriale)
            exports.ox_inventory:AddItem(ID, Config.ItemMoney, prezzoTotale)
        elseif haMateriale < 1 then
            TriggerClientEvent('esx:showNotification', source, 'Non hai abbastanza materiale da vendere!')
        end
    else
        TriggerClientEvent('esx:showNotification', ID, 'Devi essere ' .. lavoro.jobRequired .. ' per eseguire questa azione!')
    end
end)
