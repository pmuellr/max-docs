# Licensed under the Tumbolia Public License. See footer for details.

fs = require "fs"

utils = exports

SequenceNumberMax = 100 * 1024 * 1024
SequenceNumber    = 0

#-------------------------------------------------------------------------------
utils.logger = (program, opts) ->
    opts           = opts || {}
    opts.logObject = opts.logObject || console

    result =     
        verbose: opts.verbose
        log:     (message) ->  opts.logObject.log "#{logDate()} #{program}: #{message}"
        vlog:    (message) ->  @log(message) if @verbose
        err:     (message) ->  @log(message); process.exit(1)

    return result

#-------------------------------------------------------------------------------
logDate = () ->
    date = new Date().toISOString()
    date = date.replace("T", " ")
    return date

#-------------------------------------------------------------------------------
utils.getNextSequenceNumber = (g) ->
    SequenceNumber++

    if SequenceNumber > SequenceNumberMax
        SequenceNumber = 0

    SequenceNumber

#-------------------------------------------------------------------------------
utils.trim = (string) ->
    string.replace(/(^\s+)|(\s+$)/g,'')

#-------------------------------------------------------------------------------
utils.alignLeft = (string, length) ->
    while string.length < length
        string = "#{string} "
    return string

#-------------------------------------------------------------------------------
utils.alignRight = (string, length) ->
    while string.length < length
        string = " #{string}"
    return string

#-------------------------------------------------------------------------------
utils.fileExistsSync = (name) ->
    return fs.existsSync name if fs.existsSync
    return path.existsSync(name)

#-------------------------------------------------------------------------------
utils.replaceTilde = (fileName) ->
    tilde = process.env["HOME"] || process.env["USERPROFILE"] || '.'
    return fileName.replace('~', tilde)

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