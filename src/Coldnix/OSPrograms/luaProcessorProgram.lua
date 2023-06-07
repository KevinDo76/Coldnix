print("starting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=true
terminal.prefix=_VERSION..": "
terminal.reload()
_G.exit=false
_G.ControlDown=false
EventManager.regsisterListener("luainterdown","key_down",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=true
    elseif keyboardcode==46 and ControlDown then
        _G.exit=true 
        terminal.type("^C")
        terminal.enter()
    end
end)

EventManager.regsisterListener("luainterup","key_up",function(componentId,asciiNum,keyboardcode)
    if keyboardcode==29 then
        ControlDown=false
    end
end)

local function returnValue(value)
    if type(value)~="string" then
        return value
    end
    local func,err = load("local a="..value.." return a","=Lua interpreter","t",_G)
    if func then
        return func()
    else
        return "nil"
    end
end

local function listToString(obj,name,minimal)
    if type(obj)=="table" then
        local str=""
        for i,v in pairs(obj) do
            --the extra parameters are meant for recursive, not impletmented due to memory limitation
            if not minimal then
                --str=str..'\n    '..i.."="..tostring(listToString(obj[i],"",true))..","
                str=str..'\n        '..i.."="..tostring(obj[i])..","
            else
                str=str.." "..tostring(listToString(obj[i],""))..","
            end
        end
        if minimal then
            str=name.."{"..str
        else
            str=name.."={"..str
        end
        return string.sub(str,1,#str-1).."\n"..string.rep(" ",#name+2).."}"
    else
        return obj
    end
end

while not exit do
    local inp=terminal.input(_VERSION..": ")
    if string.sub(inp,#inp-1,#inp)~="^C" then
        local func,err=load(inp,"=Lua interpreter","t",_G)
        --checking for single value request
        local split=string.split(inp," ")
        local single=false
        for i,v in pairs(split) do
            if #v>0 and not single then
                single=true
            else
                single=false
                break
            end
        end
        if single and err then
            print(listToString(returnValue(inp),inp))
            func = function() end
        end
        if func then
            local succ,err=pcall(function() func() end)
            if not succ then
                print("Runtime error: "..(err or "nil"))
            end
        else
            print(err)
        end
    else
        break
    end
end
print("Exiting ".._VERSION.." Terminal")
commandAPI.noCommandProcess=false
terminal.prefix=System.filesystem.getPrefixWorkingDir()..currentWorkingDir..": "
terminal.reload()
_G.exit=nil
_G.ControlDown=nil
EventManager.removeListener("luainterdown")
EventManager.removeListener("luainterup")