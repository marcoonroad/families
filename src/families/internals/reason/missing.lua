local table  = require 'table'
local export = { }

---------------------------------------------------------------------

export.property = table.concat ({
    "The property for selector [%s] is not defined",
    "(Was it erased? Check it out in the code!).",
}, " ")

---------------------------------------------------------------------

return export

-- END --
