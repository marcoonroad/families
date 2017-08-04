local export = { }

local weak = {
    key   = { __mode = 'k', },
    value = { __mode = 'v', },
    pair  = { __mode = 'kv', },
}

local memory = { }

memory.structure = setmetatable ({ }, weak.key)
memory.prototype = setmetatable ({ }, weak.pair)
memory.clones    = setmetatable ({ }, weak.key)
memory.updated   = setmetatable ({ }, weak.key)

---------------------------------------------------------------------

local metatable = { }

function metatable: __index (selector)
    local structure = memory.structure[ self ]
    local prototype = memory.prototype[ self ]
    local value     = structure[ selector ]

    if rawequal (value, nil) and not rawequal (prototype, nil) then
        value = prototype[ selector ]

        -- polymorphic inline cache --
        structure             [ selector ] = value
        memory.updated[ self ][ selector ] = true
    end

    return value
end

function metatable: __newindex (selector, value)
    local structure = memory.structure[ self ]

    -- no need for propagation of changes --
    if memory.updated[ self ][ selector ] then
        structure[ selector ] = value

        return
    end

    local previous = self[ selector ] -- triggers __index --

    for clone in pairs (memory.clones[ self ]) do
        if memory.updated[ clone ][ selector ] then
            -- just skip it --

        else
            memory.structure[ clone ][ selector ] = previous
            memory.updated  [ clone ][ selector ] = true
        end
    end

    -- finally commit everything --
    structure             [ selector ] = value
    memory.updated[ self ][ selector ] = true
end

function metatable: __gc ( )
    local structure = memory.structure[ self ]
    local prototype = memory.prototype[ self ]

    -- copy the structure which self represents --
    for selector, value in pairs (structure) do
        for clone in pairs (memory.clones[ self ]) do
            if memory.updated[ clone ][ selector ] then
                -- do nothing else --

            else
                memory.structure[ clone ][ selector ] = value
                memory.updated  [ clone ][ selector ] = true
            end

            -- link self's clones against self's prototype --
            memory.prototype          [ clone ] = prototype
            memory.clones[ prototype ][ clone ] = true
        end
    end

    -- self is dead --
end

---------------------------------------------------------------------

function export.prototype (structure)
    return export.clone (nil, structure)
end

function export.clone (self, structure)
    local object = { }

    memory.prototype[ object ] = self
    memory.structure[ object ] = structure
    memory.clones   [ object ] = setmetatable ({ }, weak.key)
    memory.updated  [ object ] = setmetatable ({ }, weak.key)

    if (not rawequal (self, nil)) and memory.structure[ self ] then
        memory.clones[ self ][ object ] = true
    end

    setmetatable (object, metatable)

    return object
end

function export.resembles (self, object)
    local prototype = memory.prototype[ self ]

    while not rawequal (prototype, nil) do
        if rawequal (prototype, object) then
            return true

        else
            prototype = memory.prototype[ prototype ]
        end
    end

    return false
end

function export.represents (self, object)
    return export.resembles (object, self)
end

return export

-- END --
