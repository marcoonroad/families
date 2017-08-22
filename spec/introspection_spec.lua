#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  families_spec.lua
--
--        Usage:  ./introspection_spec.lua
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
--      Created:  03-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

require 'busted.runner' ( )

local families = require 'families'

describe ("families introspection", function ( )
    local hosggar = families.prototype {
        name     = "Hosggar",
        class    = "Viking",
        race     = "Human",
        gender   = "Genderfluid",
        affinity = { "Metal", },
    }

    local asterinn = families.clone (hosggar, {
        name     = "Asterinn",
        class    = "Valkyrie",
        gender   = "Agender",
        affinity = { "Thunder", "Metal", "Wood", },
        father   = hosggar,
    })

    local robiearj = families.clone (hosggar, {
        name     = "Robiearj",
        gender   = "Transgender",
        affinity = { "Ice", },
        father   = hosggar,
        sister   = asterinn,
    })
end)

-- END --
