local mt = {}
mt.__index = mt

function mt:write(...)
    if self._handle then
        self._handle:write(...)
    end
end

function mt:close()
    if self._handle then
        self._handle:close()
    end
end

return function (name)
    local dir = name:gsub('[/\\]+[^/\\]+$', '')
    os.execute('md ' .. dir)
    local self = setmetatable({
        _handle = io.open(name, 'wb'),
    }, mt)
    self._handle:setvbuf 'no'
    return self
end
