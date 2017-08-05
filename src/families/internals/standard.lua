local export    = { }
local memory    = require 'families.internals.memory'
local weak      = require 'families.internals.weak'

function export.clone (self, structure)
    local object = { }

    memory.prototype[ object ] = self
    memory.structure[ object ] = structure
    memory.clones   [ object ] = setmetatable ({ }, weak.key)
    memory.updated  [ object ] = setmetatable ({ }, weak.key)

    if (not rawequal (self, nil)) and memory.structure[ self ] then
        memory.clones[ self ][ object ] = true
    end

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

return export

-- END --
