# Licensed under the Tumbolia Public License. See footer for details.

fs   = require "fs"
path = require "path"
util = require "util"

_    = require "underscore"
nopt = require "nopt"

pkg      = require "../package.json"
utils    = require "./utils"
maxDocs  = require "./max-docs"

cli = exports

#-------------------------------------------------------------------------------
cli.run = ->
    cmdLine = process.argv[2..]

    [dir, opts] = parse cmdLine

    maxDocs.start dir, opts

#-------------------------------------------------------------------------------
# parse the command-line options
# will set the following properties on the exported object
# - argv     non-option parameters
# - config   name of the config file
# - port     port number to run the server on
# - verbose  whether to emit verbose messages
#-------------------------------------------------------------------------------
parse = (argv) ->

    optionSpecs =
        output:     path
        verbose:    Boolean
        help:       Boolean

    shortHands =
        o:   "--output"
        v:   "--verbose"
        "?": "--help"
        h:   "--help"

    help() if argv[0] == "?"

    parsed = nopt(optionSpecs, shortHands, argv, 0)

    help() if parsed.help

    defOptions =
        output:  "."
        verbose: false

    cmdOptions = _.pick parsed, "verbose output".split " "

    options = _.defaults cmdOptions, defOptions

    dir = parsed.argv.remain[0]
    help() if !dir?

    dir            = normalizeDir "parameter",     dir
    options.output = normalizeDir "option output", options.output

    return [dir, options]

#-------------------------------------------------------------------------------
normalizeDir = (label, dir) ->
    dir = path.resolve utils.replaceTilde dir

    if !utils.fileExistsSync dir
        err "directory not found for #{label}: #{dir}"

    stats = fs.statSync dir
    if !stats.isDirectory()
        err "directory is not a directory for #{label}: #{dir}"

    return dir

#-------------------------------------------------------------------------------
err = (message) ->
    console.log "#{pkg.name}: #{message}"
    process.exit 1

#-------------------------------------------------------------------------------
help = ->
    text =  """
            #{pkg.name} #{pkg.version}

                generate Max docs

            usage:
                #{pkg.name} [options] dir

            The directory for Max 6.1 on the Mac is:

                /Applications/Max 6.1/patches/docs

            options:
                -o --output dir     the directory to write the output to
                -v --verbose        be noisy
                -h --help           display this help
            """
    console.log text
    process.exit()

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