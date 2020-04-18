' SPDX-FileCopyrightText: 2020 Tod Fitch <tod@fitchfamily.org>
'
' SPDX-License-Identifier: MIT

sub init()
    m.top.functionname = "load"
end sub

function load()
    doSearches( m.top.searchlist )
    return 0
end function
