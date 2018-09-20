#!/usr/local/bin/lua


-- jrs 30aug2018
package.path = package.path .. ';/home/memcached/lua-memcached-mods/?.lua'

-- jrs 30aug2018 added the `local <var> =` snytax
local memcached = require "memcached"


local host = "localhost"
local port = "11211"

-- will use default host and port specified in module
local m = memcached()

-- local m = memcached(host, port)

if not m.status then 
    error(m.err) 
else
    print(type(m))
    print(m.host) 
    print(m.port) 
    print(type(m.socket))


    local key = "grebe.soupmode.com-533"

    local v, msg = m:get(key)

    if not v then
        error(msg)
    else
        print("returned value = " .. v)
    end

    local rc
    rc, msg = m:set("hobby", "crochet")
    if not rc then
        error(msg)
    else
        print("set hobby = crochet ") 
        print(rc, msg)

        v, msg = m:get("hobby")
        print(v, msg or "")

    end 
end

