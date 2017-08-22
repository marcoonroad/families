local export    = { }
local standard  = require 'families.internals.standard'

---------------------------------------------------------------------

function export.prototype (structure)
    return export.clone (nil, structure)
end

function export.clone (self, structure)
    return standard.clone (self, structure)
end

function export.destroy (self)
    return standard.destroy (self)
end

function export.pairs (self)
    return standard.pairs (self)
end

---------------------------------------------------------------------

return export

-- END --
