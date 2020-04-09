' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub main()
    screen = createObject("roSGScreen")
    scene = screen.createScene("home_scene")
    screen.Show()
    port = createObject("roMessagePort")
    screen.setMessagePort(m.port)


    msgPort = CreateObject("roMessagePort")
    input = CreateObject("roInput")
    input.SetMessagePort(msgPort)

    '
    '   Waiting for messages
    '
    while(true)
        msg = wait(0, msgPort)
        if type(msg) = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                ? "Received input: "; FormatJSON(info)
            end if
        end if
    end while
end sub
