' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.thumbnail = m.top.FindNode("thumbnail")
    m.play_button = m.top.FindNode("play_button")
    m.top.observeField("visible", "onVisibleChange")
    m.play_button.setFocus(true)
end sub

function updateConfig(settings)
    m.play_button.text = get_locale_string("play", settings.strings)
end function

sub onVisibleChange()
    if m.top.visible = true then
        m.play_button.setFocus(true)
    end if
end sub

sub OnContentChange(obj)
    item = obj.getData()
    '? "details_screen :";item
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

    m.thumbnail.uri = get_setting("server", "") + item.thumbnailPath
    m.top.url = ""
    m.top.streamformat = ""
    m.top.duration = item.duration
    m.top.title = item.name
    '
    '   First see if there are any HLS streams
    '
    for each stream in item.streamingPlaylists
        m.top.url = stream.playlistUrl
        m.top.streamformat = "hls"
    end for

    '
    ' HLS streams from PeerTube lack sound for unknown reasons, so clear
    ' our indicator and force use of mp4 streams.
    '
    m.top.url = ""

    '
    '   If no HLS streams then work with available mp4 files
    '
    if m.top.url = "" then
        ? "[OnContentChange] No HLS stream available"
        best_res = 0
        streams = []
        for each f in item.files

            streamQuality = false
            if f.resolution.id > 720
                streamQuality = true
            end if
            '
            '   Assume size is bytes that take 10 bits to transport (typical TCP/IP)
            '   Assume Roku "bitrate" is kbps
            '
            thisStream = {}
            thisStream.bitrate = (((f.size / item.duration) * 10) / 1024).ToStr().ToInt().ToStr()
            thisStream.url = f.fileDownloadUrl
            thisStream.quality = streamQuality
            streams.push(thisStream)

        end for
        m.top.streamformat = "mp4"
        m.top.streamlist = streams
    end if
end sub

