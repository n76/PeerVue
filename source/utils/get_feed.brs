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
        m.top.error = "Error parsing feed from URL: "+url
    else
        rslt = json
    end if

    return rslt
end function
