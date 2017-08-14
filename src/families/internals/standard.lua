local export = { }
local token  = require 'families.internals.token'
local memory = require 'families.internals.memory'
local weak   = require 'families.internals.weak'
local reason = require 'families.internals.reason'

function export.clone (self, structure)
    if (not rawequal (self, nil)) and (not memory.token[ self ]) then
        error (reason.invalid.prototype)
    end

    if rawequal (structure, nil) then
        structure = { }
    end

    local object = { }
    local ID     = token.generate ( )

    memory.token    [ object ] = ID
    memory.prototype[ ID ]     = self
    memory.structure[ ID ]     = structure
    memory.clones   [ ID ]     = setmetatable ({ }, weak.key)
    memory.updated  [ ID ]     = { }

    do
        if not rawequal (self, nil) then
            local prototypeID = memory.token[ self ]

            memory.clones[ prototypeID ][ object ] = true
        end
    end

    -- metatable is not defined here to avoid unexpected recursion --
    -- while loading modules from internals library namespace...   --
    return object
end

---------------------------------------------------------------------

function export.resembles (self, object)
    local ID        = memory.token    [ self ]
    local prototype = memory.prototype[ ID ]

    while not rawequal (prototype, nil) do
        if rawequal (prototype, object) then
            return true

        else
            ID        = memory.token    [ prototype ]
            prototype = memory.prototype[ ID ]
        end
    end

    return false
end

---------------------------------------------------------------------

function export.destroy (self)
    local ID = memory.token[ self ]

    if rawequal (ID, nil) then
        error (reason.invalid.object)
    end

    local finalizer = token.inspect (ID).__gc
    finalizer (ID)

    memory.destroyed[ ID ] = true
end

---------------------------------------------------------------------

return export

-- END --
