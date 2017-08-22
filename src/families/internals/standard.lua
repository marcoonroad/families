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

    -- metatable is not defined here to avoid unexpected recursion --
    -- while loading modules from internals library namespace...   --
    return object
end

function export.destroy (self)
    if not memory.structure[ self ] then
        error (reason.invalid.object)
    end

    local finalizer = getmetatable (self).__gc
    finalizer (self)

    memory.destroyed[ self ] = true
end

return export

-- END --
