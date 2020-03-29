function init()
    ? "[home_scene] init"
    m.init_screen = m.top.findNode("MyInitDisplay")
    m.overhang = m.top.findNode("MyOverhang")
    m.sidebar = m.top.findNode("sidebar")
    m.content_screen = m.top.findNode("content_screen")
    m.details_screen = m.top.findNode("details_screen")
    m.error_dialog = m.top.findNode("error_dialog")
    m.videoplayer = m.top.findNode("videoplayer")
    initializeVideoPlayer()

    m.sidebar.observeField("category_selected", "onCategorySelected")
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    m.details_screen.observeField("play_button_pressed", "onPlayButtonPressed")

    m.content_screen.visible = false
    m.sidebar.visible = false
    m.overhang.visible = false
    m.init_screen.visible = true
    loadConfig()
end function

' Main Remote keypress handler
function onKeyEvent(key, press) as Boolean
    ? "[home_scene] onKeyEvent", key, press

    if (press)
        if m.sidebar.visible and (key="right")
            m.content_screen.visible=true
            m.overhang.visible=true
            m.sidebar.visible=false
            m.sidebar.setFocus(false)
            return true
        else if m.content_screen.visible and (key="left")
            m.content_screen.visible=false
            m.overhang.visible=true
            m.sidebar.visible=true
            m.sidebar.setFocus(true)
            return true
        else if m.details_screen.visible and (key="back")
            m.details_screen.visible=false
            m.overhang.visible=true
            m.content_screen.visible=true
            m.content_screen.setFocus(true)
            return true
        else if m.videoplayer.visible and (key="back")
            closeVideo()
            m.details_screen.setFocus(true)
            return true
        end if
    end if

    return false
end function

sub onCategorySelected(obj)
    ? "onCategorySelected field: ";obj.getField()
    ? "onCategorySelected data: ";obj.getData()
    list = m.sidebar.findNode("category_list")
    ? "onCategorySelected checkedItem: ";list.checkedItem
    ? "onCategorySelected selected ContentNode: ";list.content.getChild(obj.getData())
    item = list.content.getChild(obj.getData())
        ? "Type not implemented: ";item.cat_type
        showErrorDialog(item.cat_type + " not yet implemented.")
end sub

Function OnChangeContent()
    ? "[home_scene] OnContentChange()"
    '
    '   Set content visibility
    '
    m.init_screen.visible = false
    m.sidebar.visible = false
    m.overhang.visible=true

    m.content_screen.visible = true
    m.content_screen.setFocus(true)
End Function

sub OnRowItemSelected()    
    item = m.content_screen.focusedContent
    loadVideoInfo(item.uuid)
end sub

sub onPlayButtonPressed(obj)
    node = createObject("roSGNode","ContentNode")
    node.streamformat = m.details_screen.streamformat    
    node.url = m.details_screen.url
    node.length = m.details_screen.duration

    m.details_screen.visible = false
    m.overhang.visible=false
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)

    m.videoplayer.content = node
    m.videoplayer.control = "play"
end sub

sub loadVideoInfo(uuid)
    m.url_task = createObject("roSGNode", "load_url_task")
    m.url_task.observeField("response", "onVideoInfoResponse")
    m.url_task.url = get_setting("server", m.server) + "/api/v1/videos/" + uuid
    m.url_task.control = "RUN"
end sub

sub onVideoInfoResponse(obj)
    response = obj.getData()
'    ? "onVideoInfoResponse: "; obj.getData()
    data = parseJSON(response)
'    ? "parsed JSON: ";data
    if data <> Invalid
        m.content_screen.visible = false
        m.overhang.visible=true
        m.details_screen.visible = true
        m.details_screen.content = data
    else
        ? "FEED RESPONSE IS EMPTY!"
    end if
end sub

sub initializeVideoPlayer()
    m.videoplayer.EnableCookies()
    m.videoplayer.setCertificatesFile("common:/certs/ca-bundle.crt")
    m.videoplayer.InitClientCertificates()
    m.videoplayer.notificationInterval=1
    m.videoplayer.observeFieldScoped("position", "onPlayerPositionChanged")
    m.videoplayer.observeFieldScoped("state", "onPlayerStateChanged")
end sub

sub onPlayerPositionChanged(obj)
    ? "Player Position: ", obj.getData()
end sub

sub onPlayerStateChanged(obj)
    state = obj.getData()
    ? "onPlayerStateChanged: ";state
    if state="error"
        ? "Error Message: ";m.videoplayer.errorMsg
        ? "Error Code: ";m.videoplayer.errorCode
        showErrorDialog(m.videoplayer.errorMsg+ chr(10) + "Error Code: "+m.videoplayer.errorCode.toStr())
    else if state = "finished"
        closeVideo()
    end if
end sub

sub closeVideo()
    m.videoplayer.control = "stop"
    m.videoplayer.visible=false
    m.overhang.visible=true
    m.details_screen.visible=true
end sub

sub showErrorDialog(message)
    m.error_dialog.title = "ERROR"
    m.error_dialog.message = message
    m.error_dialog.visible=true
    'tell the home scene to own the dialog so the remote behaves'
    m.top.dialog = m.error_dialog
end sub

sub loadConfig()
    loc = CreateObject("roLocalization")
    m.config_task = createObject("roSGNode", "load_config_task")
    m.config_task.observeField("configuration", "onConfigResponse")
    m.config_task.observeField("error", "onConfigError")
    m.config_task.control="RUN"
end sub

sub onConfigResponse(obj)
    '? "[onConfiguration]: "; obj.getData()
    '? "[onConfiguration] strings: "; obj.getData().strings
    '? "[onConfiguration] videos: "; obj.getData().videos
    '? "[onConfiguration] videos.discover: "; obj.getData().videos.discover
    'for each item in obj.getData().videos.discover
    '    ? "[configuration] discover item: "; item
    'end for

    '
    ' Sidebar needs locale strings, so initialize it
    '
    settings = obj.getData()
    m.sidebar.callFunc("updateConfig",settings)
    m.overhang.Title = settings.instance_name

    '? "[onConfiguration] server: "; obj.getData().server
    m.server = settings.server

    '
    '   Pass server URL on to objects that might need it
    '
    m.details_screen.callFunc("updateConfig",m.server)
    
    '
    '   Content screen needs server URL, locale strings and
    '   video list (basically everything)
    m.content_screen.callFunc("updateConfig",settings)

end sub

sub onConfigError(obj)
    showErrorDialog(obj.getData())
end sub
