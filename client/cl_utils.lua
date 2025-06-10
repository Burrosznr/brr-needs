function MandaNotificheBisogniClient(title, text, type)
    lib.notify({
        title = title,
        description = text,
        type = type,
        duration = 5000,
        showDuration = true,
        position = 'center-right',
        sound = { 
            name = 'Click_Fail', 
            set = 'WEB_NAVIGATION_SOUNDS_PHONE'
        },
    })
end