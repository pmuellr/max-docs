# Licensed under the Tumbolia Public License. See footer for details.

# example.name -> img.src

#-------------------------------------------------------------------------------
$(document).ready ->
    process()

#-------------------------------------------------------------------------------
process = ->
    uls$ = $ "ul.seealso"
    for ul in uls$
        ul$ = $ ul
        ul$.before "<h3>See also</h3>"


    lis$ = $ "ul.seealso li"

    for li in lis$
        li$ = $ li

        text = li$.text()
        name = li$.attr "name"
        li$.html "<b>#{name}</b>: #{text}"

#-------------------------------------------------------------------------------
# Copyright (c) 2013 Patrick Mueller
#
# Tumbolia Public License
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty provided the copyright notice and
# this notice are preserved.
#
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#   0. opan saurce LOL
#-------------------------------------------------------------------------------