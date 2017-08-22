local export = { }
local memory = require 'families.internals.memory'
local reason = require 'families.internals.reason'

-------------------------------------------------------------------------------

function export: __index (selector)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    local value = memory.delegate[ self ][ selector ]

    if rawequal (value, nil) then
        error (reason.missing.property: format (selector))

    else
        return value
    end
end

function export: __newindex (selector, value)
    if memory.destroyed[ self ] then
        error (reason.invalid.destroyed)
    end

    memory.delegate[ self ][ selector ] = value
end

---------------------------------------------------------------------

return export

-- END --
