--
--------------------------------------------------------------------------------
--         File:  families_spec.lua
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
--      Created:  03-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

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
end)

-- END --
