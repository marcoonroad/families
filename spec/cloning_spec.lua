#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  families_spec.lua
--
--        Usage:  ./cloning_spec.lua
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

        point2d: move (-5, -12)
    end)

    it ("should make the clone independent from prototype and vice-versa", function ( )
        local clone = families.clone (point2d, { })

        -- some mutation on cloned object here --
        clone: move (7, 3)

        -- but the prototype won't be aware of that --
        assert.falsy (point2d.x == clone.x)
        assert.falsy (point2d.y == clone.y)
    end)

    it ("should be independent of garbage collection", function ( )
        local double
        local scale

        do
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

            double = unit: scale (2)

            -- saving the closure/method beforehand --
            scale = unit.scale
        end

        -- unit is not referenced anymore  --
        -- lets trigger garbage collection --
        collectgarbage ( )

        -- on Lua prior 5.2, there is no such __gc for tables --
        -- therefore, this test will fail for that versions   --
        -- mostly cause double.scale will be a nil value      --
        assert.truthy (rawequal (scale, double.scale))
    end)

    -- ensures issue #1 fixing --
    it ("should not break lookup soundness on nil value", function ( )
        local point = families.clone (point2d, { x = 8, })

        -- let's add some thing for prototype --
        function point2d: print ( )
            return ("(%d, %d)"): format (self.x, self.y)
        end

        assert.same (point2d: print ( ), "(0, 0)")
        assert.same (point.print, nil)

        -- trying to break things is the best way to improve them --
        point2d.print = nil

        assert.same (point.print, nil)
    end)

    it ("should not accept invalid arguments on cloning", function ( )
        assert.error (function ( )
            families.clone ("invalid prototype passed here", nil)
        end, reason.invalid.prototype)
    end)

    -- ensures issue #2 fixing --
    it ("should be able to propagate changes whenever they occur", function ( )
        local pointA = families.clone (point2d, { y = 14, })

        -- triggering mutation --
        point2d: move (3, 6)

        assert.falsy (point2d.x == pointA.x)

        local pointB = families.clone (point2d)

        -- triggering mutation again on the same fields --
        point2d: move (-3, -6)

        assert.falsy (point2d.x == pointB.x)
    end)

    it ("should not be usable when it enters in destroyed state", function ( )
        assert.error (function ( )
            families.destroy ("invalid object")
        end, reason.invalid.object)

        local point = families.clone (point2d)

        -- doesn't matter how much we call such function --
        families.destroy (point)
        families.destroy (point)

        assert.error (function ( )
            local _ = point.x
        end, reason.invalid.destroyed)

        assert.error (function ( )
            point.y = 10
        end, reason.invalid.destroyed)

        assert.error (function ( )
            print (point)
        end, reason.invalid.destroyed)
    end)
end)

-- END --
