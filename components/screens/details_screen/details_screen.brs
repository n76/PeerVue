sub init()
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.thumbnail = m.top.FindNode("thumbnail")
    m.play_button = m.top.FindNode("play_button")
    m.top.observeField("visible", "onVisibleChange")
    m.play_button.setFocus(true)
end sub

function updateConfig(serverUrl)
    m.server = serverUrl
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.play_button.setFocus(true)
    end if
end sub

sub OnContentChange(obj)
    item = obj.getData()
    ? "details_screen :";item
    if item.name <> Invalid then
        m.title.text = item.name
    else
        m.title.text = ""
    end if

    '
    ' remove markdown hyperlinks of the form
    '
    ' [some text](url)
    '
    if item.description <> Invalid then
        regex1 = createObject("roRegEx", "\([A-Za-z]+:\/\/[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_:%&;\?\#\/.=]+\)", "gi")
        regex2 = createObject("roRegEx", "[\[\]]", "gi")
        text = regex1.ReplaceAll(item.description,"")
        m.description.text = regex2.ReplaceAll(text,"")
    else
        m.description.text = ""
    end if

    m.thumbnail.uri = get_setting("server", m.server) + item.thumbnailPath
    m.top.url = ""
    m.top.streamformat = ""
    m.top.duration = item.duration
    '
    '   First see if there are any HLS streams
    '
    for each stream in item.streamingPlaylists
        ?"playlistUrl: "; stream.playlistUrl
        m.top.url = stream.playlistUrl
        m.top.streamformat = "hls"
    end for
    m.top.url = ""
    if m.top.url = "" then
        ? "No HLS stream available"
        best_res = 0
        for each f in item.files
            if (f.resolution.id > best_res) and (f.resolution.id <= 1080)
                ?"resolution: "; f.resolution.id
                ?"url: "; f.fileDownloadUrl
                best_res = f.resolution.id
                m.top.url = f.fileDownloadUrl
                m.top.streamformat = "mp4"
            end if
        end for
    end if
end sub

