# Licensed under the Tumbolia Public License. See footer for details.

fs   = require "fs"
path = require "path"
util = require "util"

_          = require "underscore"
htmlparser = require "htmlparser"
coffee     = require "coffee-script"
less       = require "less"

pkg      = require "../package.json"
DOM      = require "./DOM"
utils    = require "./utils"

maxDocs = exports

logger = null

#-------------------------------------------------------------------------------
maxDocs.start = (baseDir, opts) ->
    opts           = opts || {}
    opts.logger    = utils.logger pkg.name, opts

    logger = opts.logger

    logger.vlog "opts:       #{JSON.stringify(opts, null, 4)}"
    logger.vlog "processing: #{baseDir}"

    movie = "tutorials/max-tut/tutorialzero.mov"

    mkdirp opts.output

    processRef baseDir, "jit", "Max reference: Jitter",       opts
    processRef baseDir, "max", "Max reference: Max",          opts
    processRef baseDir, "msp", "MSP reference: Max",          opts
    processRef baseDir, "m4l", "Max reference: Max for Live", opts

    processTut baseDir, "jit", "Max tutorial: Jitter", opts
    processTut baseDir, "max", "Max tutorial: Max",    opts
    processTut baseDir, "msp", "Max tutorial: MSP",    opts

#-------------------------------------------------------------------------------
copyStaticFiles = (type, name, opts) ->
    copyFile "#{__dirname}/static/jquery.js",     "#{opts.output}/#{type}/#{name}/jquery.js"
    copyFile "#{__dirname}/static/jquery.min.js", "#{opts.output}/#{type}/#{name}/jquery.min.js"

    compileCoffee "#{__dirname}/static/#{type}.coffee", "#{opts.output}/#{type}/#{name}/#{type}.js"
    compileLess   "#{__dirname}/static/#{type}.less",   "#{opts.output}/#{type}/#{name}/#{type}.css"

#-------------------------------------------------------------------------------
compileCoffee = (iFile, oFile) ->
    contents = fs.readFileSync iFile, "utf8"
    contents = coffee.compile contents
    fs.writeFileSync oFile, contents

#-------------------------------------------------------------------------------
compileLess = (iFile, oFile) ->
    contents = fs.readFileSync iFile, "utf8"

    less.render contents, (err, contents) ->
        if err?
            logger.err "error compiling #{iFile}: #{err}"

        fs.writeFileSync oFile, contents

#-------------------------------------------------------------------------------
processRef = (baseDir, name, title, opts) ->
    opts.logger.log "building reference #{name}"

    iDir = "#{baseDir}/refpages/#{name}-ref"
    oDir = "#{opts.output}/ref/#{name}"

    mkdirp oDir

    copyStaticFiles "ref", name, opts

#-------------------------------------------------------------------------------
processTut = (baseDir, name, title, opts) ->
    opts.logger.log "building tutorial #{name}"

    iDir = "#{baseDir}/tutorials/#{name}-tut"
    oDir = "#{opts.output}/tut/#{name}"

    mkdirp oDir

    if fs.existsSync "#{iDir}/images"
        copyFiles "#{iDir}/images", "#{oDir}/images"

    html = []; h = (line) -> html.push line

    h "<!doctype html>"
    h "<head>"
    h "<title>#{title}</title>"
    h "<link href='tut.css' rel='stylesheet'>"
    h "<script src='jquery.min.js'></script>"
    h "<script src='tut.js'></script>"
    h "</head>"
    h "<body>"

    index    = "#{iDir}/#{name}index.maxtut.xml"
    dom      = parseXML index
    sections = dom.getElements dom, "subhead"

    for section in sections
        h ""
        h "<!-- ======================================================================= -->"
        h "<h1>Topic: #{dom.getText section}</h1>"
        h ""
        h "<div class=indent>"
        ul  = dom.getNextElement section, "ul"
        lis = dom.getElements ul, "li"

        for li in lis
            link = dom.getNextElement li, "link"
            doc  = link.attribs.name

            h ""
            h "<!-- ======================================================================= -->"
            h "<h2>#{dom.getText li}</h2>"
            h ""
            h "<div class=indent>"

            domArticle = parseXML "#{iDir}/#{doc}.maxtut.xml"
            domArticle = massageXML domArticle
            xml = DOMtoXML domArticle

            h  xml
            h "</div>"

        h ""
        h "</div>"

    h "</body>"
    h "</html>"

    oFile = "#{oDir}/index.html"
    fs.writeFileSync oFile, html.join "\n"
    logger.log "wrote file tut/#{name}/index.html"

    copyStaticFiles "tut", name, opts


#-------------------------------------------------------------------------------
parseXML = (file) ->
    contents = fs.readFileSync file, "utf8"

    handler = new htmlparser.DefaultHandler (error, dom) ->
        logger.err "error parsing file #{file}: #{error}" if error

    parser = new htmlparser.Parser(handler)
    parser.parseComplete(contents)

    return new DOM handler.dom

#-------------------------------------------------------------------------------
copyFiles = (iDir, oDir) ->
#    logger.vlog "copying files from #{iDir} to #{oDir}"

    mkdirp oDir

    files = fs.readdirSync iDir
    for file in files
        iFile = "#{iDir}/#{file}"
        oFile = "#{oDir}/#{file}"

        stats = fs.statSync iFile
        if stats.isDirectory()
            copyFiles iFile, oFile

        else
            copyFile iFile, oFile

#-------------------------------------------------------------------------------
copyFile = (iFile, oFile) ->
    fs.writeFileSync oFile, fs.readFileSync iFile
    stats = fs.statSync iFile
    fs.utimesSync oFile, stats.atime, stats.mtime

#-------------------------------------------------------------------------------
DOMtoXML = (dom) ->
    result = []

    nodesToXML(dom.root.children, result)

    return result.join ""

#-------------------------------------------------------------------------------
nodesToXML = (nodes, result) ->
    for node in nodes
        if node.type == "tag"
            result.push "<#{node.raw}>"
        else
            result.push node.raw

        nodesToXML node.children, result

        if node.type == "tag"
            result.push "</#{node.name}>"

#-------------------------------------------------------------------------------
massageXML = (dom) ->
    if false
        console.log "massageXML: #{JSON.stringify(dom.root,null, 4)}"
        process.exit()

    nodes = massageNodes dom.root.children

    return new DOM nodes

#-------------------------------------------------------------------------------
massageNodes = (nodes) ->
    result = []

    for node in nodes
        continue if node.type == "directive"

        if node.type is "tag"
            if node.name is "body"
                node.name = "bodydiv"
                node.raw  = "bodydiv"

            if node.name is "example"
                node.name = "img"
                node.raw  = "img src='#{node.attribs.name}'"

            if node.name is "subhead"
                node.name = "h3"
                node.raw  = "h3"

        node.children = massageNodes node.children

        result.push node

    return result

#-------------------------------------------------------------------------------
mkdirp = (dir) ->
    return if fs.existsSync dir

    parentDir = path.dirname dir
    if !fs.existsSync parentDir
        mkdirp parentDir

    fs.mkdirSync dir

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