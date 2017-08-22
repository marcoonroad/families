local export = { }
local weak   = require 'families.internals.weak'

---------------------------------------------------------------------

export.structure = setmetatable ({ }, weak.key)
export.updated   = setmetatable ({ }, weak.key)
export.scanner   = setmetatable ({ }, weak.key)
export.delegate  = setmetatable ({ }, weak.key)
export.destroyed = setmetatable ({ }, weak.key)
export.level     = setmetatable ({ }, weak.key)

---------------------------------------------------------------------

return export

-- END --
