' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.top.functionname = "request"
    m.top.response = ""
end sub  

function request()
    url = m.top.url
    ? "Feed Task URL: ";url
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
                m.top.response = msg.getstring()
            else
                ? "feed load failed: "; msg.getfailurereason();" "; msg.getresponsecode();" "; m.top.url
                m.top.error = "Feed failed to load. "+ chr(10) +  msg.getfailurereason() + chr(10) + "Code: "+msg.getresponsecode().toStr()+ chr(10) + "URL: "+ m.top.url
            end if
            http.asynccancel()
        else if (msg = invalid)
            ? "feed load failed."
            m.top.error = "Feed failed to load. Unknown reason."
            http.asynccancel()
        end if
    end if
    return 0
end function
