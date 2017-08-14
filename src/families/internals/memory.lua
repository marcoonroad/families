local export = { }
local weak   = require 'families.internals.weak'

                                                 --| key    -> value
                                                ------------------------------------
export.structure = setmetatable ({ }, weak.key)  --| ID     -> table
export.prototype = setmetatable ({ }, weak.pair) --| ID     -> object
export.clones    = setmetatable ({ }, weak.key)  --| ID     -> object   -> boolean
export.updated   = setmetatable ({ }, weak.key)  --| ID     -> selector -> boolean
export.destroyed = setmetatable ({ }, weak.key)  --| ID     -> boolean
export.token     = setmetatable ({ }, weak.key)  --| object -> ID

return export

-- END --
