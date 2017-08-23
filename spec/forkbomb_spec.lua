#!/usr/bin/env lua

--
--------------------------------------------------------------------------------
--         File:  forkbomb_spec.lua
--
--        Usage:  ./forkbomb_spec.lua
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
--      Created:  17-08-2017
--     Revision:  ---
--------------------------------------------------------------------------------
--

require 'busted.runner' ( )

local families = require 'families'

describe ("families clone early, clone often lemma", function ( )
    it ("should be able to clone and collect objects without problems",
    function ( )
        local clones    = 1000
        local prototype = families.prototype { level = 0, kind = "test", }

        do
            local clone = prototype

            for index = 1, clones do
                clone = families.clone (prototype, { level = index, })
            end

            assert.same (clone.level, clones)
            assert.same (clone.kind, prototype.kind)
        end
    end)
end)

-- END --
