function init()
    m.top.observeField("visible", "onVisibleChange")
    m.keyboard = m.top.FindNode("keyboard")
    m.enter_button = m.top.FindNode("enter_button")
    m.server_label = m.top.FindNode("server_label")
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.keyboard.setFocus(true)
    end if
end sub

function updateConfig(settings)
    m.keyboard.text = settings.server

    m.server_label.text = get_locale_string("server_url", settings.strings)
    m.enter_button.text = get_locale_string("update", settings.strings)

end function

function onKeyEvent(key, press) as Boolean
    ? "[server_setup] onKeyEvent", key, press
    handled = false

    if (press)
        if (key="down") and not m.enter_button.hasFocus()
            m.keyboard.setFocus(false)
            m.enter_button.setFocus(true)
            ? "[server_setup] onKeyEvent: Keyboard had focus"
            handled = true
        else if (key="up") and not m.keyboard.hasFocus()
            m.enter_button.setFocus(false)
            m.keyboard.setFocus(true)
            ? "[server_setup] onKeyEvent: Keyboard had focus"
            handled = true
        end if
    end if
    return handled
end function
