local export     = { }
local reflection = require 'families.internals.reflection'
local standard   = require 'families.internals.standard'
local reason     = require 'families.internals.reason'
local metatable  = require 'families.internals.metatable'

---------------------------------------------------------------------

function export.prototype (structure)
    return export.clone (nil, structure)
end

function export.clone (self, structure)
    local object = standard.clone (self, structure)

    return setmetatable (object, metatable)
end

function export.resembles (self, object)
    return standard.resembles (self, object)
end

function export.represents (self, object)
    return export.resembles (object, self)
end

function export.reflect (self)
    local mirror = assert (reflection.reflect (self), reason.invalid.object)

    -- lazily attachs a metatable --
    if rawequal (getmetatable (mirror), nil) then
        setmetatable (mirror, metatable)
    end

    return mirror
end

function export.destroy (self)
    return standard.destroy (self)
end

return export

-- END --
