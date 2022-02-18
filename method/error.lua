local clog    = require 'script.log'
local lpack   = require 'lpack'
local clients = require 'method.clients'

local log = clog 'log/error.log'
local caches = {}

local function occlusionPath(str)
    return str:gsub('[^"\r\n]+', function (chunk)
        if not chunk:find '[/\\]' then
            return
        end
        local newStr, count = chunk:gsub('.+([/\\]script[/\\])', '***%1')
        if count > 0 then
            return newStr
        elseif chunk:find '^%u:'
        or     chunk:sub(1, 1) == '/' then
            return '***'
        end
    end)
end

return function (token, stream)
    local client = clients.getClient(token)
    if not client:versionGE '2.5.0' then
        return
    end
    local name, errq = lpack.unpack('zz', stream)
    if errq:sub(1, 1) ~= '"' then
        return
    end
    local err = assert(load('return ' .. errq))()
    if err:find('invalid address') then
        return
    end
    if caches[err] then
        return
    end
    caches[err] = true
    local info = ('version: %s\nclient: %s\n    %s\n\n'):format(client:getVersion(), name, occlusionPath(err):gsub('\n', '\n    '))
    log:write(info)
    io.stdout:write(info)
    io.stdout:flush()
end
