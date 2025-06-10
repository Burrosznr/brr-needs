ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    MySQL.ready(function()
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `user_needs` (
                `identifier` varchar(60) NOT NULL,
                `pipi` int(11) NOT NULL DEFAULT 0,
                `cacca` int(11) NOT NULL DEFAULT 0,
                `sonno` int(11) NOT NULL DEFAULT 0,
                PRIMARY KEY (`identifier`),
                UNIQUE KEY `identifier` (`identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]], {}, function(success)
            if success then
                if Config.Debug == true then
                    print('[NEEDS] Tabella user_needs creata/verificata con successo')
                end
            else
                if Config.Debug == true then
                    print('[NEEDS] Errore nella creazione della tabella user_needs')
                end
            end
        end)
    end)
end)

function LoadPlayerNeeds(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        if Config.Debug == true then
            print(('[NEEDS] ERRORE: Player non trovato (source: %s)'):format(source))
        end
        return {pipi = 0, cacca = 0, sonno = 0}
    end

    local success, result = pcall(function()
        return MySQL.Sync.fetchAll('SELECT pipi, cacca, sonno FROM user_needs WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })
    end)

    if not success then
        if Config.Debug == true then
            print(('[NEEDS] ERRORE Database per %s: %s'):format(xPlayer.identifier, result))
        end
        return {pipi = 0, cacca = 0, sonno = 0}
    end

    if result and result[1] then
        local loadedNeeds = {
            pipi = tonumber(result[1].pipi) or 0,
            cacca = tonumber(result[1].cacca) or 0,
            sonno = tonumber(result[1].sonno) or 0
        }
        if Config.Debug == true then
            print(('[NEEDS] Bisogni caricati per %s: %s'):format(xPlayer.identifier, json.encode(loadedNeeds)))
        end
        return loadedNeeds
    else
        local insertSuccess = MySQL.Sync.execute(
            'INSERT INTO user_needs (identifier, pipi, cacca, sonno) VALUES (@identifier, 0, 0, 0)', 
            {['@identifier'] = xPlayer.identifier}
        )
        
        if insertSuccess then
            if Config.Debug == true then
                print(('[NEEDS] Creato nuovo record per %s'):format(xPlayer.identifier))
            end
        else
            if Config.Debug == true then
                print(('[NEEDS] ERRORE creazione record per %s'):format(xPlayer.identifier))
            end
        end
        
        return {pipi = 0, cacca = 0, sonno = 0}
    end
end

function SavePlayerNeeds(source, needs)
    if not source or not needs then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        if Config.Debug == true then
            print(('[NEEDS] ERRORE Salvataggio: Player non trovato (source: %s)'):format(source))
        end
        return
    end

    needs.pipi = tonumber(needs.pipi) or 0
    needs.cacca = tonumber(needs.cacca) or 0
    needs.sonno = tonumber(needs.sonno) or 0

    MySQL.Async.execute([[
        INSERT INTO user_needs (identifier, pipi, cacca, sonno) 
        VALUES (@identifier, @pipi, @cacca, @sonno)
        ON DUPLICATE KEY UPDATE 
        pipi = VALUES(pipi), 
        cacca = VALUES(cacca), 
        sonno = VALUES(sonno)
    ]], {
        ['@identifier'] = xPlayer.identifier,
        ['@pipi'] = needs.pipi,
        ['@cacca'] = needs.cacca,
        ['@sonno'] = needs.sonno
    }, function(rowsChanged)
        if rowsChanged then
            if Config.Debug == true then
                print(('[NEEDS] Bisogni salvati per %s: %s'):format(xPlayer.identifier, json.encode(needs)))
            end
        else
            if Config.Debug == true then
                print(('[NEEDS] ERRORE Salvataggio per %s'):format(xPlayer.identifier))
            end
            Citizen.SetTimeout(5000, function()
                SavePlayerNeeds(source, needs)
            end)
        end
    end)
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local needs = LoadPlayerNeeds(playerId)
    TriggerClientEvent('brr-needs:load', playerId, needs)
end)

RegisterNetEvent('brr-needs:requestSync', function()
    local src = source
    local needs = LoadPlayerNeeds(src)
    TriggerClientEvent('brr-needs:load', src, needs)
end)

RegisterNetEvent('brr-needs:update', function(needs)
    SavePlayerNeeds(source, needs)
end)

RegisterNetEvent('brr-needs:satisfy', function()
    SavePlayerNeeds(source, {pipi = 0, cacca = 0, sonno = 0})
end)

CreateThread(function()
    while true do
        MySQL.Async.fetchScalar('SELECT 1', {}, function(result)
            if not result then
                if Config.Debug == true then
                    print('[NEEDS] ATTENZIONE: Problema di connessione al database')
                end
            end
        end)
        Wait(30000) 
    end
end)


if Config.Debug == true then
    ESX.RegisterCommand('needs_reload', 'admin', function(xPlayer, args, showError)
        local target = args.player or xPlayer.source
        local needs = LoadPlayerNeeds(target)
        TriggerClientEvent('brr-needs:load', target, needs)
        MandaNotificheBisogniServer(source, Config.Lang.NeedsTitleNotify, (Config.Lang.SuccessDebugMsg):format(needType:upper(), amount/1000, needs[needType]/1000), 'inform')
    end, false, {help = Config.Lang.DReloadCmdSuggestion, validate = false, arguments = {{name = 'player', help =  Config.Lang.DReloadHelpSuggestion, type = 'player'}}}
    )
end

