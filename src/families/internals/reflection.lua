local export   = { }
local standard = require 'families.internals.standard'
local memory   = require 'families.internals.memory'

-- low level function generating mirrors  --
-- don't use it directly, instead, use a  --
-- higher level version. also doesn't set --
-- a metatable to avoid unexpected        --
-- recursion among module dependecies...  --
function export.reflect (self)
    if rawequal (memory.structure[ self ], nil) then
        return nil
    end

    local mirror = memory.mirror[ self ]

    -- lazily computes mirrors --
    if rawequal (mirror, nil) then
        local prototype = memory.prototype[ self ]

        if rawequal (prototype, nil) then
            memory.mirror[ self ] = standard.clone (nil, { })

        else
            memory.mirror[ self ] = standard.clone (export.reflect (prototype), { })
        end

        return memory.mirror[ self ]

    else
        return mirror
    end
end

return export

-- END --
