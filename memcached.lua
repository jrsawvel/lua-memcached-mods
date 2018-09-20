
-- jrs september 2018
-- original code: https://github.com/silentbicycle/lua-memcached
-- the original author's copyright notice:

--[[-------------------------------------------------------------------
Copyright (c) 2010 Scott Vokes <vokes.s@gmail.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
--]]-------------------------------------------------------------------




-- Dependencies
local socket = require "socket"


local mt = {}



local new = function(host, port)
    host, port = host or "localhost", port or 11211

    local status = true

    local conn, err = socket.connect(host, port)

    if not conn then
        status = false
    end

    local obj = {
        host   = host,
        port   = port,
        status = status,
        err    = err,
        socket = conn
    }

    return setmetatable(obj, mt)
end



local function _send_recv(s, msg)
    local rc, err = s:send(msg)
    if not rc then return false, err end

    rc, err = s:receive()
    if not rc then return false, err end

   return rc
end



local get_value_for_key = function(self, key)
    local pattern = "^VALUE ([^ ]+) (%d+) (%d+)"

    local msg = string.format("get %s\r\n", key)

    local rc, err = _send_recv(self.socket, msg)

    if rc == "END" then return nil, "No value found for key" end

    local flags, len, data, cas = {}

    while rc ~= "END" do
        if not rc then return false, err end

        key, flags, len, cas = rc:match(pattern)
        if not key then return nil, "No value found for key" end

        data, err = self.socket:receive(tonumber(len) + 2):sub(1, -3)
        if not data then return false, err end

        rc, err = self.socket:receive()
    end

    return data
end
mt.get = get_value_for_key



local set_value_for_key = function(self, key, data, exptime)
    if type(data) == "number" then data = tostring(data) end

    if not key then
        return false, "no key"
    elseif type(data) ~= "string" then
        return false, "no data"
    end

    exptime = exptime or 0

    local flags = 0
    local cmd = "set"

    local msg = cmd .. " " .. key .. " " .. flags .. " " .. exptime .. " "
        .. data:len() .. "\r\n" .. data .. "\r\n"

    local rc, err = _send_recv(self.socket, msg)

    return rc and rc == "STORED", rc or false, err
end
mt.set = set_value_for_key



local delete_key_value = function (self, key)
    local msg = string.format("delete %s%s\r\n", key, "")

    local rc, err = _send_recv(self.socket, msg)

    return rc and rc == "DELETED", rc or false, err
end
mt.delete = delete_key_value



local close_connection = function(self)
   return _send_recv(self.socket, "quit\r\n")
end
mt.quit = close_connection



local get_server_version = function(self)
   return _send_recv(self.socket, "version\r\n")
end
mt.version = get_server_version



mt.__index = mt

mt.__metatable = {}

local ctor = function(cls, ...)
  return new(...)
end


return setmetatable({}, { __call = ctor })




