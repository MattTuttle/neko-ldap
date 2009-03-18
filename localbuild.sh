#!/bin/bash
echo aclocal
aclocal
echo autoconf
autoconf
echo automake
automake
cd localbuild
make distclean
echo configure
../configure
make