' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

function init()
    m.clear_button  = m.top.FindNode("clear_button")
    m.enter_button  = m.top.FindNode("enter_button")
    m.keyboard      = m.top.FindNode("keyboard")
    m.prompt_text   = m.top.FindNode("prompt_text")
    m.server_name   = m.top.FindNode("server_name")
    m.server_url    = m.top.FindNode("server_url")

    m.instances     = []

    m.keyboard.text = ""
    
    m.top.observeField("visible", "onVisibleChange")
    m.clear_button.observeField("buttonSelected", "onClearButtonPressed")
end function

sub onVisibleChange()
    ?"[server_select] onVisibleChange() entry."
    if m.top.visible = true then
        ?"[server_select] became visible."
        current_server = get_setting("server","")
        current_name = serverName(current_server)
        ?"[server_select] onVisibleChange() name: ";current_name
        ?"[server_select] onVisibleChange() url: ";current_server
        if (current_name = "")
            current_server = ""
        end if
        ?"[server_select] onVisibleChange() name: ";current_name
        ?"[server_select] onVisibleChange() url: ";current_server
        m.server_url.text = current_server
        m.server_name.text = current_name
        m.keyboard.text = current_name
        m.keyboard.setFocus(true)
    end if
end sub

sub onClearButtonPressed()
    m.keyboard.text = ""
    updateServerInfo(m.keyboard.text)
end sub

function updateConfig(settings)
    m.prompt_text.text  = get_locale_string("server_url", settings.strings)
    m.enter_button.text = get_locale_string("update", settings.strings)
    m.clear_button.text = get_locale_string("clear", settings.strings)
    m.instances = settings.instances
end function

function onKeyEvent(key, press) as Boolean
    handled = false

    ? "[server_select] onKeyEvent", key, press
    if (press)
        if (key="down") and not m.enter_button.hasFocus()
            m.keyboard.setFocus(false)
            m.clear_button.setFocus(false)
            m.enter_button.setFocus(true)
            handled = true
        else if (key="up") and not m.keyboard.hasFocus()
            m.enter_button.setFocus(false)
            m.clear_button.setFocus(false)
            m.keyboard.setFocus(true)
            handled = true
        else if (key="right" or key="left") and m.enter_button.hasFocus()
            m.clear_button.setFocus(true)
            m.enter_button.setFocus(false)
            handled = true
        else if (key="right" or key="left") and m.clear_button.hasFocus()
            m.clear_button.setFocus(false)
            m.enter_button.setFocus(true)
            handled = true
        end if
    else if (key="OK")
        updateServerInfo(m.keyboard.text)
    end if
    return handled
end function

function serverName(url) as String
    for each inst in m.instances
        if url = inst.url
            return inst.name
        end if
    end for
    return ""
end function

function updateServerInfo(pattern)
    lc_pat = LCase(pattern)
    for each inst in m.instances
        match1 = Instr(1,LCase(inst.name),lc_pat)
        match2 = Instr(1,LCase(inst.alt_name),lc_pat)
        if (match1 > 0) or (match2 > 0)
            m.server_url.text = inst.url
            m.server_name.text = inst.name
            return 0
        end if
    end for
end function
