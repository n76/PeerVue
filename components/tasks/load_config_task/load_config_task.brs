sub init()
    m.top.functionname = "load"
end sub

function load()
    configuration = {}
       
    '
    '   Get localized strings
    '
    loc = CreateObject("roLocalization")
    filepath = loc.GetLocalizedAsset("", "strings.json")
    data=ReadAsciiFile(filepath)
    json = parseJSON(data)
    if json = invalid
        ? "[Load Config Task] Strings: "; data
        m.top.error = "Locale strings at "+filepath+" is invalid."
    else
        configuration.strings = json
    end if
    
    '
    '   Get configuration
    '
    filepath = "pkg:/resources/config.json"
    data=ReadAsciiFile(filepath)
    json = parseJSON(data)
    if json = invalid
        ? "[Load Config Task] Config: "; data
        m.top.error = "Configuration file at "+filepath+" is invalid."
    else
        configuration.server = json.server
        videos = {}
        for each category in json.categories
            categoryVideos = []
            feedTitle = category.str_id
            feedPath  = category.path
            feedData  = getFeed(json.server, feedPath)
            
            '
            ' For "normal" feeds, we have "data" and "total". For "discover"
            ' there is an associative array of the kind (channels, categories,
            ' tags, etc). Within each of those are associative arrays with some
            ' ID information (tag value, etc.) and a list of videos.
            '
            ' We only want the videos.
            '
            for each key in feedData
                if key <> "total" then
                    if key = "data" then
                        categoryVideos.Append(feedData[key])
                    else
                        keyData = feedData[key]
                        for each thing in keyData
                            categoryVideos.Append(thing.videos)
                        end for
                        'categoryVideos.Append(keyData.videos)
                    end if
                end if
            end for
            videos.AddReplace(feedTitle, categoryVideos)
        end for
        configuration.videos = videos
    end if
    m.top.configuration = configuration
end function

function getFeed(server, path)
    rslt = invalid
    rsltString = ""

    url = server + path
    http = createObject("roUrlTransfer")
    http.RetainBodyOnError(true)
    port = createObject("roMessagePort")
    http.setPort(port)
    http.setCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    http.enablehostverification(false)
    http.enablepeerverification(false)
    http.setUrl(url)
    if http.AsyncGetToString() Then
        msg = wait(10000, port)
        if (type(msg) = "roUrlEvent")
            if (msg.getresponsecode() > 0 and  msg.getresponsecode() < 400)
                rsltString = msg.getstring()
            else
                ? "[getFeed] failed: "; msg.getfailurereason();" "; msg.getresponsecode();" "; url
                m.top.error = "Feed failed to load. "+ chr(10) +  msg.getfailurereason() + chr(10) + "Code: "+msg.getresponsecode().toStr()+ chr(10) + "URL: "+ m.top.url
            end if
            http.asynccancel()
        else if (msg = invalid)
            ? "[getFeed] failed, reason unknown."
            m.top.error = "Feed failed to load. Unknown reason."
            http.asynccancel()
        end if
    end if
    json = parseJSON(rsltString)
    if json = invalid
        ? "[getFeed] url: "; url
        ? "[getFeed] bad JSON: "; rsltString
        m.top.error = "Error parsing feed from server "+server
    else
        rslt = json
    end if

    return rslt
end function
