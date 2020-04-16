'
'   To be called from a task, never from a screen (UI thread)
'
'   Given a PeerTube API URL, get the JSON result of that API and
'   return it as an associative array
'
'   Errors will be raised by setting the m.top.error error string
'   as needed. And on an error the result returned will be "invalid"
'
function getFeed(url)
    rslt = invalid
    rsltString = ""

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
                m.top.error = "Feed failed to load. "+ chr(10) +  msg.getfailurereason() + chr(10) + "Code: "+msg.getresponsecode().toStr()+ chr(10) + "URL: "+ url
            end if
            http.asynccancel()
        else if (msg = invalid)
            ? "[getFeed] failed, reason unknown."
            'm.top.error = "Feed failed to load. Unknown reason."
            http.asynccancel()
        end if
    end if

    if (rsltString <> "")
        json = parseJSON(rsltString)
        if json = invalid
            ? "[getFeed] url: "; url
            ? "[getFeed] bad JSON: "; rsltString
            'm.top.error = "Error parsing feed from URL: "+url
        else
            rslt = json
        end if
    end if

    return rslt
end function


'
'   Multiple search helper
'
'   Called only from background task as it blocks!
'
'   Assumes the following interface variables are in the task object:
'       <field id = "videos"        type = "assocarray" />
'           A new array is returned on each search
'
'   The search list is an array of associative arrays. Two versions:
'   1. If the title is to be localized then:
'       {
'           "str_id":   "liked",
'           "path":     "/api/v1/videos/?start=0&count=30&sort=-likes"
'       },
'
'   2. If the title is not to be localized then:
'       {
'           "title":    "Title for row of videos",
'           "path":     "/api/v1/videos/?start=0&count=30&sort=-likes"
'       },
'

function doSearches( searchList, localeStrings )
    '?"[doSearches] Entry"

    for each search in searchList
        vids = {}
        searchVideos = []

        if (localeStrings <> invalid) and (search.str_id <> invalid)
            vids.title = get_locale_string(search.str_id, localeStrings)
        else
            vids.title = search.title
        end if
        if (vids.title = invalid)
            vids.title = ""
        end if

        '? "[search_task] s.str_id: ";vids.title
        '? "[search_task] s.path: ";search.path

        feedData  = getFeed(get_setting("server", "") + search.path)

        '
        ' For "normal" feeds, we have "data" and "total". For "discover"
        ' there is an associative array of the kind (channels, categories,
        ' tags, etc). Within each of those are associative arrays with some
        ' ID information (tag value, etc.) and a list of videos.
        '
        ' We only want the videos.
        '
        if (feedData <> invalid)
            for each key in feedData
                if key <> "total" then
                    if key = "data" then
                        searchVideos.Append(feedData[key])
                    else
                        keyData = feedData[key]
                        for each thing in keyData
                            searchVideos.Append(thing.videos)
                        end for
                        'searchVideos.Append(keyData.videos)
                    end if
                end if
            end for

            '
            ' Report this set of videos to our home scene
            '
            if (searchVideos.Count() = 0)
                ? "[doSearches] no results on search for ";search.path
            else
                vids.videos = searchVideos
                m.top.videos = vids
            end if
        end if
    end for
end function
