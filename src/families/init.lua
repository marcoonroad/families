local export     = { }
local standard   = require 'families.internals.standard'
local metatable  = require 'families.internals.metatable'

---------------------------------------------------------------------

function export.prototype (structure)
    return export.clone (nil, structure)
end

function export.clone (self, structure)
    local object = standard.clone (self, structure)

    return setmetatable (object, metatable)
end

function export.destroy (self)
    return standard.destroy (self)
end

return export

-- END --
