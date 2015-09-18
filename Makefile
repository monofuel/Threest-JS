all: core_js util_js

start: all
	nodejs threest_main.js

core_js: ./*.coffee
	coffee -cb ./*.coffee

util_js: util/*.coffee
	coffee -cb util/*.coffee
