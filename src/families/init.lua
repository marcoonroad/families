local export    = { }
local weak      = require 'families.internals.weak'
local memory    = require 'families.internals.memory'
local metatable = require 'families.internals.metatable'

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
