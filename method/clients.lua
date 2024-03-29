local lpack = require 'lpack'

local path = 'log/clients.log'

local clients = {}

---@class client
local mt = {}
mt.__index   = mt
mt.token     = nil
mt._name     = '<UNKNOWN>'
mt._OS       = '<UNKNOWN>'
mt._CRT      = '<UNKNOWN>'
mt._Compiler = '<UNKNOWN>'
mt._version  = '<UNKNOWN>'

function mt:remove()
    if self._removed then
        return
    end
    self._removed = true
    clients[self.token] = nil
end

function mt:setName(name)
    if name == '' then
        return
    end
    self._name = name
end

function mt:getName()
    return self._name
end

function mt:setOS(OS)
    self._OS = OS
end

function mt:getOS()
    return self._OS
end

function mt:setCRT(CRT)
    self._CRT = CRT
end

function mt:getCRT()
    return self._CRT
end

function mt:setCompiler(Compiler)
    self._Compiler = Compiler
end

function mt:getCompiler()
    return self._Compiler
end

function mt:setVersion(version)
    self._version = version
end

function mt:getVersion()
    return self._version
end

function mt:versionGE(version)
    local a1, b1, c1 = self._version:match '(%d+)%.(%d+)%.(%d+)'
    local a2, b2, c2 = version:match '(%d+)%.(%d+)%.(%d+)'
    if not a1 or not a2 then
        return false
    end
    if a1 > a2 then
        return true
    end
    if a1 < a2 then
        return false
    end
    if b1 > b2 then
        return true
    end
    if b1 < b2 then
        return false
    end
    if c1 > c2 then
        return true
    end
    if c1 < c2 then
        return false
    end
    return true
end

function mt:isDisconnected()
    return os.time() - self._lastPulse >= 60 * 60
end

function mt:updateConnect()
    self._lastPulse = os.time()
end

---@return client
local function getClient(token)
    if not clients[token] then
        clients[token] = setmetatable({
            token      = token,
            _lastPulse = os.time(),
        }, mt)
    end
    return clients[token]
end

local function onPulse(token, name)
    local client = getClient(token)
    client:setName(name)
    client:updateConnect()
end

local function onPlatform(token, OS, CRT, Compiler)
    local client = getClient(token)
    client:setOS(OS)
    client:setCRT(CRT)
    client:setCompiler(Compiler)
end

local function onVersion(token, version)
    local client = getClient(token)
    client:setVersion(version)
end

local function listCount(getter)
    local map = {}
    for _, client in pairs(clients) do
        local name = getter(client)
        map[name] = (map[name] or 0) + 1
    end

    local names = {}
    for name in pairs(map) do
        names[#names+1] = name
    end

    table.sort(names, function (a, b)
        if map[a] == map[b] then
            return a < b
        end
        return map[a] > map[b]
    end)

    local total = 0
    for _, count in pairs(map) do
        total = total + count
    end

    local lines = {}
    lines[#lines+1] = ('TOTAL: %d'):format(total)
    for _, name in ipairs(names) do
        lines[#lines+1] = ('% 8d: %s'):format(map[name], name)
    end

    return table.concat(lines, '\n')
end

ngx.timer.every(10, function ()
    for _, client in pairs(clients) do
        if client:isDisconnected() then
            client:remove()
        end
    end

    local buf = {}
    buf[#buf+1] = '===Name==='
    buf[#buf+1] = listCount(function (client)
        return client:getName()
    end)
    buf[#buf+1] = '===Version==='
    buf[#buf+1] = listCount(function (client)
        return client:getVersion()
    end)
    buf[#buf+1] = '===OS==='
    buf[#buf+1] = listCount(function (client)
        return client:getOS()
    end)
    buf[#buf+1] = '===CRT==='
    buf[#buf+1] = listCount(function (client)
        return client:getCRT()
    end)
    buf[#buf+1] = '===Compiler==='
    buf[#buf+1] = listCount(function (client)
        return client:getCompiler()
    end)

    local info = table.concat(buf, '\n')
    io.stdout:write(info)
    io.stdout:flush()

    local f = io.open(path, 'wb')
    if f then
        f:write(info)
        f:close()
    end
end)

return {
    onPulse    = onPulse,
    onPlatform = onPlatform,
    onVersion  = onVersion,
    getClient  = getClient,
}
