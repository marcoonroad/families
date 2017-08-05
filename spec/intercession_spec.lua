--
--------------------------------------------------------------------------------
--         File:  intercession_spec.lua
--
--        Usage:  (through busted)
--
--  Description:  Families specification test.
--
--      Options:  ---
-- Requirements:  ---
--         Bugs:  ---
--        Notes:  ---
--       Author:  Marco Aurélio da Silva (marcoonroad at gmail dot com)
-- Organization:  
--      Version:  1.0
--      Created:  04-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

local families = require 'families'

describe ("families reflection", function ( )
    local structure = {
        name   = "Marco Aurélio da Silva",
        age    = 21,
        health = 27,
        mana   = 49,
        level  = 6,
        race   = "Human", -- perhaps --
    }

    local marco = families.prototype (structure)
 
    it ("should iterate the same fields from passed structure", function ( )
       -- ensures the same fields through two iterators --
        for selector, value in pairs (marco) do
            assert.same (value, structure[ selector ])
        end

        for selector, value in pairs (structure) do
            assert.same (value, marco[ selector ])
        end
    end)

    it ("should pretty-print the same string from passed structure", function ( )
        assert.same (tostring (structure), tostring (marco))
    end)

    it ("should delegate binary/unary operations", function ( )
        local previous = getmetatable (structure)

        -- error cant index nil with selector "level" --
        assert.error (function ( )
            setmetatable (structure, {
                __add = function (self, object)
                    return self.level + object
                end,
            })

            assert.same (7, nil + marco)
        end)

        setmetatable (structure, previous)
    end)
end)

-- END --
