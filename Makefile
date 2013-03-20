# Licensed under the Tumbolia Public License. See footer for details.

.PHONY: lib test

all: help

#-------------------------------------------------------------------------------
check-deps:
	@-mkdir -p tmp

	@echo "local status:"
	@echo $(PROGRAM)    > tmp/process-ls.js
	@npm ls --json> tmp/ls.json
	@node tmp/process-ls.js
	@echo " "
	@echo "npm status:"
	@echo "   coffee-script:" 	"`npm view coffee-script version`"
	@echo "   htmlparser:" 		"`npm view htmlparser    version`"
	@echo "   less:" 			"`npm view less          version`"
	@echo "   nopt:" 			"`npm view nopt          version`"
	@echo "   underscore:" 		"`npm view underscore    version`"
	@echo "   wr:" 				"`npm view wr            version`"

PROGRAM = "fs = require(\"fs\");json = fs.readFileSync(\"tmp/ls.json\"); json = JSON.parse(json); for (var dep in json.dependencies) {version = json.dependencies[dep].version; console.log(\"   \" + dep + \": \" + version);}"

#-------------------------------------------------------------------------------
clean:  
	@echo "cleaning up"
	@rm -rf  tmp/*

#-------------------------------------------------------------------------------
watch:
	node_modules/.bin/wr \
		"make run" \
		bin lib Makefile

#-------------------------------------------------------------------------------
run: 
	@-mkdir -p tmp
	@-rm -rf   tmp/*

	@bin/max-docs.js --output tmp --verbose "/Applications/Max 6.1/patches/docs"	

#-------------------------------------------------------------------------------
vendor: \
	vendor-jquery

#-------------------------------------------------------------------------------
vendor-jquery:
	@echo "installing jquery"

	@curl --progress-bar -o lib/static/jquery.min.js  $(JQUERY_URL).min.js
	@curl --progress-bar -o lib/static/jquery.js      $(JQUERY_URL).js

JQUERY_URL = http://code.jquery.com/jquery-1.9.0

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo "   clean  - erase built files"
	@echo "   run    - run the app"
	@echo "   watch  - watch for source changes, then restart the server"
	@echo "   help   - print this help"

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

