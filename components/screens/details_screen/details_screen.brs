' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.thumbnail = m.top.FindNode("thumbnail")
    m.play_button = m.top.FindNode("play_button")
    m.top.observeField("visible", "onVisibleChange")
    m.play_button.setFocus(true)
end sub

function updateConfig(settings)
    m.play_button.text = get_locale_string("play", settings.strings)
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.play_button.setFocus(true)
    end if
end sub

sub OnContentChange(obj)
    item = obj.getData()
    '? "details_screen :";item
    if item.name <> Invalid then
        m.title.text = item.name
    else
        m.title.text = ""
    end if

    '
    ' remove markdown hyperlinks of the form
    '
    ' [some text](url)
    '
    if item.description <> Invalid then
        regex1 = createObject("roRegEx", "\([A-Za-z]+:\/\/[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_:%&;\?\#\/.=]+\)", "gi")
        regex2 = createObject("roRegEx", "[\[\]]", "gi")
        text = regex1.ReplaceAll(item.description,"")
        m.description.text = regex2.ReplaceAll(text,"")
    else
        m.description.text = ""
    end if

    m.thumbnail.uri = get_setting("server", "") + item.thumbnailPath
    'm.top.duration = item.duration
end sub

