' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

function init()
    m.about_info    = m.top.findNode("about_info")
    m.category_list = m.top.findNode("category_list")
    m.language_list = m.top.findNode("language_list")
    m.setting_list  = m.top.findNode("setting_list")

    m.about_info.visible    = false
    m.language_list.visible = false
    m.setting_list.visible  = false

    m.current_category_cat_type = ""
    m.current_setting_cat_type  = ""
    m.top.selected_item = "ignore"

    m.iso639_1 = [{"title":"Any Language","cat_type":"none"},{"title":"Use Roku Setting","cat_type":"roku"}]

    '
    '   Setting up about text here as I can't figure out how to put line breaks
    '   into an attribute in the XML
    '
    crlf = chr(13)+chr(10)
    about_text = tr("PeerVue is an open source channel to view content hosted by a PeerTube instance.") + " "
    about_text = about_text + tr("Source for this channel is at https://github.com/n76/PeerVue") + crlf + crlf
    about_text = about_text + tr("For information about PeerTube see https://https://joinpeertube.org/") + crlf + crlf
    about_text = about_text + tr("UKIJCKJ font") + " ©2017 Tursun Sultan https://fontlibrary.org/en/font/ukij-cjk" + crlf + crlf
    about_text = about_text + tr("Search and gear icons") +  " ©2020 Remix-Design https://github.com/Remix-Design/RemixIcon" + crlf + crlf
    m.about_info.text = about_text

    m.top.observeField("visible", "onVisibleChange")
end function

function updateConfig(settings)
    '
    '   First item will be "any language"
    '   Second item will be "Roku setting"
    '
    m.iso639_1 = [{"title":"Any Language","cat_type":"none"},{"title":"Use Roku Setting","cat_type":"roku"}]

    keys = settings.iso639_1.Keys()
    for each lg in keys
        item = {}
        item.title = settings.iso639_1.Lookup(lg).NativeName
        item.cat_type = lg
        '? "[sidebar] updateConfig() lg: ";item
        m.iso639_1.push(item)
    end for
end function

function onKeyEvent(key, press) as Boolean
    handled = false

    if (press)
        m.top.selected_item = "ignore"
        if ((key="right") or (key="OK"))
            if (m.category_list.hasFocus())
                if (m.current_category_cat_type = "xSettings")
                    m.setting_list.setFocus(true)
                    handled = true
                else if (m.current_category_cat_type = "search")
                    m.top.selected_item = "search"
                    handled = true
                else if (m.current_category_cat_type = "xAbout")
                    handled = true
                end if
            else if (m.setting_list.hasFocus())
                if (m.current_setting_cat_type = "server")
                    m.top.selected_item = "server"
                    handled = true
                else if ((m.current_setting_cat_type = "xLanguage"))
                    m.language_list.setFocus(true)
                    handled = true
                end if
            else if (m.language_list.hasFocus())
                handled = true
            end if
        else if ((key="left") or (key="back"))
            if (m.setting_list.hasFocus())
                m.category_list.setFocus(true)
                m.language_list.visible = false
                handled = true
            else if (m.language_list.hasFocus())
                setNewLanguage()
                m.setting_list.setFocus(true)
                handled = true
            end if
        end if
    end if
    return handled
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.category_list.setFocus(true)
        m.category_list.focusRow = 0
        m.setting_list.focusRow = 0
    end if
end sub

sub onCategoryFocused(obj)
    category_type = m.category_list.content.getChild(m.category_list.itemFocused).cat_type

    m.current_category_cat_type = category_type
    m.setting_list.visible  = (category_type = "xSettings")
    m.about_info.visible    = (category_type = "xAbout")

    if (m.setting_list.visible = false)
        m.language_list.visible = false
    end if
end sub

sub onSettingFocused(obj)
    category_type = m.setting_list.content.getChild(m.setting_list.itemFocused).cat_type

    m.current_setting_cat_type = category_type
    m.language_list.visible = (category_type = "xLanguage")

    if (m.language_list.visible)
        setupLanguageList()
    end if
end sub

sub setupLanguageList()

    cur_lg = get_setting("language")
    if (cur_lg = invalid)
        cur_lg = "roku"
    end if
    this_index = 0
    select_index = -1

    content = createObject("roSGNode","ContentNode")
    content.id = "languages"

    for each item in m.iso639_1
        node = content.createChild("category_node")
        node.title = tr(item.title)
        node.cat_type = item.cat_type
        if (cur_lg = item.cat_type)
            select_index = this_index
        end if
        this_index = this_index + 1
    end for

    m.language_list.content = content
    m.language_list.checkedItem = select_index
    m.language_list.jumpToItem = select_index
end sub

sub setNewLanguage()
    old_iso639_1 = get_language()
    checkedIndex = m.language_list.checkedItem
    item = m.language_list.content.getChild(checkedIndex)
    set_setting("language", item.cat_type)
    new_iso639_1 = get_language()
    if (old_iso639_1 <> new_iso639_1)
        m.top.language_set = new_iso639_1
    end if
end sub
