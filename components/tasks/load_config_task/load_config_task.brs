' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

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
        localeStrings = json
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

        configuration.iso639_1 = json.iso639_1
        configuration.instances = json.instances

        server = get_setting("server", "")
        if (server = "")
            configuration.instance_name = ""
        else
            '
            '   Get name of instance
            '
            ?"[load_config_task] server for instance name: ";server
            feedData = getFeed(server + "/api/v1/config")
            configuration.instance_name = feedData.instance.name
        end if

        '
        '   Done with basic configuration, give it to our home scene
        '
        m.top.configuration = configuration

        if (server = "")
            ?"[load_config_task] no server defined"
            m.top.complete = "done"
        else
            doSearches( json.categories, localeStrings )
        end if
    end if
    '
    '   Tell home scene that we have loaded all the configured videos
    '
    m.top.complete = "done"
    return 0
end function
