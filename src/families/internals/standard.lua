local export    = { }
local memory    = require 'families.internals.memory'
local reason    = require 'families.internals.reason'
local structure = require 'families.internals.structure'
local metatable = require 'families.internals.metatable'

---------------------------------------------------------------------

function export.clone (self, definitions)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    if (not rawequal (self, nil)) and (not memory.delegate[ self ]) then
        error (reason.invalid.prototype)
    end

    local object = { }

    if rawequal (definitions, nil) then
        definitions = { }
    end

    if rawequal (self, nil) then
        memory.delegate[ object ] = structure.create (definitions)

    else
        memory.prototype[ object ] = self

        local former, latter = structure.split (memory.delegate[ self ], definitions)

        memory.delegate[ self ]   = former
        memory.delegate[ object ] = latter
    end

    setmetatable (object, metatable)

    return object
end

---------------------------------------------------------------------

-- resemblance is transitive and reflexive --
function export.resembles (self, object)
    if rawequal (self, object) then return true end

    local prototype = memory.prototype[ self ]

    while prototype do
        if rawequal (prototype, object) then
            return true

        else
            prototype = memory.prototype[ prototype ]
        end
    end

    return false
end

---------------------------------------------------------------------

function export.destroy (self)
    if rawequal (memory.delegate[ self ], nil) and not memory.destroyed[ self ] then
        error (reason.invalid.object)
    end

    memory.destroyed[ self ] = true
    memory.delegate[ self ]  = nil
end

function export.pairs (self)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    if memory.delegate[ self ] then
        return structure.pairs (memory.delegate[ self ])

    else
        error (reason.invalid.object)
    end
end

---------------------------------------------------------------------

return export

-- END --
