local export    = { }
local memory    = require 'families.internals.memory'

---------------------------------------------------------------------

local metatable = {
    __gc = function (ID)
        if memory.destroyed[ ID ] then
            return
        end

        local structure   = memory.structure[ ID ]
        local prototype   = memory.prototype[ ID ]
        local prototypeID = memory.token[ prototype ]

        -- copy the structure which self represents --
        for selector, value in pairs (structure) do
            for clone in pairs (memory.clones[ ID ]) do
                local cloneID = memory.token[ clone ]

                if not memory.updated[ cloneID ][ selector ] then
                    memory.structure[ cloneID ][ selector ] = value
                    memory.updated  [ cloneID ][ selector ] = true
                end

                -- link self's clones against self's prototype --
                memory.prototype            [ clone ] = prototype
                memory.clones[ prototypeID ][ clone ] = true
            end
        end

        -- ID is dead --
    end,
}

---------------------------------------------------------------------

local generate
local reflect
local inspect

-- workaround to get 100% coverage --
do
    local detect = {
        [ "Lua 5.1" ] = {
            generate = newproxy,
            reflect  = debug.setmetatable,
            inspect  = debug.getmetatable,
        },
        [ "Lua 5.2" ] = {
            generate = function ( ) return { } end,
            reflect  = setmetatable,
            inspect  = getmetatable,
        },
    }

    detect[ "Lua 5.3" ] = detect[ "Lua 5.2" ]

    generate = detect[ _VERSION ].generate
    reflect  = detect[ _VERSION ].reflect
    inspect  = detect[ _VERSION ].inspect
end

---------------------------------------------------------------------

function export.generate ( )
    local token = generate ( )

    reflect (token, metatable)

    return token
end

export.inspect = inspect

---------------------------------------------------------------------

return export

-- END --
