Config = {}

-- Impostazioni generali
Config.Tipo = -1  -- Tipo di marker
Config.NomeTexture = "general" -- Nome della texutre
Config.rprogress = true  -- Vuoi utilizzare lo script rprogress? se impostato su false utilizzerà la progressBar di LIB
Config.Durata = 2000 -- Durata della progressBar per ogni processo
Config.ItemMoney = "money" -- Scegli il nome del tuo item dei soldi
-- Impostazioni dei lavori
Config.Lavori = {
    {
        nome = "Minatore",
        jobRequired = "minatore", -- Nome del lavoro richiesto
        posizione_raccolta = vector3(2243.6072, 5585.7251, 53.6662),
        posizione_processo = vector3(-1168.5908, -2050.8936, 14.4399),
        posizione_vendita = vector3(-1172.7941, -1572.6609, 4.6644),
        posizione_camion = vector3(2244.5996, 5580.0156, 53.2877), -- Aggiungi la posizione di spawn del camion
        modello_camion = "bati", -- Aggiungi il modello del camion
        itemDaRaccogliere = "marijuana_da_processare",
        itemProcessato = "marijuana_processata",
        quantitaProcesso = 2,
        prezzoUnitario = 300,
    },
    -- Puoi aggiungere quante lavori vuoi!
}