local redis = require "resty.redis"

local m = {}

function m.get()
    local red = redis:new()

    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("failed to connect: ", err)
        return nil
    end

    return red
end

function m.call(callback, ...)
    local red = m.get()
    if not red then
        return nil
    end

    local res = callback(red, ...)

    --local ok, err = red:set_keepalive(10000, 100)
    --if not ok then
    --    ngx.say("failed to set keepalive: ", err)
    --    return nil
    --end

    return res
end

return m
