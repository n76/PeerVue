' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

' Look up international locale version of string

function get_locale_string(key, dictionary)
    text =  dictionary.lookup(key)
    if text = invalid then
        text = key
    end if
    return text
end function
