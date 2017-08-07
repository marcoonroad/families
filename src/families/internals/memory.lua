local export = { }
local weak   = require 'families.internals.weak'

export.structure = setmetatable ({ }, weak.key)
export.prototype = setmetatable ({ }, weak.pair)
export.clones    = setmetatable ({ }, weak.key)
export.updated   = setmetatable ({ }, weak.key)
export.mirror    = setmetatable ({ }, weak.key)
export.destroyed = setmetatable ({ }, weak.key)

return export

-- END --
