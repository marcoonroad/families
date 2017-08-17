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
        memory.token   [ object ] = { }

    else
        memory.token[ object ] = { }

        do
            local objectID = memory.token[ object ]
            local selfID   = memory.token[ self ]

            memory.prototype[ objectID ] = selfID
        end

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
    if memory.destroyed[ self ] or memory.destroyed[ object ] then
        error (reason.invalid.destroyed)
    end

    assert (memory.delegate[ self ],   reason.invalid.object)
    assert (memory.delegate[ object ], reason.invalid.object)

    local selfID   = memory.token[ self ]
    local objectID = memory.token[ object ]

    if rawequal (selfID, objectID) then return true end

    local prototypeID = memory.prototype[ selfID ]

    while prototypeID do
        if rawequal (prototypeID, objectID) then
            return true

        else
            prototypeID = memory.prototype[ prototypeID ]
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
