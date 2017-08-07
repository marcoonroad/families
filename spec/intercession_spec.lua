#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  intercession_spec.lua
--
--        Usage:  ./intercession_spec.lua
--
--  Description:  Families specification test.
--
--      Options:  ---
-- Requirements:  ---
--         Bugs:  ---
--        Notes:  ---
--       Author:  Marco Aurélio da Silva (marcoonroad at gmail dot com)
-- Organization:  ---
--      Version:  1.0
--      Created:  04-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

require 'busted.runner' ( )

local families = require 'families'
local reason   = require 'families.internals.reason'

describe ("families reflection", function ( )
    local structure = {
        name   = "Marco Aurélio da Silva",
        age    = 21,
        health = 27,
        mana   = 49,
        level  = 6,
        race   = "Human", -- perhaps --
    }

    local function show (self)
        return ("%s [%s]"): format (self.name, self.race)
    end

    local marco = families.prototype (structure)

    do
        local mirror = families.reflect (marco)

        mirror.__tostring = show
    end

    --[[
    it ("should iterate the same fields from passed structure", function ( )
       -- ensures the same fields through two iterators --
        for selector, value in pairs (marco) do
            assert.same (value, structure[ selector ])
        end

        for selector, value in pairs (structure) do
            assert.same (value, marco[ selector ])
        end
    end)
    ]]--

    it ("should pretty-print the same string from passed structure", function ( )
        assert.same (show (structure), tostring (marco))
    end)

    it ("should not reflect on undefined metamethods", function ( )
        assert.error (function ( )
            marco ( ) -- triggers __call metamethod --
        end, reason.missing.metamethod: format ('__call'))
    end)

    --[[
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
    ]]--

    it ("should provide cloning on mirror-level", function ( )
        local twin = families.clone (marco, {
            name = "Marco's Evil Twin",
            race = "Demon",
        })

        assert.same (
            families.reflect (twin).__tostring,
            families.reflect (marco).__tostring
        )
    end)

    it ("should not be able to reflect upon unknown objects", function ( )
        assert.error (function ( )
            families.reflect ("this is not a valid object for this library")
        end, reason.invalid.object)
    end)
end)

-- END --
