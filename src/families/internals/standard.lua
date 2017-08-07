local export    = { }
local memory    = require 'families.internals.memory'
local weak      = require 'families.internals.weak'
local reason    = require 'families.internals.reason'

function export.clone (self, structure)
    if (not rawequal (self, nil)) and (not memory.structure[ self ]) then
        error (reason.invalid.prototype)
    end

    if rawequal (structure, nil) then
        structure = { }
    end

    local object = { }

    memory.prototype[ object ] = self
    memory.structure[ object ] = structure
    memory.clones   [ object ] = setmetatable ({ }, weak.key)
    memory.updated  [ object ] = { }

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

function export.destroy (self)
    if not memory.structure[ self ] then
        error (reason.invalid.object)
    end

    local finalizer = getmetatable (self).__gc

    memory.destroyed[ self ] = true

    finalizer (self)
end

return export

-- END --
