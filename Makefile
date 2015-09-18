all: core_js util_js

start: all
	node threest_main.js

core_js: ./*.coffee
	coffee -cb ./*.coffee

util_js: util/*.coffee
	coffee -cb util/*.coffee
