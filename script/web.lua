local m = {}

local function seeLog(path)
    local f = io.open(path)
    if not f then
        return
    end
    ngx.say('=======================', '<br>')
    ngx.say(path, '<br>')
    ngx.say('=======================', '<br>')
    local str = f:read('*a')
                 :gsub('[\r\n]', '<br>')
    ngx.say(str)
    f:close()
end

function m.see()
    seeLog 'log/clients.log'
    seeLog 'log/error.log'
end

return m
