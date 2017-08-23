local table  = require 'table'
local export = { }

---------------------------------------------------------------------

export.object = table.concat ({
    "The passed value is not a valid object.",
    "Please, ensure that one cloned by this library is used here.",
}, " ")

export.prototype = table.concat ({
    "Passed prototype is invalid.",
    "It must be an object or nil (ex-nihilo).",
}, " ")

export.destroyed = table.concat ({
    "Used object reference was manually destroyed.",
    "Thus it renders itself unusable until garbage collection.",
}, " ")

---------------------------------------------------------------------

return export

-- END --
