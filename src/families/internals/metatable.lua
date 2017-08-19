local export     = { }
local memory     = require 'families.internals.memory'
local reason     = require 'families.internals.reason'

function export: __index (selector)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    local structure = memory.structure[ self ]
    local prototype = memory.prototype[ self ]
    local value     = structure[ selector ]

    if rawequal (value, nil) and (not rawequal (prototype, nil))
        and (not memory.updated[ self ][ selector ])
    then
        value = prototype[ selector ]

        -- polymorphic inline cache --
        structure             [ selector ] = value
        memory.updated[ self ][ selector ] = true
    end

    return value
end

function export: __newindex (selector, value)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    local previous = self[ selector ] -- triggers __index --

    for clone in pairs (memory.clones[ self ]) do
        -- despite null value, was it changed after cloning? --
        -- if no, lets update that clone with previous value --
        if rawequal (memory.structure[ clone ][ selector ], nil) and
            not memory.updated[ clone ][ selector ]
        then
            memory.structure[ clone ][ selector ] = previous
        end

        memory.updated[ clone ][ selector ] = true
    end

    local structure = memory.structure[ self ]

    -- finally commit everything --
    structure             [ selector ] = value
    memory.updated[ self ][ selector ] = true
end

function export: __gc ( )
    if memory.destroyed[ self ] then
        return
    end

    local structure = memory.structure[ self ]
    local prototype = memory.prototype[ self ]

    -- copy the structure which self represents --
    for selector, value in pairs (structure) do
        for clone in pairs (memory.clones[ self ]) do
            if not memory.updated[ clone ][ selector ] then
                memory.structure[ clone ][ selector ] = value
                memory.updated  [ clone ][ selector ] = true
            end

            if prototype then
                -- link self's clones against self's prototype --
                memory.prototype[ clone ]           = prototype
                memory.clones[ prototype ][ clone ] = true
            end
        end
    end

    -- self is dead --
end

-------------------------------------------------------------------------------

--[[
local unary = {
    __unm      = true, __bnot  = true, __len    = true,
    __call     = true, __pairs = true, __ipairs = true,
    __tostring = true,
}

local binary = {
    __add    = true, __sub  = true, __mul  = true,
    __div    = true, __pow  = true, __idiv = true,
    __mod    = true,
    __eq     = true, __lt   = true, __le   = true,
    __band   = true, __bor  = true, __bxor = true,
    __concat = true, __shl  = true, __shr  = true,
}

local function dispatch (self, selector, object, ...)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    local mirror = reflection.reflect (self)

    if rawequal (mirror, nil) and binary[ selector ] then
        mirror = assert (reflection.reflect (object), reason.invalid.object)
    end

    -- assigns the metatable which reflect avoids to do --
    if rawequal (getmetatable (mirror), nil) then
        setmetatable (mirror, export)
    end

    local value = mirror[ selector ]

    if rawequal (value, nil) then
        error (reason.missing.metamethod: format (selector))

    else
        return value (self, object, ...)
    end
end

local function metamethod (selector)
    return function (self, ...)
        return dispatch (self, selector, ...)
    end
end

-------------------------------------------------------------------------------

for metaevent in pairs (binary) do
    export[ metaevent ] = metamethod (metaevent)
end

for metaevent in pairs (unary) do
    export[ metaevent ] = metamethod (metaevent)
end
]]--

return export

-- END --
