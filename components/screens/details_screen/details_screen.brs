' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.category      = m.top.FindNode("category")
    m.description   = m.top.FindNode("description")
    m.duration      = m.top.FindNode("duration")
    m.play_button   = m.top.FindNode("play_button")
    m.publishdate   = m.top.FindNode("publishdate")
    m.tags          = m.top.FindNode("tags")
    m.thumbnail     = m.top.FindNode("thumbnail")
    m.title         = m.top.FindNode("title")

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

    '
    '   Show duration as h:mm:ss
    '
    '   Seems like there should be a built-in function for formatting
    '   seconds to a string but I don't see it so we do it the hard way
    '
    sec = item.duration
    hr = (sec / 3600).ToStr().ToInt()
    sec = sec - (hr * 3600)
    min = (sec / 60).ToStr().ToInt()
    sec = sec - (min * 60)

    if (min > 9)
        min = min.toStr()
    else
        min = "0" + min.toStr()
    end if
    if (sec > 9)
        sec = sec.toStr()
    else
        sec = "0" + sec.toStr()
    end if
    m.duration.text = hr.toStr() + ":" + min + ":" + sec

    '
    '   Show video category
    '
    m.category.text = item.category.label

    '
    '   Show video tags
    '
    tagString = ""
    for each t in item.tags
        if (tagString <> "")
            tagString = tagString + ", "
        end if
        tagString = tagString + t
    end for
    m.tags.text = tagString

    '
    '   Show publish date.
    '
    date = CreateObject("roDateTime")
    date.FromISO8601String(item.publishedAt)
    m.publishdate.text = date.AsDateString("short-month-no-weekday")
end sub
