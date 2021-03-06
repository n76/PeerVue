' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

'
'   Our content screen (and thus things shown in our details and
'   video player) can be from either our configuration specified set
'   of URLs or from URLs derived from a search term.
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
    m.searchResultsReceived = false
    m.ConfigComplete        = false
    m.search_task           = invalid

    m.DeepLinkContentId     = Invalid
    m.DeepLinkMediaType     = Invalid

    initializeVideoPlayer()

    '
    '   Setup all our observers
    '
    m.details_screen.observeField("play_button_pressed", "onPlayButtonPressed")
    m.details_screen.observeField("related_button_pressed", "onRelatedButtonPressed")
    m.search_screen.observeField("enter_button_pressed","onSearchPressed")
    m.server_setup.observeField("enter_button_pressed", "onServerUpdatePressed")
    m.sidebar.observeField("selected_item", "onCategorySelected")
    m.top.observeField("rowItemSelected", "onRowItemSelected")
    m.sidebar.observeField("language_set", "onLanguageChanged")

    '
    '   Flag that we need to send a launch complete signal beacon
    '
    m.launchCompleteSent = false

    loadConfig()
end function

Function deepLink(mediaType, contentId)
    m.DeepLinkContentId     = contentId
    m.DeepLinkMediaType     = mediaType
    if (m.launchCompleteSent)
        startDeepLink()
    end if
end function

sub startDeepLink()
    ? "startDeepLink() mediaType = ";m.DeepLinkMediaType
    ? "startDeepLink() contendId = ";m.DeepLinkContentId
    loadDeepLinkVideoInfo(m.DeepLinkContentId)
end sub

sub pushContent()
    m.details_screen.callFunc("pushContent")
    m.content_screen.callFunc("pushContent")
end sub

sub popContent() as boolean
    m.details_screen.callFunc("popContent")
    return m.content_screen.callFunc("popContent")
end sub

sub setContentContains(newContains)
    if newContains = m.content_contains
        ? "[setContentContains] set to current value: ";m.content_contains
    else
        '
        '   Changing modes, rewind content history stack
        '
        while (popContent())
            ? "[setContentContains] popping content stack"
        end while

        if newContains = "search_videos"
            m.content_contains = "search_videos"
            m.content_screen.callFunc("saveContent")
        else
            m.content_contains = "config_videos"
            m.content_screen.callFunc("restoreContent")
        end if
    end if
end sub

sub sendLaunchComplete()
    if m.launchCompleteSent = false
        m.launchCompleteSent = true
        m.top.signalBeacon("AppLaunchComplete")
        if (m.DeepLinkContentId <> Invalid) and (m.DeepLinkMediaType <> Invalid)
            startDeepLink()
        end if
    end if
end sub

' Main Remote keypress handler
function onKeyEvent(key, press) as Boolean
    ? "[home_scene] onKeyEvent", key, press
    handled = false

    if (press)
        if m.search_screen.visible and (key="back")
            setContentContains("config_videos")
            enterSideBar()
            m.search_screen.setFocus(false)
            m.sidebar.setFocus(true)
            handled = true
        else if m.server_setup.visible and (key="back")
            enterSideBar()
            m.server_setup.setFocus(false)
            m.sidebar.setFocus(true)
            handled = true
        else if m.sidebar.visible and ((key="right") or (key="back"))
            enterContentScreen()
            m.sidebar.setFocus(false)
            handled = true
        else if m.content_screen.visible
            if (key="left")
                enterSideBar()
                m.sidebar.setFocus(true)
                handled = true
            else if (key="back")
                rslt = popContent()
                ?"[home_scene] onKeyPress result from popContent: ";rslt
                if (rslt)
                    enterDetailsScreen()
                    handled = true
                else if (m.content_contains="search_videos")
                    enterSearchScreen()
                    m.search_screen.setFocus(true)
                    handled = true
                end if
            end if
        else if m.details_screen.visible and (key="back")
            enterContentScreen()
            m.content_screen.setFocus(true)
            handled = true
        else if m.videoplayer.visible and (key="back")
            closeVideo()
            enterDetailsScreen()

            m.details_screen.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function

sub enterContentScreen()
    m.content_screen.visible    = true
    m.details_screen.visible    = false
    m.init_screen.visible       = false
    m.overhang.visible          = true
    m.search_screen.visible     = false
    m.server_setup.visible      = false
    m.sidebar.visible           = false
    m.videoplayer.visible       = false
end sub

sub enterSideBar()
    m.content_screen.visible    = false
    m.details_screen.visible    = false
    m.init_screen.visible       = false
    m.overhang.visible          = true
    m.search_screen.visible     = false
    m.server_setup.visible      = false
    m.sidebar.visible           = true
    m.videoplayer.visible       = false
end sub

sub enterDetailsScreen()
    m.content_screen.visible    = false
    m.details_screen.visible    = true
    m.init_screen.visible       = false
    m.overhang.visible          = true
    m.search_screen.visible     = false
    m.server_setup.visible      = false
    m.sidebar.visible           = false
    m.videoplayer.visible       = false
end sub

sub enterSearchScreen()
    m.content_screen.visible    = false
    m.details_screen.visible    = false
    m.init_screen.visible       = false
    m.overhang.visible          = true
    m.search_screen.visible     = true
    m.server_setup.visible      = false
    m.sidebar.visible           = false
    m.videoplayer.visible       = false
end sub

sub enterServerSetupScreen()
    m.content_screen.visible    = false
    m.details_screen.visible    = false
    m.init_screen.visible       = false
    m.overhang.visible          = true
    m.search_screen.visible     = false
    m.server_setup.visible      = true
    m.sidebar.visible           = false
    m.videoplayer.visible       = false
end sub

sub onCategorySelected(obj)
    cat_type = obj.getData()
    if cat_type = "server"
        enterServerSetupScreen()
    else if cat_type = "search"
        if (m.ConfigComplete)
            enterSearchScreen()
        end if
    else if cat_type = "ignore"
        ? "[home_scene] ignored category type"
    else
        ? "Type not implemented: ";cat_type
        'showErrorDialog(cat_type + " not yet implemented.")
    end if
end sub

sub OnRowItemSelected()
    item = m.content_screen.focusedContent
    loadVideoInfo(item.uuid)
end sub

sub onPlayButtonPressed(obj)
    m.details_screen.visible = false
    m.overhang.visible=false
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)

    '
    '   The video player content has been set in the preBufferVideo()
    '   routine when we entered the details screen. So all we have to
    '   do is tell the player to start.
    '
    m.videoplayer.control = "play"
end sub

sub onRelatedButtonPressed(obj)
    '
    '   Only allow the search and related buttons to work if
    '   our full configuration including default video content
    '   has completed. Otherwise we start messing up the video
    '   lists in the content screen
    '
    if (m.ConfigComplete)
        '
        '   Build searches from the tags associated with the current
        '   video
        '
        searches = []
        s = {}
        s.title = m.details_screen.video_owner
        s.path = "/api/v1/accounts/" + url_encode(s.title) + "/videos?nsfw=false&start=0&count=25&sort=-publishedAt"
        searches.push(s)
        for each tag in m.details_screen.related_tags
            s = {}
            s.title = tag
            s.path = "/api/v1/search/videos/?nsfw=false&start=0&count=30&sort=-match&tagsOneOf=" + url_encode(tag)
            searches.push(s)
        end for
        initiateSearchCommon(searches, true)
    end if
end sub

sub loadVideoInfo(uuid)
    m.url_task = createObject("roSGNode", "load_video_info_task")
    m.url_task.observeField("response", "onVideoInfoResponse")
    m.url_task.url = get_setting("server","") + "/api/v1/videos/" + uuid
    m.url_task.control = "RUN"
end sub

sub onVideoInfoResponse(obj)
    data = obj.getData()
    if data <> Invalid
        m.content_screen.visible = false
        m.overhang.visible=true
        m.details_screen.visible = true
        m.details_screen.content = data
        preBufferVideo(data)
        '
        '   Fix me: Need to get captions, if they exist, for video object
        '       /api/v1/videos/<video id>/captions
        '       See: SubtitleTracks at
        '       https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md
        '
        '       Also, see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
        '       for list of ISO 639-1 2 and ISO 639.2B 3 letter codes. Probably
        '       need a table lookup to do the conversion
        '
    else
        ? "[onVideoInfoResponse]: Feed response is empty!"
    end if
end sub

sub loadDeepLinkVideoInfo(uuid)
    m.url_task = createObject("roSGNode", "load_video_info_task")
    m.url_task.observeField("response", "onDeepLinkVideoInfoResponse")
    m.url_task.url = get_setting("server","") + "/api/v1/videos/" + uuid
    m.url_task.control = "RUN"
end sub

sub onDeepLinkVideoInfoResponse(obj)
    data = obj.getData()
    if data <> Invalid
        m.content_screen.visible = false
        m.overhang.visible=true
        m.details_screen.visible = true
        m.details_screen.content = data
        preBufferVideo(data)
        '
        '   Fix me: Need to get captions, if they exist, for video object
        '       /api/v1/videos/<video id>/captions
        '       See: SubtitleTracks at
        '       https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md
        '
        '       Also, see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
        '       for list of ISO 639-1 2 and ISO 639.2B 3 letter codes. Probably
        '       need a table lookup to do the conversion
        '

        '   If media type specified by deep link is short form or live then
        '   simulate pressing the play button.
        if (m.DeepLinkMediaType = "shortFormVideo") or (m.DeepLinkMediaType = "Live")
            onPlayButtonPressed(Invalid)
        end if
    else
        ? "[onDeepLinkVideoInfoResponse]: Response is empty!"
    end if
end sub

sub preBufferVideo(item)
    '
    '   Attempt to "fast start" video per:
    '   https://developer.roku.com/docs/developer-program/media-playback/fast-video-start.md
    '   and:
    '   https://developer.roku.com/docs/references/scenegraph/media-playback-nodes/video.md
    '
    '   We build the content node when we enter the details screen and
    '   tell it to pre-buffer. Then when the play button is pressed we
    '   should just be able to make it visible and tell it to play.
    '
    content = createObject("roSGNode","ContentNode")
    if item.name <> Invalid then
        content.title = item.name
    else
        content.title = ""
    end if
    content.length = item.duration

    streams = []
    hls_url = ""
    '
    '   Build list of URLs of the various bitrate/sizes available
    '
    '   See:
    '   https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    '
    for each f in item.files
        thisStream = {}

        thisStream.quality = false
        if f.resolution.id > 720
            thisStream.quality = true
        end if

        thisStream.url = f.fileUrl
        thisStream.stickyredirects = false

        '
        '   PeerTube gives file size in bytes, Roku wants bitrate, so compute
        '   an average bitrate from file size and video duration.
        '
        '   Assume each byte take 10 bits to transport (typical TCP/IP)
        '   Assume Roku "bitrate" is kbps and "k" means 1024 rather than 1000
        '
        '   We want an integer expressed as a string. Can't find a round()
        '   or trunc() function in the Brightscript docs, so we'll turn the
        '   floating point to a string, convert the string to integer.
        '
        bitrate = (((f.size / item.duration) * 10) / 1024).ToStr().ToInt()
        thisStream.bitrate = bitrate
        thisStream.contentid = item.uuid + "-" + f.resolution.label + "-" + bitrate.ToStr()
        streams.push(thisStream)

    end for

    '
    '   See if there is a HLS stream defined
    '
    for each stream in item.streamingPlaylists
        hls_url = stream.playlistUrl
    end for

    '
    '   Since HLS sound is broken and the assumed problem is in PeerTube
    '   as the HLS it provides fails the Apple mediastreamvalidator, give
    '   preference to stream list of MP4 URLs
    '
    '   Bug: Need to revisit HLS when PeerTube HLS passes validation.
    '
    if (streams.count() > 0)
        content.streamformat = "mp4"
        content.streams = streams
    else
        content.url = hls_url
        content.streamformat = "hls"
    end if

    '
    '   Build list of subtitle/captions available on video
    '
    '   Peertube uses 2 letter ISO 639-1 codes while
    '   Roku uses 3 letter ISO 639-2B codes. So we convert
    '   them with a look up table.
    '
    if item.captions <> invalid
        captions = []
        for each cap in item.captions
            isoInfo =  m.iso639_1.lookup(cap.language.id)
            if isoInfo <> invalid then
                thisCaption = {}
                thisCaption.Language = isoInfo.iso639_2b
                thisCaption.Description = isoInfo.NativeName
                thisCaption.TrackName = get_setting("server","") + cap.captionPath
                captions.push(thisCaption)
            end if
        end for
        if captions.count() > 0
            content.SubtitleTracks = captions
        end if
    end if

    m.videoplayer.content = content
    m.videoplayer.control = "prebuffer"
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
    '? "Player Position: ", obj.getData()
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

    ? "[closeVideo] completedStreamInfo:";m.videoplayer.completedStreamInfo
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
            enterSidebar()
            m.server_setup.setFocus(false)
            m.sidebar.setFocus(true)
        else
            '? "[onServerUpdatePressed] new server: ";new_url
            set_setting("server", new_url)
            loadConfig()
        end if
    end if
end sub

sub onLanguageChanged()
    '? "[onLanguageChanged] Language changed to: "; get_language()
    '
    '   Need to reload all the default content. Easiest way
    '   is to reload our whole configuration.
    loadConfig()
end sub

sub onSearchPressed(obj)
    '
    '   Only allow the search and related buttons to work if
    '   our full configuration including default video content
    '   has completed. Otherwise we start messing up the video
    '   lists in the content screen
    '
    if (m.ConfigComplete)
        search_string = m.search_screen.text_content
        '? "[onSearchPressed] search string: ";search_string
        setContentContains("search_videos")

        '
        '   First search in list is simply the user's search string
        '
        searches = []
        s = {}
        s.title = m.search_screen.text_content
        s.path = "/api/v1/search/videos/?nsfw=false&start=0&count=30&sort=-match&search=" + url_encode(search_string)
        searches.push(s)

        '
        '   On the "related" search we break the search string into
        '   words and treat them, individually or in pairs, as tags
        '   to search for
        '
        '   Example: If the search string is "steam railroad trains" we will
        '   search for the following tags:
        '       "steam"
        '       "railroad"
        '       "steam railroad"
        '       "trains"
        '       "railroad trains"
        '
        '   Note, search API on the PeerTube server side is being improved
        '   and this second search based on assumed tags may not be needed
        '   in the future
        '
        s = {}
        s.title = tr("Related Videos")
        query = "/api/v1/search/videos/?nsfw=false&start=0&count=30&sort=-match"
        '? "[onSearchPressed] search string: ";m.search_screen.text_content
        tags = (m.search_screen.text_content).tokenize(" ")
        previousTag = ""
        for each tag in tags
            query = query + "&tagsOneOf=" + url_encode(tag)
            if previousTag <> ""
                query = query + "&tagsOneOf=" + url_encode(previousTag + " " + tag)
            end if
            previousTag = tag
        end for
        s.path = query
        searches.push(s)

        initiateSearchCommon(searches, false)
    end if
end sub

sub initiateSearchCommon(searches, related)
    '
    '   If there is an existing search task that is running, stop it.
    '
    if (m.search_task <> invalid) and (m.search_task.state = "run")
        ? "[initiateSearchCommon] Existing search task is running, stopping it."
        m.search_task.control = "stop"
    end if

    '
    '   In theory we should be able to reuse the old task node but it seems
    '   that it doesn't handle new search lists very well if we do that.
    '
    m.search_task = createObject("roSGNode", "search_task")

    if (related)
        m.search_task.observeField("videos", "onRelatedVideosResponse")
    else
        m.search_task.observeField("videos", "onSearchVideosResponse")
    end if
    m.search_task.observeField("error", "onTaskError")

    '
    ' Indicate we are haven't yet seen first search response
    '
    m.searchResultsReceived = false

    m.search_task.searchlist = invalid
    m.search_task.searchlist = searches

    m.search_task.control = "RUN"
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

sub onRelatedVideosResponse(obj)
    if (m.searchResultsReceived = false)
        '
        '   Tell the details page and the content page to save their current
        '   state so we can get back to it.
        '
        pushContent()
    end if
    onSearchVideosResponse(obj)
end sub

sub onSearchVideosResponse(obj)
    info = obj.getData()
    if (m.searchResultsReceived = false)
        m.content_screen.callFunc("resetContent")
        m.searchResultsReceived = true
        if (m.content_screen.visible = false)
            m.details_screen.visible = false
            m.search_screen.visible = false
            m.sidebar.visible = false
            m.overhang.visible=true

            m.content_screen.visible = true
            m.content_screen.setFocus(true)
        end if
    end if
    m.content_screen.callFunc("addContent",info)
end sub

sub loadConfig()
    '
    '   Start configuration: Hide everything but the init screen
    '
    m.content_screen.visible    = false
    m.init_screen.visible       = true
    m.overhang.visible          = false
    m.search_screen.visible     = false
    m.server_setup.visible      = false
    m.sidebar.visible           = false

    m.ConfigComplete            = false

    '
    '   Assure we are in configured content mode and clear the existing
    '   content if any.
    '
    while (popContent())
        ? "[loadConfig] popping content stack"
    end while

    setContentContains("config_videos")
    m.content_screen.callFunc("resetContent")

    '
    '   Start a task to load everything we need from our instance server
    '
    loc = CreateObject("roLocalization")
    m.config_task = createObject("roSGNode", "load_config_task")
    m.config_task.observeField("configuration", "onConfigResponse")
    m.config_task.observeField("error", "onTaskError")
    m.config_task.observeField("videos", "onConfigVideos")
    m.config_task.observeField("complete", "onConfigComplete")
    m.config_task.control="RUN"
end sub

sub onConfigResponse(obj)
    settings = obj.getData()
    m.strings = settings.strings
    m.iso639_1 = settings.iso639_1

    m.overhang.Title = settings.instance_name

    '
    '   Various screens need the configuration too to setup
    '   server address, etc.
    '
    m.server_setup.callFunc("updateConfig",settings)
    m.sidebar.callFunc("updateConfig",settings)

    if get_setting("server","") = ""
        '
        '   If no server defined (initial start up) then
        '   start with server setup screen
        '
        m.server_setup.text_content = ""
        enterServerSetupScreen()
    end if
end sub

sub onConfigComplete(obj)
    sendLaunchComplete()
    m.ConfigComplete = true
end sub

sub onConfigVideos(obj)
    info = obj.getData()
    m.content_screen.callFunc("addContent",info)

    '
    '   First few videos available, set content visibility
    '
    if (m.init_screen.visible = true)
        m.content_screen.visible    = true
        m.init_screen.visible       = false
        m.overhang.visible          = true
        m.sidebar.visible           = false

        m.content_screen.setFocus(true)
    end if
end sub

sub onTaskError(obj)
    showErrorDialog(obj.getData())
end sub
