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
        memory.level   [ object ] = 0
        memory.delegate[ object ] = structure.create (definitions)
        --[[
        memory.token   [ object ] = { }
        ]]--

    else
        --[[
        memory.token[ object ] = { }

        do
            local objectID = memory.token[ object ]
            local selfID   = memory.token[ self ]

            memory.prototype[ objectID ] = selfID
        end
        ]]--

        local former, latter = structure.split (memory.delegate[ self ], definitions)

        memory.level   [ object ] = memory.level[ self ] + 1
        memory.delegate[ self ]   = former
        memory.delegate[ object ] = latter
    end

    setmetatable (object, metatable)

    -- force iteration --
    if memory.level[ object ] % 100 == 0 then
        for _, _ in export.pairs (object) do
        end
    end

    return object
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
