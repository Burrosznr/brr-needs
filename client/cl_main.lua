ESX = exports['es_extended']:getSharedObject()

local PlayerData = {}
local needs = { pipi = 0, cacca = 0, sonno = 0 }
local isDead = false
local isInMenu = false
local isDoingAction = false
local isLoaded = false 
local updateInterval = 60000 
local maxNeedValue = 100000 

local sleepEffectActive = false
local blurTransitionTime = 500
local blurActiveDuration = 2500 
local blurInactiveDuration = 5000 
local lastBlurChangeTime = 0
local isBlurred = false

function ForceBlurReset()
    TriggerScreenblurFadeOut(0)
    ClearTimecycleModifier()
    SetTimecycleModifierStrength(0.0)
    isBlurred = false
end

function ManageSleepBlur()
    if needs.sonno <= 80000 or isDead or isDoingAction then
        if isBlurred then
            ForceBlurReset()
        end
        return
    end

    local currentTime = GetGameTimer()
    local elapsed = currentTime - lastBlurChangeTime

    if isBlurred and elapsed >= blurActiveDuration then
        ForceBlurReset()
        lastBlurChangeTime = currentTime
    elseif not isBlurred and elapsed >= blurInactiveDuration then
        TriggerScreenblurFadeIn(blurTransitionTime)
        SetTimecycleModifier("hud_def_blur")
        TriggerScreenblurFadeOut(blurTransitionTime)
        isBlurred = true
        lastBlurChangeTime = currentTime
    end
end

function UpdateNeeds()
    if not isLoaded or isDead then 
        ForceBlurReset()
        return 
    end
    
    needs.pipi = math.min(needs.pipi + 100, maxNeedValue) 
    needs.cacca = math.min(needs.cacca + 100, maxNeedValue) 
    needs.sonno = math.min(needs.sonno + 500, maxNeedValue)
    
    updateNeedsHUD()

    if needs.pipi > 80000 then
        MandaNotificheBisogniClient(Config.Lang.NeedsTitleNotify, Config.Lang.PeeNotify ..math.floor(needs.pipi/1000).."%)", 'warning')
    end
    
    if needs.cacca > 80000 then
        MandaNotificheBisogniClient(Config.Lang.NeedsTitleNotify, Config.Lang.PooNotify ..math.floor(needs.cacca/1000).."%)", 'warning')
    end

    if needs.sonno > 80000 then
        if not sleepEffectActive then
            MandaNotificheBisogniClient(Config.Lang.NeedsTitleNotify, Config.Lang.SleepNotify ..math.floor(needs.sonno/1000).."%)", 'warning')
            sleepEffectActive = true
            lastBlurChangeTime = GetGameTimer() - blurInactiveDuration
        end
    else
        sleepEffectActive = false
        ForceBlurReset()
    end

    ManageSleepBlur()
    TriggerServerEvent('brr-needs:update', needs)
end

function StartPipiAction()
    if not isLoaded or isDoingAction or needs.pipi <= 0 then return end
    isDoingAction = true

    local playerPed = PlayerPedId()
    local isFemale = IsPedFemale(playerPed)

    local animDict, animClip
    if isFemale then
        animDict = "missfbi3ig_0"
        animClip = "shit_loop_trev" 
    else
        animDict = 'misscarsteal2peeing'
        animClip = 'peeing_loop'
    end

    LoadAnimDict(animDict)

    local success = lib.progressBar({
        duration = math.max(2000, math.min(10000, needs.pipi/1000 * 1000)),
        label = Config.Lang.PeeProgress,
        anim = {
            dict = animDict,
            clip = animClip,
            flag = 1
        }
    })

    if success then
        needs.pipi = 0
        TriggerServerEvent('brr-needs:update', needs)
        updateNeedsHUD() 
    end

    isDoingAction = false
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(5)
        end
    end
end

function IsPedFemale(ped)
    local model = GetEntityModel(ped)

    local femaleModels = {
        `mp_m_freemode_01`, 
        `mp_f_freemode_01`  
    }

    return model == femaleModels[2]
end

function StartCaccaAction()
    if not isLoaded or isDoingAction or needs.cacca <= 0 then return end
    isDoingAction = true
    
    local success = lib.progressBar({
        duration = math.max(2000, math.min(10000, needs.cacca/1000 * 1000)),
        label = Config.Lang.PooProgress,
        anim = {
            dict = "missfbi3ig_0",
            clip = "shit_loop_trev",
            flag = 1
        }
    })
    
    if success then
        needs.cacca = 0
        TriggerServerEvent('brr-needs:update', needs)
        updateNeedsHUD() 
    end
    
    isDoingAction = false
end

function StartSonnoAction()
    if not isLoaded or isDoingAction or needs.sonno <= 0 then return end
    isDoingAction = true
    
    local duration = math.max(5000, math.min(15000, needs.sonno/1000 * 1000))
    local success = lib.progressBar({
        duration = duration,
        label = Config.Lang.SleepProgress,
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict = 'timetable@tracy@sleep@',
            clip = 'idle_c',
            flag = 1
        },
    })

    if success then
        DoScreenFadeOut(800)
        Citizen.Wait(1000)
        DoScreenFadeIn(800)
        needs.sonno = 0
        TriggerServerEvent('brr-needs:update', needs)
        ForceBlurReset()
        updateNeedsHUD() 
    end
    
    isDoingAction = false
end

RegisterNetEvent('brr-needs:load')
AddEventHandler('brr-needs:load', function(loadedNeeds)
    needs = {
        pipi = tonumber(loadedNeeds.pipi) or 0,
        cacca = tonumber(loadedNeeds.cacca) or 0,
        sonno = tonumber(loadedNeeds.sonno) or 0
    }
    isLoaded = true
    updateNeedsHUD() 
end)

RegisterNetEvent('brr-needs:updateClient')
AddEventHandler('brr-needs:updateClient', function(newNeeds)
    if not isLoaded then return end
    needs = newNeeds
end)

AddEventHandler('esx:onPlayerDeath', function() 
    isDead = true 
    ForceBlurReset()
end)

AddEventHandler('esx:onPlayerSpawn', function() 
    isDead = false 
end)

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end
    
    TriggerServerEvent('brr-needs:requestSync')
    
    while not isLoaded do
        Citizen.Wait(1000)
    end
    
    while true do
        UpdateNeeds()
        updateNeedsHUD() 
        Citizen.Wait(updateInterval)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if sleepEffectActive then
            ManageSleepBlur()
        end
    end
end)

RegisterNetEvent('brr-needs:client:ModifyNeed')
AddEventHandler('brr-needs:client:ModifyNeed', function(needType, amount)
    if not needs[needType] then return end
    needs[needType] = math.max(0, math.min(needs[needType] + amount, maxNeedValue))
    TriggerServerEvent('brr-needs:update', needs)
end)

--==================================--
--============= CMDS ===============--
--==================================--

RegisterCommand(Config.PipiCmd, function()
    StartPipiAction()
end, false)

if Config.KeyMapCmd then
    RegisterKeyMapping(Config.PipiCmd, Config.PipiSuggestion, "keyboard", Config.PipiKeyMap)
end


RegisterCommand(Config.CaccaCmd, function()
    StartCaccaAction()
end, false)

if Config.KeyMapCmd then
    RegisterKeyMapping(Config.CaccaCmd, Config.CaccaSuggestion, "keyboard", Config.CaccaKeyMap)
end

RegisterCommand(Config.DormiCmd, function()
    StartSonnoAction()
end, false)

if Config.KeyMapCmd then
    RegisterKeyMapping(Config.DormiCmd, Config.DormiSuggestion, "keyboard", Config.DormiKeyMap)
end

--===================================--
--============= DEBUG ===============--
--===================================--

if Config.Debug == true then
    function DebugNeed(needType, amount)
        if not needs[needType] then
            MandaNotificheBisogniClient(Config.Lang.NeedsTitleNotify, Config.Lang.ErrorDebugMsg, 'warning')
            return
        end
        needs[needType] = math.max(0, math.min(needs[needType] + amount, maxNeedValue))
        TriggerServerEvent('brr-needs:update', needs)
        MandaNotificheBisogniClient(Config.Lang.NeedsTitleNotify, (Config.Lang.SuccessDebugMsg):format(needType:upper(), amount/1000, needs[needType]/1000), 'inform')
    end
end

if Config.Debug == true then
    RegisterCommand('needsadd', function(_, args)
        if #args < 2 then return end
        DebugNeed(args[1], tonumber(args[2])*1000)
    end, false)

    RegisterCommand('needsremove', function(_, args)
        if #args < 2 then return end
        DebugNeed(args[1], -tonumber(args[2])*1000)
    end, false)

    RegisterCommand('needsreset', function()
        TriggerServerEvent('brr-needs:satisfy')
    end, false)
end


--=================================--
--============= HUD ===============--
--=================================--

local hudVisible = true 

function updateNeedsHUD()
    if hudVisible then
        SendNUIMessage({
            action = "updateNeeds",
            pipi = math.floor(needs.pipi/1000),
            cacca = math.floor(needs.cacca/1000),
            sonno = math.floor(needs.sonno/1000)
        })
    end
end

local function showHUD()
    hudVisible = true
    SendNUIMessage({ action = "show" })
    updateNeedsHUD()
end

local function hideHUD()
    hudVisible = false
    SendNUIMessage({ action = "hide" })
end

RegisterCommand("togglehud", function()
    if hudVisible then
        hideHUD()
    else
        showHUD()
    end
end, false)

Citizen.CreateThread(function()
    Citizen.Wait(5000) 
    showHUD()
end)