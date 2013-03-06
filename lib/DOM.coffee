# Licensed under the Tumbolia Public License. See footer for details.

#-------------------------------------------------------------------------------
module.exports = class DOM

    #---------------------------------------------------------------------------
    constructor: (nodes) ->
#        console.log "DOM(): nodes: #{JSON.stringify nodes, null, 4}"

        @index = []
        @root  = children: nodes

        assignIds    @root, @index
        addRelatives @root

#        console.log "DOM(): @index: #{JSON.stringify @index, null, 4}"
#        console.log "DOM(): @root:  #{JSON.stringify @root,  null, 4}"

    #---------------------------------------------------------------------------
    getNextElement: (node, tag) ->
#        console.log "DOM.getNextElement('#{tag}', #{@dumpNode node})"
        node = @root if node is @

        if node.type == "tag"
            if node.name == tag
                return node

        for child in node.children
            result = @getNextElement child, tag
            if result?
#                console.log "DOM.getNextElement('#{tag}', #{@dumpNode node}) -> #{@dumpNode result})"
                return result 

        if !node.next?
#            console.log "DOM.getNextElement('#{tag}', #{@dumpNode node}) -> null"
            return null 

        return @getNextElement @index[node.next], tag

    #---------------------------------------------------------------------------
    getElements: (node, tag, result) ->
#       console.log "DOM.getElements(#{tag}, #{@dumpNode node})"
        node = @root if node is @

        result = result || []

        if node.type == "tag"
            if node.name == tag
                result.push node

        for child in node.children
            @getElements child, tag, result

        return result

    #---------------------------------------------------------------------------
    getText: (node) ->
#        console.log "DOM.getText(#{@dumpNode node})"

        node = @root if node is @

        result = ""

        result += node.data if node.type == "text"

        for child in node.children
            result += @getText child

        return result

    #---------------------------------------------------------------------------
    dumpNode: (node) ->
        dumped = 
            id:   node.id
            type: node.type
            data: node.data

        return JSON.stringify dumped

#-------------------------------------------------------------------------------
assignIds = (node, index) ->
    node.id = index.length
    index.push node

    node.children = [] if !node.children?

    for child in node.children
        assignIds child, index

#-------------------------------------------------------------------------------
addRelatives = (node, parent) ->
    node.parent = parent.id if parent?

    for i in [0...node.children.length]
        nodePrev   = node.children[i-1]
        child      = node.children[i]
        nodeNext   = node.children[i+1]

        child.prev = nodePrev.id if nodePrev?
        child.next = nodeNext.id if nodeNext?

        addRelatives child, node

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