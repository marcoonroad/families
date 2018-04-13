# Travis-CI custom script

function fail-build {
    echo "!!! FAILED TO BUILD. exiting..." && exit
}

function build-luaenv {
    mkdir -p $TRAVIS_CACHE_DIRECTORY
    CURRENT_DIRECTORY=`pwd`
    cd $TRAVIS_CACHE_DIRECTORY

    echo ""
    echo "==========================================================="
    echo "*** Building lua..."
    curl -R -O http://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz && \
    tar zxf lua-$LUA_VERSION.tar.gz && \
    cd lua-$LUA_VERSION && \
    make linux test && \
    make install INSTALL_TOP=$TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install && \
    cd .. && \
    echo "*** Lua is built!" || fail-build
    echo "==========================================================="
    echo ""

    ###########################################################################

    echo ""
    echo "==========================================================="
    echo "*** Building luarocks..."
    wget --no-check-certificate \
    https://www.luarocks.org/releases/luarocks-$LUAROCKS_VERSION.tar.gz && \
    tar zxpf luarocks-$LUAROCKS_VERSION.tar.gz && \
    cd luarocks-$LUAROCKS_VERSION && \
    ./configure --with-lua=$TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install \
    --prefix=$TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install && \
    make build && \
    make install && \
    cd .. && \
    echo "*** Luarocks is built!" || fail-build
    echo "==========================================================="
    echo ""

    ###########################################################################

    echo ""
    echo "==========================================================="
    echo "*** Linking directories..."
    ln -s lua-$LUA_VERSION/install/bin bin
    ln -s lua-$LUA_VERSION/install/lib lib
    ln -s lua-$LUA_VERSION/install/include include
    ln -s lua-$LUA_VERSION/install/share share
    ln -s lua-$LUA_VERSION/install/man man
    cd $CURRENT_DIRECTORY
    echo "*** Linked directories!"
    echo "==========================================================="
    echo ""
}

if [ $REBUILD_LUA ]
then
    build-luaenv
fi

if [ -d $TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install ]
then
    echo ""
    echo "==========================================================="
    echo "*** Reusing cache directory $TRAVIS_CACHE_DIRECTORY..."
    echo "==========================================================="
    echo ""
else
    build-luaenv
fi

echo ""
echo "==============================================================="
echo "*** Setting up environment..."
PATH=$TRAVIS_CACHE_DIRECTORY/bin:$PATH
export PATH
LD_LIBRARY_PATH=$TRAVIS_CACHE_DIRECTORY/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
MANPATH=$TRAVIS_CACHE_DIRECTORY/man:$MANPATH
export MANPATH
echo "*** Configuration is done!"
echo "==============================================================="
echo ""

# END
