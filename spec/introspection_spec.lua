#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  introspection_spec.lua
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
--      Version:  0.2
--      Created:  03-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

require 'busted.runner' ( )

local families = require 'families'
local reason   = require 'families.internals.reason'

-- TODO
-- reflection by mirrors will improve that.
-- by now, let's only check if the fields
-- match
describe ("families introspection -", function ( )
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

    it ("should iterate even the fields from parents", function ( )
        local properties = {
            name     = true,
            gender   = true,
            class    = true,
            affinity = true,
            race     = true,
            mother   = true,
            sister   = true,
            father   = true,
        }

        for selector, _ in families.pairs (hosggar) do
            assert.truthy (properties[ selector ])
        end

        for selector, _ in families.pairs (asterinn) do
            assert.truthy (properties[ selector ])
        end

        for selector, _ in families.pairs (robiearj) do
            assert.truthy (properties[ selector ])
        end

        assert.error (function ( )
            for _, _ in families.pairs (5) do
            end
        end, reason.invalid.object)

        assert.error (function ( )
            local twin = families.clone (hosggar, {
                name     = "Hosggar's Evil Twin",
                class    = "Human Slayer",
                race     = "Demon/Dragon",
                gender   = "Bigender",
                affinity = { "Dark", "Cosmos", "Light", "Ethereal", "Shade", },
            })

            families.destroy (twin)
            families.destroy (twin)
            families.destroy (twin)
            -- we should ensure that this evil creature --
            -- is indeed dead. be careful anyways...    --

            -- here comes the error --
            for _, _ in families.pairs (twin) do
            end
        end, reason.invalid.destroyed)
    end)
end)

-- END --
