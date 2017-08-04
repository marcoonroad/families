local detailed = [[
This library provides concatenation-based prototypical inheritance,
heavily optimized with clone families and immutable objects.
]]

package = "families"
version = "0.1-1"

source = {
    url = "git://github.com/marcoonroad/families",
    tag = "v0.1-1",
}

description = {
    summary  = "Concatenation-based prototypes implementation for Lua.",
    detailed = detailed,
    homepage = "http://github.com/marcoonroad/families",
    license  = "MIT/X11",
}

dependencies = {
    "lua >= 5.2, < 5.4",
}

build = {
    type = "builtin",

    modules = {
        [ "families" ] = "src/families/init.lua",
    },
}
