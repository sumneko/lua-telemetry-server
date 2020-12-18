local proto = require 'script.proto.proto'
local zero  = require 'script.proto.zero'

local m = {}

function m.recive()
    ngx.req.read_body()
    local stream = ngx.req.get_body_data()
    if not stream then
        ngx.log(ngx.ERR, '没有收到数据？')
        return nil, 'no data'
    end

    local suc, zstream = xpcall(zero.decode, debug.traceback, stream)
    if not suc then
        ngx.log(ngx.ERR, zstream, ('%q'):format(stream))
        return nil, zstream
    end
    local suc, data = xpcall(proto.decode, debug.traceback, zstream)
    if not suc then
        ngx.log(ngx.ERR, data, ('%q'):format(zstream))
        return nil, data
    end

    return data
end

function m.response(data)
    --ngx.log(ngx.INFO, 'response: ', data.request, ' ', data.result)
    local rstream = zero.encode(proto.encode(data))
    ngx.print(rstream)
end

return m
