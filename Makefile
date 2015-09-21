all: core_js util_js


start: all
	node threest_main.js

web: all
	browserify threest_web.js -o threest_bundle.js

electron: all web
	electron .

core_js: ./*.coffee
	coffee -cb ./*.coffee

util_js: util/*.coffee
	coffee -cb util/*.coffee
