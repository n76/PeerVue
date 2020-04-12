' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.top.functionname = "request"
    m.top.response = {}
end sub  

'
'   PeerTube does not give all the information we want about a video when
'   we ask for video information. This task has the same API as the load_url_task
'   (i.e. we return back one JSON result for the requested URL) but we
'   actually make several server requests:
'
'   1. The call requested
'   2. The call modified to get the full video description. We replace the
'      shorter summary description in the first result.
'   3. A modified call to get closed caption/subtitle information.
'
function request()
    url = m.top.url
    ? "[load_url_task]: ";url
    json = getFeed(url)
    if (json <> invalid)
        '
        '   Get full description and replace the summary in our original
        '   response
        extraJson = getFeed(url + "/description")
        if (extraJson <> invalid)
            json.description = extraJson.description
        end if
        '
        '   Get subtitle info and add it to the summary in our original
        '   response
        extraJson = getFeed(url + "/captions")
        if (extraJson <> invalid)
            json.captions = extraJson.captions
        end if
        m.top.response = json
    end if
    return 0
end function
