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

describe ("families cloning", function ( )
    local point2d = families.prototype {
        x = 0,
        y = 0,

        move = function (self, x, y)
            self.x = self.x + x
            self.y = self.y + y
        end,
    }

    it ("should clone a prototype", function ( )
        local point3d = families.clone (point2d, { z = 0, })

        assert.equals (point2d.x, point3d.x)
        assert.equals (point2d.y, point3d.y)
    end)

    it ("should be creation-time sharing", function ( )
        local point3d = families.clone (point2d, {
            z = 0,

            move = function (self, x, y, z)
                self.x = self.x + x
                self.y = self.y + y
                self.z = self.z + z
            end,
        })

        -- some mutation occurring here --
        point2d: move (5, 12)

        -- but it's not propagated into clones --
        assert.falsy (point2d.x == point3d.x)
        assert.falsy (point2d.y == point3d.y)
    end)

    it ("should be independent of garbage collection", function ( )
        local unit = families.clone (point2d, {
            x = 1,
            y = 1,

            scale = function (self, k)
                return families.clone (self, {
                    x = self.x * k,
                    y = self.y * k,
                })
            end,
        })

        local double = unit: scale (2)

        -- saving the closure/method beforehand --
        local scale = unit.scale

        -- lets trigger garbage collection --
        unit = nil
        collectgarbage ( )

        assert.truthy (rawequal (scale, double.scale))
    end)
end)

-- END --
