'
'   Our content screen (and thus things shown in our details and
'   video player) can be from either our configuration specified set
'   of URLs or from a URL derived from a search term.
'
'   We use the m.content_contains variable to keep track of what
'   is in the content screen. Values are:
'
'   "config_videos"     - content contains video information from
'                         the URLs in our config.json file
'   "search_videos"     - content contains video information from
'                         our most recent search
'

function init()
    ? "[home_scene] init"
    '
    '   Find all of our screens and components
    '
    m.content_screen = m.top.findNode("content_screen")
    m.details_screen = m.top.findNode("details_screen")
    m.error_dialog = m.top.findNode("error_dialog")
    m.init_screen = m.top.findNode("MyInitDisplay")
    m.overhang = m.top.findNode("MyOverhang")
    m.search_screen = m.top.findNode("search_screen")
    m.server_setup = m.top.findNode("server_setup")
    m.sidebar = m.top.findNode("sidebar")
    m.videoplayer = m.top.findNode("videoplayer")
    
    m.content_contains = "config_videos"

    initializeVideoPlayer()

    '
    '   Setup all our observers
    '
    m.details_screen.observeField("play_button_pressed", "onPlayButtonPressed")
    m.search_screen.observeField("search_screen_button_pressed","onSearchPressed")
    m.server_setup.observeField("server_update_button_pressed", "onServerUpdatePressed")
    m.sidebar.observeField("category_selected", "onCategorySelected")
    m.top.observeField("rowItemSelected", "OnRowItemSelected")

    loadConfig()
end function

' Main Remote keypress handler
function onKeyEvent(key, press) as Boolean
    ? "[home_scene] onKeyEvent", key, press

    if (press)
        if m.search_screen.visible and (key="back")
            m.content_screen.callFunc("restoreContent")
            m.content_contains = "config_videos"
            m.search_screen.visible = false
            m.search_screen.setFocus(false)
            m.overhang.visible=true
            m.sidebar.visible = true
            m.sidebar.setFocus(true)
            return true
        else if m.server_setup.visible and (key="back")
            m.server_setup.visible = false
            m.server_setup.setFocus(false)
            m.overhang.visible=true
            m.sidebar.visible = true
            m.sidebar.setFocus(true)
            return true
        else if m.sidebar.visible and ((key="right") or (key="back"))
            m.content_screen.visible=true
            m.overhang.visible=true
            m.sidebar.visible=false
            m.sidebar.setFocus(false)
            return true
        else if m.content_screen.visible
            if (key="left")
                m.content_screen.visible=false
                m.overhang.visible=true
                m.sidebar.visible=true
                m.sidebar.setFocus(true)
                return true
            else if (key="back") and (m.content_contains="search_videos")
                ? "[home_scene] contents contains: "; m.content_contains
                m.content_screen.visible = false
                m.search_screen.visible = true
                m.search_screen.setFocus(true)
                m.overhang.visible = true
                m.sidebar.visible = false
                return true
            end if
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
    list = m.sidebar.findNode("category_list")
    item = list.content.getChild(obj.getData())
    if item.cat_type = "settings"
        m.server_setup.server_url = get_setting("server","")
        m.content_screen.visible = false
        m.sidebar.visible = false
        m.overhang.visible=true
        m.server_setup.visible = true
    else if item.cat_type = "search"
        m.content_screen.visible = false
        m.content_screen.callFunc("saveContent")
        m.sidebar.visible = false
        m.overhang.visible=true
        m.search_screen.visible = true
    else
        ? "Type not implemented: ";item.cat_type
        showErrorDialog(item.cat_type + " not yet implemented.")
    end if
end sub

sub OnRowItemSelected()
    item = m.content_screen.focusedContent
    loadVideoInfo(item.uuid)
end sub

sub onPlayButtonPressed(obj)
    node = createObject("roSGNode","ContentNode")
    node.streamformat = m.details_screen.streamformat
    if (m.details_screen.streamformat = "hls")
        node.url = m.details_screen.url
    else
        node.streams = m.details_screen.streamlist
    endif
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
    m.url_task.url = get_setting("server","") + "/api/v1/videos/" + uuid
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

sub onServerUpdatePressed(obj)
    new_url = m.server_setup.server_url
    '
    '   URL must start with either "http://" or "https://" and it must
    '   contain at least one "." separator.
    '
    if ((INSTR(1,new_url,"http://") = 1) or (instr(1,new_url,"https://"))) and (INSTR(1,new_url,".") > 1)
        if (get_setting("server","") = new_url)
            '
            ' New server same as old. Treat the same as a back button
            '
            m.server_setup.visible = false
            m.server_setup.setFocus(false)
            m.overhang.visible=true
            m.sidebar.visible = true
            m.sidebar.setFocus(true)
        else
            ? "[onServerUpdatePressed] new server: ";new_url
            set_setting("server", new_url)
            loadConfig()
        end if
    end if
end sub

sub onSearchPressed(obj)
    search_string = m.search_screen.search_string
    ? "[onSearchPressed] new server: ";search_string
    
    m.url_task = createObject("roSGNode", "load_url_task")
    m.url_task.observeField("response", "onSearchResponse")
    m.url_task.url = get_setting("server","") + "/api/v1/search/videos/?start=0&count=30&sort=-match&search=" + url_encode(search_string)
    m.url_task.control = "RUN"
end sub

function url_encode(s):
    unreserved = createObject("roRegex", "[\w\d\-_.]", "")
    ba = createObject("roByteArray")
    res = ""
    for each ch in s.split(""):
        if unreserved.isMatch(ch):
            res += ch
        else
            ba.fromAsciiString(ch): hex = ba.toHexString()
            for i = 1 to len(hex) step 2: res += "%" + mid(hex,i,2): next      
        end if
    end for
    return res
end function

sub onSearchResponse(obj)
    response = obj.getData()
    '? "[onSearchResponse] response: " response
    json = parseJSON(response)
    if json = invalid
        ? "[getFeed] bad JSON: "; rsltString
        m.top.error = "Error parsing feed from server "+server
    end if

    m.content_contains = "search_videos"
    vids = {}
    vids.title = m.search_screen.search_string
    vids.videos = json.data
    m.content_screen.callFunc("newContent",vids)
    
    m.search_screen.visible = false
    m.init_screen.visible = false
    m.sidebar.visible = false
    m.overhang.visible=true

    m.content_screen.visible = true
    m.content_screen.setFocus(true)
end sub


sub loadConfig()
    '
    ' Go into config loading mode: Hide everything but the init screen
    '
    m.content_screen.visible = false
    m.sidebar.visible = false
    m.server_setup.visible = false
    m.overhang.visible = false
    m.init_screen.visible = true

    m.content_screen.callFunc("resetContent")
    m.content_contains = "config_videos"

    '
    '   Start a task to load everything we need from our instance server
    '
    loc = CreateObject("roLocalization")
    m.config_task = createObject("roSGNode", "load_config_task")
    m.config_task.observeField("configuration", "onConfigResponse")
    m.config_task.observeField("error", "onConfigError")
    m.config_task.observeField("videos", "onConfigVideos")
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

    settings = obj.getData()
    m.strings = settings.strings

    m.overhang.Title = settings.instance_name

    '
    '   Various screens need the configuration too to setup
    '   locale based text and/or server address, etc.
    '
    m.content_screen.callFunc("updateConfig",settings)
    m.details_screen.callFunc("updateConfig",settings)
    m.search_screen.callFunc("updateConfig", settings)
    m.server_setup.callFunc("updateConfig", settings)
    m.sidebar.callFunc("updateConfig",settings)

    if get_setting("server","") = ""
        '
        '   If no server defined (initial start up) then
        '   start with server setup screen
        '
        m.init_screen.visible = false
        m.server_setup.server_url = ""
        m.content_screen.visible = false
        m.sidebar.visible = false
        m.overhang.visible=true
        m.server_setup.visible = true
    else
        '
        '   Server defined, set content visibility
        '
        m.init_screen.visible = false
        m.sidebar.visible = false
        m.overhang.visible=true

        m.content_screen.visible = true
        m.content_screen.setFocus(true)
    end if
end sub

sub onConfigVideos(obj)
    info = obj.getData()
    m.content_screen.callFunc("addContent",info)
end sub

sub onConfigError(obj)
    showErrorDialog(obj.getData())
end sub
