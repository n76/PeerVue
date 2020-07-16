' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

Function Main (args as Dynamic) as Void
    screen = createObject("roSGScreen")
    scene = screen.createScene("home_scene")
    screen.Show()
    port = createObject("roMessagePort")
    screen.setMessagePort(m.port)

    msgPort = CreateObject("roMessagePort")
    input = CreateObject("roInput")
    input.SetMessagePort(msgPort)

    if (args.mediaType <> invalid) and (args.contentId <> invalid)
        scene.callFunc("deepLink",args.mediaType,args.contentID)
    end if

    '
    '   Waiting for messages
    '
    while(true)
        msg = wait(0, msgPort)
        if type(msg) = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                ? "Received input: "; FormatJSON(info)
                if info.DoesExist("contentid") and info.DoesExist("mediatype")
                    scene.callFunc("deepLink",info.mediaType,info.contentID)
                end if
            end if
        end if
    end while
End Function
