local m = {}

m._tickList = {}
m._curTick = nil

function m.onTick(callback)
    m._tickList[#m._tickList+1] = callback
end

function m._wakeUp(tick)
    local date = os.date('*t', tick)
    for _, callback in ipairs(m._tickList) do
        local suc, err = xpcall(callback, debug.traceback, tick, date)
        if not suc then
            ngx.log(ngx.ERR, err)
        end
    end
end

function m._updateTicks()
    local time = os.time()
    if not m._curTick then
        m._curTick = time - 1
    end
    for tick = m._curTick + 1, time do
        m._curTick = tick
        m._wakeUp(tick)
    end
end

function m.update()
    m._updateTicks()
end

return m
