local m = {}

local function seeLog(path)
    ngx.say('=======================', '<br>')
    ngx.say(path, '<br>')
    ngx.say('=======================', '<br>')
    local str = io.open(path)
        : read('*a')
        : gsub('[\r\n]', '<br>')
    ngx.say(str)
end

function m.see()
    seeLog 'log/clients.log'
    seeLog 'log/error.log'
end

return m
