all:
	cd project && haxelib run hxcpp Build.xml
	cd tests && haxe test.hxml
