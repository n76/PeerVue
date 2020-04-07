' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

' "Registry" is where Roku stores config

' Generic registry accessors
function registry_read(key, section=invalid)
    if section = invalid then
        return invalid
    end if
    reg = CreateObject("roRegistrySection", section)
    if reg.exists(key) then
        return reg.read(key)
    end if
    return invalid
end function

function registry_write(key, value, section=invalid)
    if section = invalid then
        return invalid
    end if
    reg = CreateObject("roRegistrySection", section)
    reg.write(key, value)
    reg.flush()
end function

function registry_delete(key, section=invalid)
    if section = invalid then
        return invalid
    end if
    reg = CreateObject("roRegistrySection", section)
    reg.delete(key)
    reg.flush()
end function


' "PeerVue" registry accessors for the default global settings
function get_setting(key, default=invalid)
    value = registry_read(key, "PeerVue")
    if value = invalid then
        return default
    end if
    return value
end function

function set_setting(key, value)
    registry_write(key, value, "PeerVue")
end function

function unset_setting(key)
    registry_delete(key, "PeerVue")
end function

