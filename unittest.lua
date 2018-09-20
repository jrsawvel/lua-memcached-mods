
-- https://github.com/silentbicycle/lunatest
local lunatest = require "lunatest"

package.path = package.path .. ';/home/memcached/lua-memcached-mods/?.lua'
local memcached = require "memcached"

pcall(require, "luacov")

local assert_true, assert_false = lunatest.assert_true, lunatest.assert_false

local m


function setup()
   m = assert(memcached(), "Is the server running?")
end


function test_set()
   local ok, res = m:set("foo", "bar")
   assert_true(ok, res)
   assert_true(res == "STORED")
end


function test_set_get()
   local ok, res = m:set("foo", "bar")
   assert_true(ok, res)
   local val = m:get("foo")
   assert_true(val == "bar")
end

lunatest.run(true)

