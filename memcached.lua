

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



local get_value_for_key = function(self, key)
    local pattern = "^VALUE ([^ ]+) (%d+) (%d+)"

    local msg = string.format("get %s\r\n", key)

    local rc, err = self.socket:send(msg)
    if not rc then return false, err end

    rc, err = self.socket:receive()
    if not rc then return false, err end

    if rc == "END" then return false, "No value found for key" end

    local res, key, flags, len, data, cas = {}

    while rc ~= "END" do
        if not rc then return false, err end

        key, flags, len, cas = rc:match(pattern)
        if not key then return false, "No value found for key" end

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

    local rc, err = self.socket:send(msg)
    if not rc then return false, err end

    rc, err = self.socket:receive()
    if not rc then return false, err end

    return rc and rc == "STORED", rc or false, err
end
mt.set = set_value_for_key





mt.__index = mt
 
mt.__metatable = {}
 
local ctor = function(cls, ...)
  return new(...)
end

 
return setmetatable({}, { __call = ctor })




