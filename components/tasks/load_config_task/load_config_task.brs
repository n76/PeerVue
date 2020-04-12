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
            '
            '   Get configured video lists
            '
            ?"[load_config_task] getting videos"
            for each category in json.categories
                vids = {}
                categoryVideos = []
            
                vids.title = get_locale_string(category.str_id, localeStrings)
                feedPath  = category.path
                feedData  = getFeed(server + feedPath)
            
                '
                ' For "normal" feeds, we have "data" and "total". For "discover"
                ' there is an associative array of the kind (channels, categories,
                ' tags, etc). Within each of those are associative arrays with some
                ' ID information (tag value, etc.) and a list of videos.
                '
                ' We only want the videos.
                '
                for each key in feedData
                    if key <> "total" then
                        if key = "data" then
                            categoryVideos.Append(feedData[key])
                        else
                            keyData = feedData[key]
                            for each thing in keyData
                                categoryVideos.Append(thing.videos)
                            end for
                            'categoryVideos.Append(keyData.videos)
                        end if
                    end if
                end for

                '
                ' Report this set of videos to our home scene
                '
                vids.videos = categoryVideos
                m.top.videos = vids
            end for
        end if
    end if
    '
    '   Tell home scene that we have loaded all the configured videos
    '
    m.top.complete = "done"
    return 0
end function
