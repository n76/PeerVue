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
    contentNode.appendChild(newCategory("settings"))
    contentNode.appendChild(newCategory("search"))
    m.category_list.content = contentNode
end function

function newCategory(key)
    node = createObject("roSGNode","category_node")
    node.title = get_locale_string(key, m.strings)
    node.cat_type = key
    return node
end function
