.PHONY: build test

all: build test

build:
	cd project && haxelib run hxcpp Build.xml
	cd project && haxelib run hxcpp Build.xml -DHXCPP_M64

test:
	cd tests && haxe test.hxml
