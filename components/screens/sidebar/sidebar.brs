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
    contentNode = createObject("roSGNode","ContentNode")
    contentNode.appendChild(newCategory("settings",settings.strings))
    contentNode.appendChild(newCategory("search",settings.strings))
    m.category_list.content = contentNode
end function

function newCategory(key, localeStrings)
    node = createObject("roSGNode","category_node")
    title = localeStrings.lookup(key)
    if title = invalid then
        title = key
    end if
    node.title = title
    node.cat_type = key
    return node
end function
