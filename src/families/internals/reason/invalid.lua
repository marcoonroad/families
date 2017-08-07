local export = { }

export.object    = "The passed value is not an object cloned by this library."
export.prototype = "Passed prototype is invalid. It must be an object or nil (ex-nihilo)."
export.destroyed = "Reference was manually destroyed, so it renders itself unusable."

return export

-- END --
