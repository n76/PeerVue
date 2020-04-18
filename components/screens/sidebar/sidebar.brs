' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

function init()
    m.category_list=m.top.findNode("category_list")
    m.top.observeField("visible", "onVisibleChange")
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.category_list.setFocus(true)
    end if
end sub

function updateConfig(settings)
    m.strings = settings.strings

    contentNode = createObject("roSGNode","ContentNode")
    contentNode.appendChild(newCategory("Search...","search"))
    contentNode.appendChild(newCategory("Settings","settings"))
    contentNode.appendChild(newCategory("About","about"))
    m.category_list.content = contentNode
end function

function newCategory(key, cat_type)
    node = createObject("roSGNode","category_node")
    node.title = tr(key)
    node.cat_type = cat_type
    return node
end function
