# Travis-CI custom script

if [ -d $TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION ]
then
    echo "Reusing cache directory $TRAVIS_CACHE_DIRECTORY..."
else
    mkdir -p $TRAVIS_CACHE_DIRECTORY
    CURRENT_DIRECTORY=`pwd`
    cd $TRAVIS_CACHE_DIRECTORY

    echo "Building lua..."
    curl -R -O http://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz
    tar zxf lua-$LUA_VERSION.tar.gz
    cd lua-$LUA_VERSION
    make linux test
    make local
    cd ..
    echo "Lua is built!"

    ###########################################################################

    echo "Building luarocks..."
    wget https://www.luarocks.org/releases/luarocks-$LUAROCKS_VERSION.tar.gz
    tar zxpf luarocks-$LUAROCKS_VERSION.tar.gz
    cd luarocks-$LUAROCKS_VERSION
    ./configure --with-lua=$TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install \
        --prefix=$TRAVIS_CACHE_DIRECTORY/lua-$LUA_VERSION/install
    make build
    make install
    cd ..
    echo "Luarocks is built!"

    ###########################################################################

    echo "Linking directories..."
    ln -s lua-$LUA_VERSION/install/bin bin
    ln -s lua-$LUA_VERSION/install/lib lib
    ln -s lua-$LUA_VERSION/install/include include
    ln -s lua-$LUA_VERSION/install/share share
    ln -s lua-$LUA_VERSION/install/man man
    echo "Linked directories!"

    ###########################################################################

    echo "Setting up environment..."
    cd $CURRENT_DIRECTORY
    PATH=$TRAVIS_CACHE_DIRECTORY/bin:$PATH
    export PATH
    LD_LIBRARY_PATH=$TRAVIS_CACHE_DIRECTORY/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH
    echo "Configuration is done!"
fi

# END
