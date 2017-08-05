local export = { }
local memory = require 'families.internals.memory'

function export: __index (selector)
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

function export: __newindex (selector, value)
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

function export: __gc ( )
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

function export: __pairs ( )
    return pairs (memory.structure[ self ])
end

function export: __tostring ( )
    return tostring (memory.structure[ self ])
end

function export: __add (object)
    local structure = memory.structure[ self ]

    if rawequal (structure, nil) then
        -- object is who triggers this metamethod --
        return self + memory.structure[ object ]

    else
        return structure + object
    end
end

function export: __sub (object)
    local structure = memory.structure[ self ]

    if rawequal (structure, nil) then
        return self - memory.structure[ object ]

    else
        return structure - object
    end
end

function export: __mul (object)
    local structure = memory.structure[ self ]

    if rawequal (structure, nil) then
        return self * memory.structure[ object ]

    else
        return structure * object
    end
end

function export: __div (object)
    local structure = memory.structure[ self ]

    if rawequal (structure, nil) then
        return self / memory.structure[ object ]

    else
        return structure / object
    end
end

function export: __mod (object)
    local structure = memory.structure[ self ]

    if rawequal (structure, nil) then
        return self % memory.structure[ object ]

    else
        return structure % object
    end
end

function export: __call (...)
    return memory.structure[ self ] (...)
end

return export

-- END --
