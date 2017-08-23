#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  cloning_spec.lua
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

        assert.equals (point3d.x, point2d.x)
        assert.equals (point3d.y, point2d.y)
        assert.equals (point3d.z, 0)

        -- some mutation occurring here --
        point2d: move (5, 12)

        -- but it's not propagated into clones --
        assert.falsy  (point2d.x == point3d.x)
        assert.falsy  (point2d.y == point3d.y)
        assert.truthy (point3d.z == 0)

        point3d: move (5, 12, 0)

        assert.equals (point3d.x, point2d.x)
        assert.equals (point3d.y, point2d.y)
        assert.equals (point3d.z, 0)

        -- clean up --
        point2d: move (-5, -12)

        assert.falsy  (point2d.x == point3d.x)
        assert.falsy  (point2d.y == point3d.y)
        assert.truthy (point3d.z == 0)
    end)

    it ("should make the clone independent from prototype and vice-versa",
    function ( )
        local clone = families.clone (point2d, { })

        assert.equals (point2d.x, clone.x)
        assert.equals (point2d.y, clone.y)

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

        assert.equals (point.y, point2d.y)
        assert.falsy  (point.x == point2d.x)

        -- let's add some thing for prototype --
        function point2d: print ( )
            return ("(%d, %d)"): format (self.x, self.y)
        end

        -- that thing exists only on prototype itself --
        assert.same (point2d: print ( ), "(0, 0)")

        assert.error (function ( )
            point: print ( )
        end, reason.missing.property: format "print")

        -- trying to break things is the best way to improve them --
        point2d.print = nil

        assert.error (function ( )
            point2d: print ( )
        end, reason.missing.property: format "print")

        -- still nil, despite removed prototype's selector --
        assert.error (function ( )
            point: print ( )
        end, reason.missing.property: format "print")
    end)

    it ("should not accept invalid arguments on cloning", function ( )
        assert.error (function ( )
            families.clone ("invalid prototype passed here", nil)
        end, reason.invalid.prototype)

        assert.error (function ( )
            local clone = families.clone (point2d, { })

            families.destroy (clone)
            families.destroy (clone)

            local _ = families.clone (clone, { })
        end, reason.invalid.destroyed)
    end)

    -- ensures issue #2 fixing --
    it ("should be able to propagate changes whenever they occur",
    function ( )
        local pointA = families.clone (point2d, { y = 14, })

        assert.truthy (point2d.x == pointA.x)
        assert.falsy  (point2d.y == pointA.y)

        -- triggering mutation --
        point2d: move (3, 6)

        assert.falsy (point2d.x == pointA.x)
        assert.falsy (point2d.y == pointA.y)

        local pointB = families.clone (point2d)

        assert.truthy (point2d.x == pointB.x)
        assert.truthy (point2d.y == pointB.y)

        -- triggering mutation again on the same fields --
        point2d: move (-3, -6)

        assert.falsy  (point2d.y == pointB.y)
        assert.falsy  (point2d.x == pointB.x)
        assert.truthy (point2d.x == pointA.x)
    end)

    it ("should not be usable when it enters in destroyed state",
    function ( )
        assert.error (function ( )
            families.destroy ("invalid object")
        end, reason.invalid.object)

        local point = families.clone (point2d, { x = -5, y = 16, })
        local clone = families.clone (point, { y = 19, })

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
            local _ = families.clone (point)
        end, reason.invalid.destroyed)

        families.destroy (clone)
    end)

    -- ensures issue #3 fixing --
    it ("should not propagate changes on existent properties", function ( )
        local point = families.clone (point2d, { x = 7, })

        assert.same (point.x,   7)
        assert.same (point.y,   0)
        assert.same (point2d.y, 0)

        -- let's trigger some mutation --
        point2d: move (8, 8)

        -- prototype's mutation won't affect child's existent selectors --
        assert.same (point.x, 7)
        assert.same (point.y, 0)

        -- cleanup to default state --
        point2d: move (-8, -8)

        assert.truthy (point.y == point2d.y)
        assert.falsy  (point.x == point2d.x)
        assert.truthy (point.x == 7)
    end)

    it ("should make nil-cloning and ex-nihilo creation equivalent",
    function ( )
        local former = families.clone (nil, {
            name         = "Zero",
            power        = "Geass",
            strength     = 15,
            intelligence = 90,
        })

        local latter = families.prototype {
            name         = "Zero",
            power        = "Geass",
            strength     = 15,
            intelligence = 90,
        }

        for selector, value in families.pairs (former) do
            assert.same (value, latter[ selector ])
        end

        for selector, value in families.pairs (latter) do
            assert.same (value, former[ selector ])
        end
    end)

    it ("should not be able to remove fields on cloning", function ( )
        -- this is due the Lua's table semantics --
        -- and I must not break that thing...    --

        local sword = families.prototype {
            name     = "Cheap Sword",
            weakness = { "Water", "Thunder", },
        }

        local excalibur = families.clone (sword, {
            name     = "Excalibur Sword",
            weakness = nil,
        })

        assert.same (sword.name, "Cheap Sword")
        assert.same (sword.weakness, { "Water", "Thunder", })

        assert.same (excalibur.name, "Excalibur Sword")
        assert.same (excalibur.weakness, { "Water", "Thunder", })

        -- exclusion is only possible after cloning --
        excalibur.weakness = nil

        assert.error (function ( )
            return excalibur.weakness
        end, reason.missing.property: format 'weakness')
    end)
end)

-- END --
