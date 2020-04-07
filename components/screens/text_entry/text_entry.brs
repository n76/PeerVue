' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

function init()
    m.clear_button  = m.top.FindNode("clear_button")
    m.enter_button  = m.top.FindNode("enter_button")
    m.keyboard      = m.top.FindNode("keyboard")
    m.server_label  = m.top.FindNode("server_label")
    m.clear_content = ""

    m.keyboard.text = m.clear_content
    
    m.top.observeField("visible", "onVisibleChange")
    m.clear_button.observeField("buttonSelected", "onClearButtonPressed")
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.keyboard.setFocus(true)
    end if
end sub

sub onClearButtonPressed()
    m.keyboard.text = m.clear_content
end sub

function setLabelText(newText)
    m.server_label.text = newText
end function

function setEnterButtonText(newText)
    m.enter_button.text = newText
end function

function setClearButtonText(newText)
    m.clear_button.text = newText
end function

function setClearContentText(newText)
    m.clear_content = newText
end function

function onKeyEvent(key, press) as Boolean
    handled = false

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
    end if
    return handled
end function
