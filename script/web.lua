local m = {}

local esc = {
    ['\r'] = '<br>',
    ['\n'] = '<br>',
    [' ']  = '&#160;',
    ['<']  = '&#60;',
    ['>']  = '&#62;',
    ['&']  = '&#38;',
    ['"']  = '&#34;',
    ['\''] = '&#39;',
}

local function seeLog(path)
    local f = io.open(path)
    if not f then
        return
    end
    ngx.say('=======================', '<br>')
    ngx.say(path, '<br>')
    ngx.say('=======================', '<br>')
    local str = f:read('*a')
                 :gsub('.', esc)
    ngx.say(str, '<br>')
    f:close()
end

function m.see()
    seeLog 'log/clients.log'
    seeLog 'log/error.log'
end

return m
