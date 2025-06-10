Config = {}


-------------------------------------
-------------- DEBUG ----------------
-------------------------------------


Config.Debug = false --- Set it to true if you need for test and server print

-- CMD Debug:
-- /needsadd + [pipi or cacca or sonno] + [1-100]
-- /needsremove + [pipi or cacca or sonno] + [1-100]
-- /needreset 


-------------------------------------
------------ COMMANDS ---------------
-------------------------------------


Config.HudToggleCmd = "needshud"
Config.KeyMapCmd = false -- true if you want to bind some key

--- PEE
Config.PipiCmd = "pipi"
Config.PipiSuggestion = "Urinare"
Config.PipiKeyMap = "8"  -- if Config.KeyMapCmd is true

--- POOP
Config.CaccaCmd = "cacca"
Config.CaccaSuggestion = "Defecare"
Config.CaccaKeyMap = "9"  -- if Config.KeyMapCmd is true

--- SLEEP
Config.DormiCmd = "dormi"
Config.DormiSuggestion = "Riposare"
Config.DormiKeyMap = "0"  -- if Config.KeyMapCmd is true


-------------------------------------
------- Strings to translate --------
-------------------------------------


Config.Lang = {
    ---- Notification Strings
    NeedsTitleNotify = "ESSENTIAL NEEDS",
    PeeNotify = "ALERT! You need to pee! (",
    PooNotify = "ALERT! You need to poo! (",
    SleepNotify = "ALERT! You are exhausted, you need to sleep! (",
    LoadingNeeds = "Your needs are still loading...",
    ---- OX progressBar Strings
    PeeProgress = "You are peeing...",
    PooProgress = "You are pooping...",
    SleepProgress = "You are sleeping...",
    ---- Debug Strings
    ErrorDebugMsg = "ERROR: Invalid type! Use: pipi, cacca, sonno",
    SuccessDebugMsg = "DEBUG: %s changed by %d%% (Total: %d%%)",
    DReloadCmdSuggestion = "Reload player's needs from database",
    DReloadHelpSuggestion = "ID Player"
}


