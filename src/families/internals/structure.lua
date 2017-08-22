local export    = { }
local weak      = require 'families.internals.weak'
local memory    = require 'families.internals.memory'
local metatable = { }

---------------------------------------------------------------------

function metatable: __index (selector)
    local value = memory.structure[ self ][ selector ]

    if not rawequal (value, nil) then
        memory.updated[ self ][ selector ] = true

        return value
    end

    -- trampoline-style to avoid depth-stack of coroutines --
    do
        local _
        local scanner = memory.scanner[ self ]

        while memory.scanner[ self ] and
            not memory.updated[ self ][ selector ]
        do
            local thread = scanner or memory.scanner[ self ]

            _, scanner = assert (coroutine.resume (thread))
        end
    end

    return memory.structure[ self ][ selector ]
end

function metatable: __newindex (selector, value)
    memory.structure[ self ][ selector ] = value
    memory.updated  [ self ][ selector ] = true
end

---------------------------------------------------------------------

function export.create (definitions)
    local origin = { }

    memory.structure[ origin ] = definitions
    memory.updated  [ origin ] = setmetatable ({ }, weak.key)

    setmetatable (origin, metatable)

    return origin
end

local function scanmove (sourceID, targetID)
    local scanner

    scanner = coroutine.create (function ( )
        while memory.scanner[ sourceID ] do
            coroutine.yield (memory.scanner[ sourceID ])
        end

        -- must be here to avoid unexpected stuff later --
        local dictionary = memory.structure[ sourceID ]

        for selector, value in pairs (dictionary) do
            if rawequal (memory.structure[ targetID ][ selector ], nil) and
                not memory.updated[ targetID ][ selector ]
            then
                memory.structure[ targetID ][ selector ] = value
                memory.updated  [ targetID ][ selector ] = true

                coroutine.yield (scanner)
            end
        end

        memory.scanner[ targetID ] = nil
    end)

    return scanner
end

function export.split (originID, definitions)
    local formerID = { }
    local latterID = { }

    memory.structure[ formerID ] = { }
    memory.structure[ latterID ] = definitions or { }

    memory.updated[ formerID ] = setmetatable ({ }, weak.key)
    memory.updated[ latterID ] = setmetatable ({ }, weak.key)

    memory.scanner[ formerID ] = scanmove (originID, formerID)
    memory.scanner[ latterID ] = scanmove (originID, latterID)

    setmetatable (formerID, metatable)
    setmetatable (latterID, metatable)

    return formerID, latterID
end

function export.pairs (origin)
    local _
    local scanner = memory.scanner[ origin ]

    while memory.scanner[ origin ] do
        local thread = scanner or memory.scanner[ origin ]

        _, scanner = assert (coroutine.resume (thread))
    end

    return pairs (memory.structure[ origin ])
end

---------------------------------------------------------------------

return export

-- END --
