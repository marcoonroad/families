local export = { }
local memory = require 'families.internals.memory'
local reason = require 'families.internals.reason'

function export: __index (selector)
    local ID = memory.token[ self ]

    if memory.destroyed[ ID ] then
        error (reason.invalid.destroyed)
    end

    local structure = memory.structure[ ID ]
    local prototype = memory.prototype[ ID ]
    local value     = structure[ selector ]

    if rawequal (value, nil) and (not rawequal (prototype, nil))
        and (not memory.updated[ ID ][ selector ])
    then
        value = prototype[ selector ]

        -- polymorphic inline cache --
        structure           [ selector ] = value
        memory.updated[ ID ][ selector ] = true
    end

    return value
end

function export: __newindex (selector, value)
    local ID = memory.token[ self ]

    if memory.destroyed[ ID ] then
        error (reason.invalid.destroyed)
    end

    local previous = self[ selector ] -- triggers __index --

    for clone in pairs (memory.clones[ ID ]) do
        -- despite null value, was it changed after cloning? --
        -- if no, lets update that clone with previous value --
        local cloneID = memory.token[ clone ]

        if rawequal (memory.structure[ cloneID ][ selector ], nil) and
            not memory.updated[ cloneID ][ selector ]
        then
            memory.structure[ cloneID ][ selector ] = previous
        end

        memory.updated[ cloneID ][ selector ] = true
    end

    local structure = memory.structure[ ID ]

    -- finally commit everything --
    structure           [ selector ] = value
    memory.updated[ ID ][ selector ] = true
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
