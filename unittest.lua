
-- https://github.com/silentbicycle/lunatest
local lunatest = require "lunatest"

package.path = package.path .. ';/home/memcached/lua-memcached-mods/?.lua'
local memcached = require "memcached"

pcall(require, "luacov")

local assert_true, assert_false = lunatest.assert_true, lunatest.assert_false
local assert_nil = lunatest.assert_nil
local assert_match = lunatest.assert_match


local m


function setup()
   m = assert(memcached(), "Is the server running?")
end


function test_get_unavailable()
   local v = m:get("foobar")
   assert_nil(v, "Shouldn't be defined yet")
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


function test_delete()
   local ok, res = m:set("foo", "bar")
   assert_true(ok, res)
   local val = m:get("foo")
   assert_true(val == "bar")
   m:delete("foo")
   assert_nil(m:get("foo"))
end


function test_version()
   assert_match("^VERSION", m:version())
end


lunatest.run(true)


