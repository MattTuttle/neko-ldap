if BUILTIN_LIBRARIES
libnekoldap_la_CFLAGS = -I$(top_srcdir)/include

all-local: nekoldap.ndll haxelib

nekoldap.o: nekoldap.c
	gcc -O0 -g3 -I${top_srcdir}/include -Wall -c -fmessage-length=0 -MMD -MP -o"$@" "$<"
nekoldap.ndll: nekoldap.o 
	$(CC) -shared -Wl,-soname=nekoldap -o "../nekoldap.ndll" nekoldap.o @STATIC_LIB_LDAP@ @STATIC_LIB_LBER@ @STATIC_LIB_SSL@ @STATIC_LIB_CRYPTO@ @STATIC_LIB_REGEX@ $(LIBS) 

else
lib_LTLIBRARIES = libnekoldap.la
libnekoldap_la_SOURCES = nekoldap.c

all-local: all haxelib

endif

haxelib:
	$(MKDIR_P) $(top_srcdir)/build_haxe/haxelib/nekoldap
	$(MKDIR_P) $(top_srcdir)/build_haxe/haxelib/ndll/@HAXE_OS@
	cp -u $(top_srcdir)/haxe/nekoldap/Ldap.hx $(top_srcdir)/build_haxe/haxelib/nekoldap/Ldap.hx
	cp -u $(top_srcdir)/haxe/nekoldap/LdapException.hx $(top_srcdir)/build_haxe/haxelib/nekoldap/LdapException.hx
	cp -u $(top_srcdir)/haxe/haxelib.xml $(top_srcdir)/build_haxe/haxelib/haxelib.xml
	cp -u @HAXE_LIB_NAME@ $(top_srcdir)/build_haxe/haxelib/ndll/@HAXE_OS@/@HAXELIB_LIB_NAME@
