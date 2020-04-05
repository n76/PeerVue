sub init()
    m.rowList = m.top.FindNode("rowList")
    m.top.observeField("visible", "onVisibleChange")

    m.rowList       =   m.top.findNode("rowList")
    m.summary       =   m.top.findNode("summary")
    m.background    =   m.top.findNode("Background")
    m.overhang      =   m.top.findNode("MyOverhang")

    m.savedContent = createObject("roSGNode","ContentNode")

    resetContent()

    m.top.observeField("visible", "onVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")

end sub

function updateConfig(settings)
    m.overhang.Title = settings.instance_name
end function

'
'   Clear existing content
'
function resetContent()
    m.summary.content = createObject("roSGNode","ContentNode")
    m.background.url = ""
    m.content = createObject("roSGNode","ContentNode")
    m.rowList.content = m.content
end function

'
'   Add videos to current content
'
function addContent(videoInfo)
    date = CreateObject("roDateTime")

    row = createObject("RoSGNode","ContentNode")
    row.Title = videoInfo.title
    for each item in videoInfo.videos
        node = createObject("roSGNode","summary_node")
        node.title = item.name

        node.uuid = item.uuid
        node.url = get_setting("server", "") + item.previewPath

        '
        ' PeerTube descriptions use markdown and, at the least, we want
        ' to remove URLs that we can't click on with Roku
        '
        ' Assume markdown hyperlinks are of the form:
        '
        ' [some text](url)
        '
        if item.description <> Invalid then
            regex1 = createObject("roRegEx", "\([A-Za-z]+:\/\/[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_:%&;\?\#\/.=]+\)", "gi")
            regex2 = createObject("roRegEx", "[\[\]]", "gi")
            text = regex1.ReplaceAll(item.description,"")
            node.description = regex2.ReplaceAll(text,"")
        else
            node.description = ""
        end if

        node.HdGridPosterUrl = get_setting("server", "") + item.thumbnailPath
        node.ShortDescriptionLine1 = item.name
        node.ShortDescriptionLine2 = ""
        node.Length=item.duration

        date.FromISO8601String(item.publishedAt)
        node.ReleaseDate = date.AsDateString("short-month-no-weekday")
        row.appendChild(node)
    end for

    m.content.appendChild(row)
    m.rowList.content.appendChild(row)
end function

function saveContent()
    m.savedContent = m.rowList.content
end function

function restoreContent()
    m.content = m.savedContent
    m.rowList.content = m.savedContent
end function

' handler of focused item in RowList
Sub OnItemFocused()
    itemFocused = m.top.itemFocused

    '   When an item gains the key focus, set to a 2-element array,
    '   where element 0 contains the index of the focused row,
    '   and element 1 contains the index of the focused item in that row.
    If itemFocused.Count() = 2 then
        focusedContent = m.content.getChild(itemFocused[0]).getChild(itemFocused[1])
        if focusedContent <> invalid then
            m.top.focusedContent    = focusedContent
            m.summary.content       = focusedContent
            m.background.url        = focusedContent.HdGridPosterUrl
        end if
    end if
End Sub

sub onVisibleChange()
    if m.top.visible = true then
        m.rowList.setFocus(true)
    end if
end sub

' set proper focus to rowList in case if return from Details Screen
Sub OnFocusedChildChange()
    if m.top.isInFocusChain() and not m.rowList.hasFocus() then
        m.rowList.setFocus(true)
    end if
End Sub
