' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.top.functionname = "request"
    m.top.response = {}
end sub  

function request()
    url = m.top.url
    ? "[load_url_task]: ";url
    json = getFeed(url)
    if (json <> invalid)
        m.top.response = json
    end if
    return 0
end function
