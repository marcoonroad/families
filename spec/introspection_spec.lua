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
local reason   = require 'families.internals.reason'

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

    it ("should inspect ancestor", function ( )
        assert.truthy (families.resembles (asterinn, hosggar))
        assert.truthy (families.resembles (robiearj, hosggar))
    end)

    it ("should inspect descendant", function ( )
        assert.truthy (families.represents (hosggar, asterinn))
        assert.truthy (families.represents (hosggar, robiearj))
    end)

    it ("should not be directly related", function ( )
        assert.falsy (families.represents (asterinn, hosggar))
        assert.falsy (families.represents (robiearj, hosggar))
        assert.falsy (families.represents (robiearj, asterinn))
        assert.falsy (families.represents (asterinn, robiearj))

        assert.falsy (families.resembles (hosggar,  asterinn))
        assert.falsy (families.resembles (hosggar,  robiearj))
        assert.falsy (families.resembles (asterinn, robiearj))
        assert.falsy (families.resembles (robiearj, asterinn))
    end)

    it ("should be transitive as well", function ( )
        local emmania = families.clone (asterinn, {
            name     = "Emmania",
            gender   = "Cisgender",
            class    = "Archer",
            affinity = { "Fire", "Dark", },
            mother   = asterinn,
        })

        assert.truthy (families.resembles (emmania, asterinn))
        assert.truthy (families.resembles (emmania, hosggar))

        assert.truthy (families.represents (asterinn, emmania))
        assert.truthy (families.represents (hosggar, emmania))

        -- non-transitive relations doesn't holds --
        assert.falsy (families.resembles  (emmania,  robiearj))
        assert.falsy (families.represents (robiearj, emmania))
    end)

    it ("should also be reflexive", function ( )
        assert.truthy (families.resembles (hosggar,  hosggar))
        assert.truthy (families.resembles (robiearj, robiearj))
        assert.truthy (families.resembles (asterinn, asterinn))

        assert.truthy (families.represents (hosggar,  hosggar))
        assert.truthy (families.represents (robiearj, robiearj))
        assert.truthy (families.represents (asterinn, asterinn))
    end)

    it ("should not inspect invalid values", function ( )
        assert.error (function ( )
            local _ = families.resembles (5, 4)
        end, reason.invalid.object)

        assert.error (function ( )
            local _ = families.represents ("hey dude", "wait guy")
        end, reason.invalid.object)

        assert.error (function ( )
            local object = families.prototype { }

            families.destroy (object)
            families.destroy (object)

            local _ = families.resembles (object, object)
        end, reason.invalid.destroyed)

        assert.error (function ( )
            local object = families.prototype { }

            families.destroy (object)
            families.destroy (object)

            local _ = families.represents (object, object)
        end, reason.invalid.destroyed)
    end)

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
                affinity = { "Dark", "Cosmos", "Light", "Ethereal", "Shade" },
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
