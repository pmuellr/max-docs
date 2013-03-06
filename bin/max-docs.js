#!/usr/bin/env node

// Licensed under the Tumbolia Public License. See footer for details.

var path = require('path')
var fs   = require('fs')

var rootPath = path.dirname(fs.realpathSync(__filename))
var coffee   = path.join(rootPath, '..', 'node_modules', 'coffee-script')
var cli      = path.join(rootPath, '..', 'lib', 'cli')

require(coffee)
require(cli).run()

//------------------------------------------------------------------------------
// Copyright (c) 2013 Patrick Mueller
//
// Tumbolia Public License
//
// Copying and distribution of this file, with or without modification, are
// permitted in any medium without royalty provided the copyright notice and
// this notice are preserved.
//
// TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
//
//   0. opan saurce LOL
//------------------------------------------------------------------------------