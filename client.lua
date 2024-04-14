local markeriMostrati = {
    raccolta = false,
    processo = false,
    vendita = false,
    camion = false,
}

local ox = exports.ox_inventory

Citizen.CreateThread(function()
    for k, v in ipairs(Config.Lavori) do
        CreaMarker("raccolta", k, v.posizione_raccolta, "RACCOLTA " .. v.nome, function()
            CheckJob("raccolta", k, v.jobRequired, "buongiornodev:progressbarraccolta")
        end)        
        CreaMarker("processo", k, v.posizione_processo, "PROCESSO " .. v.nome, function()
            CheckJob("processo", k, v.jobRequired, "buongiornodev:cercaitemprocesso")
        end)
        CreaMarker("vendita", k, v.posizione_vendita, "VENDITA " .. v.nome, function()
            CheckJob("vendita", k, v.jobRequired, "buongiornodev:cercaitemvendita")
        end)
        CreaMarker("camion", k, v.posizione_camion, "CAMION " .. v.nome, function()
            CheckJob("camion", k, v.jobRequired, "buongiornodev:spawnacamion")
        end)
    end
end)

function CheckJob(markerType, lavoroId, requiredJob, eventToTrigger)
    local jobName = ESX.GetPlayerData(PlayerId()).job.name
    if jobName == requiredJob then
        TriggerEvent(eventToTrigger, lavoroId)
        markeriMostrati[markerType] = true
    else
        ESX.ShowNotification("Devi essere " .. requiredJob .. " per poter eseguire questa azione!")
    end
end


RegisterNetEvent("buongiornodev:spawnacamion")
AddEventHandler("buongiornodev:spawnacamion", function(lavoroId)
    local alCompletamento = function(annullato)
        SpawnCamion(lavoroId)
    end
    MostraProgressBar("Stai spawnando il camion", alCompletamento, Config.Durata)
end)

function SpawnCamion(lavoroId)
    local lavoro = Config.Lavori[lavoroId]
    local posizioneCamion = lavoro.posizione_camion
    local ID = source
    local jobName = ESX.GetPlayerData(ID).job.name

    if jobName == lavoro.jobRequired then
        if posizioneCamion then
            local modelloCamion = lavoro.modello_camion
            if IsModelInCdimage(modelloCamion) and IsModelAVehicle(modelloCamion) then
                RequestModel(modelloCamion)
                while not HasModelLoaded(modelloCamion) do
                    Citizen.Wait(0)
                end
                local vehicle = CreateVehicle(modelloCamion, posizioneCamion.x, posizioneCamion.y, posizioneCamion.z, posizioneCamion.heading, true, false)
                if DoesEntityExist(vehicle) then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleOnGroundProperly(vehicle)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    TriggerEvent("buongiornodev:camionspawnato", vehicle)
                else
                    print("Errore: Impossibile spawnare il camion.")
                end
            else
                print("Errore: Modello del camion non valido.")
            end
        else
            print("Errore: Posizione del camion non definita nella tabella dei lavori.")
        end
    else
        ESX.ShowNotification("Devi essere " .. lavoro.jobRequired .. " per poterlo fare!")
    end
end


function CreaMarker(categoria, indice, posizione, messaggio, azione)
    local nomeMarker = categoria .. "lavoro" .. indice
    if not markeriMostrati[categoria] then
        TriggerEvent('gridsystem:registerMarker', {
            name = nomeMarker,
            pos = posizione,
            scale = vector3(1.0, 1.0, 1.0),
            msg = messaggio,
            control = 'E',
            type = Config.Tipo,
            texture = Config.NomeTexture,
            color = { r = 255, g = 255, b = 255 },
            action = azione
        })
    end
end

-- PROGRESS BAR
function MostraProgressBar(etichetta, alCompletamento, durata)
    local opzioni = {
        Async = true,
        canCancel = true,
        cancelKey = 178,
        x = 0.5,
        y = 0.5,
        From = 0,
        To = 100,
        Duration = durata or 1000,
        Radius = 60,
        Stroke = 10,
        Cap = 'butt',
        Padding = 0,
        MaxAngle = 360,
        Rotation = 0,
        Width = 300,
        Height = 40,
        ShowTimer = true,
        ShowProgress = false,
        Easing = "easeLinear",
        Label = etichetta,
        LabelPosition = "bottom",
        Color = "rgba(255, 255, 255, 1.0)",
        BGColor = "rgba(0, 0, 0, 0.4)",
        Animation = {
            animationDictionary = "mini@repair",
            animationName = "fixing_a_ped",
        },
        DisableControls = {
            Vehicle = true
        },    
        onStart = function()
        end,
        onComplete = alCompletamento
    }
    
    if Config.rprogress then
        exports.rprogress:Custom(opzioni)
    else
        lib.progressCircle({
            duration = opzioni.Duration,
            position = 'middle',
            label = etichetta,
            useWhileDead = false,
            canCancel = opzioni.canCancel,
            disable = opzioni.DisableControls,
            anim = {
                dict = opzioni.Animation.animationDictionary,
                clip = opzioni.Animation.animationName
            }
        })
        if alCompletamento then
            alCompletamento()
        end
    end
end

RegisterNetEvent("buongiornodev:progressbarraccolta")
AddEventHandler("buongiornodev:progressbarraccolta", function(lavoroId)
    local alCompletamento = function(annullato)
        TriggerServerEvent("buongiornodev:daiitemlavoro", lavoroId)
    end
    MostraProgressBar("Stai lavorando", alCompletamento, Config.Durata)
end)

RegisterNetEvent("buongiornodev:progressbarvendita")
AddEventHandler("buongiornodev:progressbarvendita", function(lavoroId)
    local alCompletamento = function(annullato)
        TriggerServerEvent("buongiornodev:venditalavoro", lavoroId)
    end
    MostraProgressBar("Stai vendendo il materiale", alCompletamento, Config.Durata)
end)

RegisterNetEvent("buongiornodev:cercaitemprocesso")
AddEventHandler("buongiornodev:cercaitemprocesso", function(lavoroId)
    local ID = source
    local lavoro = Config.Lavori[lavoroId]
    local jobName = ESX.GetPlayerData(ID).job.name
    
    if jobName == lavoro.jobRequired then
        local alCompletamento = function(annullato)
            TriggerServerEvent("buongiornodev:daiitemprocesso", lavoroId)
        end
        local haMateriale = ox:Search('count', lavoro.itemDaRaccogliere) 
        if haMateriale < lavoro.quantitaProcesso then
            ESX.ShowNotification("Non hai abbastanza materiale da processare!")
        else
            MostraProgressBar("Stai processando il materiale", alCompletamento, Config.Durata)
        end
    else
        ESX.ShowNotification("Devi essere " .. lavoro.jobRequired .. " per eseguire questa azione!")
    end
end)

RegisterNetEvent("buongiornodev:cercaitemvendita")
AddEventHandler("buongiornodev:cercaitemvendita", function(lavoroId)
    local ID = source
    local lavoro = Config.Lavori[lavoroId]
    local jobName = ESX.GetPlayerData(ID).job.name
    
    if jobName == lavoro.jobRequired then
        local alCompletamento = function(annullato)
            TriggerServerEvent("buongiornodev:venditalavoro", lavoroId)
        end
        local haMateriale = ox:Search('count', lavoro.itemProcessato) 
        if haMateriale < 1 then
            ESX.ShowNotification("Non hai abbastanza materiale da vendere!")
        else
            MostraProgressBar("Stai vendendo il materiale", alCompletamento, Config.Durata)
        end
    else
        ESX.ShowNotification("Devi essere " .. lavoro.jobRequired .. " per eseguire questa azione!")
    end
end)
